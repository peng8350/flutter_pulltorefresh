/**
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-01 11:39
 */

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:pull_to_refresh/src/indicator/classic_indicator.dart';
import 'package:pull_to_refresh/src/internals/build_factory.dart';
import 'package:pull_to_refresh/src/internals/indicator_wrap.dart';
import 'package:pull_to_refresh/src/internals/refresh_physics.dart';

typedef void OnRefresh(bool up, ValueNotifier<int> notifier);
typedef void OnOffsetChange(bool isUp, double offset);
typedef Widget HeaderBuilder(BuildContext context, RefreshStatus mode);
typedef Widget FooterBuilder(BuildContext context, RefreshStatus mode);

enum WrapperType { Refresh, Loading }

class RefreshStatus {
  static const int idle = 0;
  static const int canRefresh = 1;
  static const int refreshing = 2;
  static const int completed = 3;
  static const int failed = 4;
  static const int noMore = 5;
}

/**
    This is the most important component that provides drop-down refresh and up loading.
 */
class SmartRefresher extends StatefulWidget {
  //indicate your listView
  final Widget child;

  final Function header, footer;
  // This bool will affect whether or not to have the function of drop-up load.
  final bool enablePullUpLoad;
  //This bool will affect whether or not to have the function of drop-down refresh.
  final bool enablePullDownRefresh;
  // if enable auto Loadmore,it will loadmore when enter the bottomest
  final bool enableAutoLoadMore;
  // upper and downer callback when you drag out of the distance
  final OnRefresh onRefresh;
  // This method will callback when the indicator changes from edge to edge.
  final OnOffsetChange onOffsetChange;

  final WrapperType wrapperType;

  SmartRefresher({
    Key key,
    @required this.child,
    this.header,
    this.wrapperType,
    this.footer,
    this.enablePullDownRefresh: true,
    this.enablePullUpLoad: false,
    this.enableAutoLoadMore: true,
    this.onRefresh,
    this.onOffsetChange,
  })  : assert(child != null),
        super(key: key);

  @override
  _SmartRefresherState createState() => new _SmartRefresherState();
}

class _SmartRefresherState extends State<SmartRefresher>
    with TickerProviderStateMixin {
  // listen the listen offset or on...
  ScrollController _mScrollController;
  // the bool will check the user if dragging on the screen.
  bool _mIsDraging = false;
  // key to get height header of footer
  final GlobalKey _mHeaderKey = new GlobalKey(), _mFooterKey = new GlobalKey();
  // the height must be  equals your headerBuilder
  double _mHeaderHeight = 0.0, _mFooterHeight = 0.0;

  ValueNotifier<double> offset = new ValueNotifier(0.0);

  ValueNotifier<int> topMode = new ValueNotifier(0),
      bottomMode = new ValueNotifier(0);

  //handle the scrollStartEvent
  bool _handleScrollStart(ScrollStartNotification notification) {
    // This is used to interupt useless callback when the pull up load rolls back.
    if ((notification.metrics.outOfRange && notification.dragDetails == null)) {
      return false;
    }
    if (_mIsDraging) return false;
    _mIsDraging = true;
    GestureDelegate topWrap = _mHeaderKey.currentState as GestureDelegate;
    GestureDelegate bottomWrap = _mFooterKey.currentState as GestureDelegate;
    bottomWrap.onDragStart(notification);
    topWrap.onDragStart(notification);
    return false;
  }

  //handle the scrollMoveEvent
  bool _handleScrollMoving(ScrollUpdateNotification notification) {
    bool down = _isPullDown(notification);

    if (down) {
      if (widget.onOffsetChange != null)
        widget.onOffsetChange(notification.metrics.extentBefore == 0,
            notification.metrics.minScrollExtent - notification.metrics.pixels);
    } else {
      if (widget.onOffsetChange != null)
        widget.onOffsetChange(notification.metrics.extentAfter == 0,
            notification.metrics.pixels - notification.metrics.maxScrollExtent);
    }
    GestureDelegate topWrap = _mHeaderKey.currentState as GestureDelegate;
    GestureDelegate bottomWrap = _mFooterKey.currentState as GestureDelegate;
    bottomWrap.onDragMove(notification);
    topWrap.onDragMove(notification);
    return false;
  }


  //handle the scrollEndEvent
  bool _handleScrollEnd(ScrollNotification notification) {
    GestureDelegate topWrap = _mHeaderKey.currentState as GestureDelegate;
    GestureDelegate bottomWrap = _mFooterKey.currentState as GestureDelegate;
    bottomWrap.onDragEnd(notification);
    topWrap.onDragEnd(notification);

    _resumeVal();
    return false;
  }

  bool _dispatchScrollEvent(ScrollNotification notification) {
    // when is scroll in the ScrollInside,nothing to do
    if ((!_isPullUp(notification) && !_isPullDown(notification))) return false;
    if (notification is ScrollStartNotification) {
      return _handleScrollStart(notification);
    }
    if (notification is ScrollUpdateNotification) {
      //if dragDetails is null,This represents the user's finger out of the screen
      if (notification.dragDetails == null && _mIsDraging) {
        return _handleScrollEnd(notification);
      } else if (notification.dragDetails != null) {
        return _handleScrollMoving(notification);
      }
    }
    if (notification is ScrollEndNotification) {
      _handleScrollEnd(notification);
    }

    return false;
  }

  //After the end of the drag, some variables are reduced to the default value
  void _resumeVal() {
    _mIsDraging = false;
  }

  //check user is pulling up
  bool _isPullUp(ScrollNotification noti) {
    return noti.metrics.extentAfter == 0;
  }

  //check user is pulling down
  bool _isPullDown(ScrollNotification noti) {
    return noti.metrics.extentBefore == 0;
  }

  void init() {
    _mScrollController = new ScrollController();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _onAfterBuild();
    });
  }
  
  _modeChange(bool up,ValueNotifier<int> mode){
    
    switch(mode.value){
      case RefreshStatus.refreshing:
        if (widget.onRefresh != null) {
          widget.onRefresh(up, mode);
        }
        // this will update later
        if(up)
        _mScrollController.jumpTo(-50.0);
        break;
        
    }
    setState(() {

    });
  }

  void _onAfterBuild() {
    topMode.addListener(() {
      _modeChange(true, topMode);
    });
    bottomMode.addListener((){
      _modeChange(false, bottomMode);
    });
    setState(() {
      if (widget.enablePullDownRefresh)
        _mHeaderHeight = _mHeaderKey.currentContext.size.height;
      if(widget.enablePullUpLoad)
        _mFooterHeight =_mFooterKey.currentContext.size.height;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _mScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(builder: (context, cons) {
      return new Stack(
        children: <Widget>[
          new Positioned(
              top: !widget.enablePullDownRefresh ? 0.0 : -_mHeaderHeight,
              bottom: !widget.enablePullUpLoad ? 0.0 : -_mFooterHeight,
              left: 0.0,
              right: 0.0,
              child: new NotificationListener(
                child: new SingleChildScrollView(
                    controller: _mScrollController,
                    physics: new RefreshScrollPhysics(),
                    child: new Column(
                      children: <Widget>[
                        widget.header != null && widget.enablePullDownRefresh
                            ? new RefreshWrapper(
                                key: _mHeaderKey,
                                modeLis: topMode,
                                up: true,
                                child: widget.header(
                                    context, topMode.value, offset),
                              )
                            : new Container(),
                        new ConstrainedBox(
                          constraints: new BoxConstraints(
                              minHeight: cons.biggest.height),
                          child: widget.child,
                        ),
                        widget.footer != null && widget.enablePullDownRefresh
                            ? new LoadWrapper(
                          key: _mFooterKey,
                          modeLis: bottomMode,
                          up: false,
                          child: widget.footer(
                              context, bottomMode.value, offset),
                        )
                            : new Container()
                      ],
                    )),
                onNotification: _dispatchScrollEvent,
              )),
        ],
      );
    });
  }
}
