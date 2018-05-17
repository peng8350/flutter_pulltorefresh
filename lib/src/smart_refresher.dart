/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-01 11:39
 */

import 'package:flutter/scheduler.dart';
import 'internals/default_constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:pull_to_refresh/src/internals/indicator_config.dart';
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

/*
    This is the most important component that provides drop-down refresh and up loading.
 */
class SmartRefresher extends StatefulWidget {
  //indicate your listView
  final Widget child;

  final Function header, footer;

  final Config headerConfig, footerConfig;
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

  SmartRefresher({
    Key key,
    @required this.child,
    this.header,
    this.footer,
    this.headerConfig: const RefreshConfig(),
    this.footerConfig: const LoadConfig(),
    this.enablePullDownRefresh: default_enablePullDown,
    this.enablePullUpLoad: default_enablePullUp,
    this.enableAutoLoadMore: true,
    this.onRefresh,
    this.onOffsetChange,
  })  : assert(child != null),
        super(key: key);

  @override
  _SmartRefresherState createState() => new _SmartRefresherState();
}

class _SmartRefresherState extends State<SmartRefresher> {
  // listen the listen offset or on...
  ScrollController _scrollController;
  // the bool will check the user if dragging on the screen.
  bool _isDraging = false;
  // key to get height header of footer
  final GlobalKey _headerKey = new GlobalKey(), _footerKey = new GlobalKey();
  // the height must be  equals your headerBuilder
  double _headerHeight = 0.0, _footerHeight = 0.0;

  ValueNotifier<double> _offsetLis = new ValueNotifier(0.0);

  ValueNotifier<int> _topModeLis = new ValueNotifier(0),
      _bottomModeLis = new ValueNotifier(0);

  //handle the scrollStartEvent
  bool _handleScrollStart(ScrollStartNotification notification) {
    // This is used to interupt useless callback when the pull up load rolls back.
    if ((notification.metrics.outOfRange && notification.dragDetails == null)) {
      return false;
    }
    if (_isDraging) return false;
    _isDraging = true;
    GestureProcessor topWrap = _headerKey.currentState as GestureProcessor;
    GestureProcessor bottomWrap = _footerKey.currentState as GestureProcessor;
    if (widget.enablePullUpLoad) bottomWrap.onDragStart(notification);
    if (widget.enablePullDownRefresh) topWrap.onDragStart(notification);
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
    if (_easure(notification) != -1.0) _offsetLis.value = _easure(notification);
    GestureProcessor topWrap = _headerKey.currentState as GestureProcessor;
    GestureProcessor bottomWrap = _footerKey.currentState as GestureProcessor;
    if (widget.enablePullUpLoad) bottomWrap.onDragMove(notification);
    if (widget.enablePullDownRefresh) topWrap.onDragMove(notification);
    return false;
  }

  //handle the scrollEndEvent
  bool _handleScrollEnd(ScrollNotification notification) {
    GestureProcessor topWrap = _headerKey.currentState as GestureProcessor;
    GestureProcessor bottomWrap = _footerKey.currentState as GestureProcessor;
    if (widget.enablePullUpLoad) bottomWrap.onDragEnd(notification);
    if (widget.enablePullDownRefresh) topWrap.onDragEnd(notification);

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
      if (notification.dragDetails == null && _isDraging) {
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
    _isDraging = false;
  }

  //check user is pulling up
  bool _isPullUp(ScrollNotification noti) {
    return noti.metrics.extentAfter == 0;
  }

  //check user is pulling down
  bool _isPullDown(ScrollNotification noti) {
    return noti.metrics.extentBefore == 0;
  }

  double _easure(ScrollNotification notification) {
    if (notification.metrics.minScrollExtent - notification.metrics.pixels >
        0) {
      return (notification.metrics.minScrollExtent -
              notification.metrics.pixels) /
          widget.headerConfig.triggerDistance;
    } else if (notification.metrics.pixels -
            notification.metrics.maxScrollExtent >
        0) {
      return (notification.metrics.pixels -
              notification.metrics.maxScrollExtent) /
          widget.footerConfig.triggerDistance;
    }
    return -1.0;
  }

  void init() {
    _scrollController = new ScrollController();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _onAfterBuild();
    });
  }

  _odeChange(bool up, ValueNotifier<int> mode) {
    switch (mode.value) {
      case RefreshStatus.refreshing:
        if (widget.onRefresh != null) {
          widget.onRefresh(up, mode);
        }
        // this will update later
//        if(up)
//        _ScrollController.jumpTo(-50.0);
        break;
    }
    setState(() {});
  }

  void _onAfterBuild() {
    _topModeLis.addListener(() {
      _odeChange(true, _topModeLis);
    });
    _bottomModeLis.addListener(() {
      _odeChange(false, _bottomModeLis);
    });
    setState(() {
      if (widget.enablePullDownRefresh)
        _headerHeight = _headerKey.currentContext.size.height;
      if (widget.enablePullUpLoad) {
        _footerHeight = _footerKey.currentContext.size.height;
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  Widget _buildWrapperByConfig(Config config, bool up) {
    if (config is LoadConfig) {
      return new LoadWrapper(
        key: up ? _headerKey : _footerKey,
        modeListener: up ? _topModeLis : _bottomModeLis,
        up: up,
        autoLoad: config.autoLoad,
        triggerDistance: config.triggerDistance,
        child: up
            ? widget.header(context, _topModeLis.value, _offsetLis)
            : widget.footer(context, _bottomModeLis.value, _offsetLis),
      );
    } else if (config is RefreshConfig) {
      return new RefreshWrapper(
        key: up ? _headerKey : _footerKey,
        modeLis: up ? _topModeLis : _bottomModeLis,
        up: up,
        triggerDistance: config.triggerDistance,
        visibleRange: config.visibleRange,
        child: up
            ? widget.header(context, _topModeLis.value, _offsetLis)
            : widget.footer(context, _bottomModeLis.value, _offsetLis),
      );
    }
    return new Container();
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(builder: (context, cons) {
      return new Stack(
        children: <Widget>[
          new Positioned(
              top: !widget.enablePullDownRefresh||widget.headerConfig is LoadConfig ? 0.0 : -_headerHeight,
              bottom: !widget.enablePullUpLoad||widget.footerConfig is LoadConfig ? 0.0 : -_footerHeight,
              left: 0.0,
              right: 0.0,
              child: new NotificationListener(
                child: new SingleChildScrollView(
                    controller: _scrollController,
                    physics: new RefreshScrollPhysics(),
                    child: new Column(
                      children: <Widget>[
                        widget.header != null && widget.enablePullDownRefresh
                            ? _buildWrapperByConfig(widget.headerConfig, true)
                            : new Container(),
                        new ConstrainedBox(
                          constraints: new BoxConstraints(
                              minHeight: cons.biggest.height),
                          child: widget.child,
                        ),
                        widget.footer != null && widget.enablePullUpLoad
                            ? _buildWrapperByConfig(widget.footerConfig, false)
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


abstract class Indicator extends StatefulWidget {
  final ValueNotifier<double> offsetListener;

  final int mode;

  const Indicator({Key key,this.mode, this.offsetListener}):super(key:key);
}