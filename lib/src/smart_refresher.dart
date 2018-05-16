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
    with TickerProviderStateMixin, BuildFactory {
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
//    if (notification.metrics.outOfRange &&
//        _mDragPointY == null &&
//        (_isPullUp(notification) || _isPullDown(notification)))
//      _mDragPointY = _mScrollController.offset;
//    if (_isPullUp(notification))
//      _changeMode(notification, RefreshStatus.startDrag);
//    if(widget.enablePullDownRefresh)
//      widget.header.onDragStart(notification);
//    if(widget.enablePullUpLoad)
//      widget.footer.onDragStart(notification);
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
    GestureDelegate deleagte = _mHeaderKey.currentState as GestureDelegate;
    deleagte.onDragMove(notification);
//    if(widget.enablePullDownRefresh)
//      widget.header.onDragMove(notification);
//    if(widget.enablePullUpLoad)
//      widget.footer.onDragMove(notification);
    return false;
  }

//  double _measure(ScrollNotification notification){
//    if(widget.header&&widget.header!=null){
//      return widget.header.meas
//    }
//    else if(notification.metrics.extentAfter==0){
//
//    }
//    return 0.0;
//  }

  //handle the scrollEndEvent
  bool _handleScrollEnd(ScrollNotification notification) {
//  if(widget.enablePullDownRefresh)
//    widget.header.onDragEnd(notification);
//  if(widget.enablePullUpLoad)
//    widget.footer.onDragEnd(notification);
    GestureDelegate deleagte = _mHeaderKey.currentState as GestureDelegate;
    deleagte.onDragEnd(notification);
    _resumeVal();
    return false;
  }

  /**
    this will handle the Scroll Event in ListView,
    I find flutter one Bug:the doc said:Return true to cancel
      the notification bubbling. Return false (or null) to
      allow the notification to continue to be dispatched to
      further ancestors.
     I tried to return true,  But it didn't work,the event still
      pass to me
   */
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
//    if(widget.enablePullDownRefresh)
//      widget.header..modeListener.addListener((){
//        if(widget.header.mode==RefreshStatus.refreshing){
//          if(widget.onRefresh!=null){
//            widget.onRefresh(true,widget.header);
//          }
//        }
//        setState(() {
//        });
//      })..scrollController =_mScrollController;
//    if(widget.enablePullUpLoad)
//      widget.footer..modeListener.addListener((){
//        if(widget.footer.mode==RefreshStatus.refreshing){
//          if(widget.onRefresh!=null){
//            widget.onRefresh(false,widget.footer);
//          }
//        }
//        setState(() {
//        });
//      })..scrollController = _mScrollController;
  }

  void _onAfterBuild() {
    topMode.addListener(() {
      int mode = this.topMode.value;
      if (mode == RefreshStatus.refreshing) {
        if (widget.onRefresh != null) {
          widget.onRefresh(true, topMode);
        }
      }
      setState(() {});
    });
//    ClassicRefresher refresher = widget.header;
//    RefreshWrapper cc =refresher.globalKey.currentWidget;
//    print(cc.onDragMove);
    setState(() {
      if (widget.enablePullDownRefresh)
        _mHeaderHeight = _mHeaderKey.currentContext.size.height;
//      if(widget.enablePullUpLoad)
//        _mFooterHeight =_mFooterKey.currentContext.size.height;
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
                      ],
                    )),
                onNotification: _dispatchScrollEvent,
              )),
        ],
      );
    });
  }
}
