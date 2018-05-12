/**
 Author: Jpeng
 Email: peng8350@gmail.com
 createTime:2018-05-01 11:39
 */
import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:pull_to_refresh/src/build_factory.dart';
import 'package:pull_to_refresh/src/refresh_physics.dart';

typedef void OnRefreshChange(RefreshMode mode);
typedef void OnLoadChange(LoadMode mode);
typedef void OnOffsetChange(bool isUp, double offset);
typedef Widget HeaderBuilder(BuildContext context, RefreshMode mode);
typedef Widget FooterBuilder(BuildContext context, LoadMode mode);

enum RefreshMode { idle, startDrag, canRefresh, refreshing, completed, failed }
enum LoadMode { idle, emptyData, failed, loading }

/**
    This is the most important component that provides drop-down refresh and up loading.
 */
class SmartRefresher extends StatefulWidget {
  //indicate your listView
  final Widget child;
  //the indicator View when you pull down
  final HeaderBuilder headerBuilder;
  //the indicator View when you pull up
  final FooterBuilder footerBuilder;
  // This bool will affect whether or not to have the function of drop-up load.
  final bool enablePullUpLoad;
  //This bool will affect whether or not to have the function of drop-down refresh.
  final bool enablePullDownRefresh;
  // if enable auto Loadmore,it will loadmore when enter the bottomest
  final bool enableAutoLoadMore;
  //this will influerence the RefreshMode
  final RefreshMode refreshMode;
  final LoadMode loadMode;
  // completed show time
  final int completeDuration;
  // This value represents the distance that can be refreshed and trigger the callback drag.
  final double triggerDistance;
  // The scope of the display when the top indicator enters a refresh state
  final double topVisibleRange;
  // upper and downer callback when you drag out of the distance
  final OnRefreshChange onRefreshChange;
  final OnLoadChange onLoadChange;
  // This method will callback when the indicator changes from edge to edge.
  final OnOffsetChange onOffsetChange;

  SmartRefresher({
    Key key,
    @required this.child,
    this.enablePullDownRefresh: true,
    this.enablePullUpLoad: false,
    this.enableAutoLoadMore: true,
    this.headerBuilder,
    this.footerBuilder,
    this.refreshMode: RefreshMode.idle,
    this.topVisibleRange: 50.0,
    this.loadMode: LoadMode.idle,
    this.completeDuration: 800,
    this.onRefreshChange,
    this.onLoadChange,
    this.onOffsetChange,
    this.triggerDistance: 100.0,
  })  : assert(child != null),
        super(key: key);

  @override
  _SmartRefresherState createState() => new _SmartRefresherState();
}

class _SmartRefresherState extends State<SmartRefresher>
    with TickerProviderStateMixin, BuildFactory {
  // the two controllers can controll the top and bottom empty spacing widgets.
  AnimationController _mTopController;
  // animate change for icon top and bottom
  AnimationController _mTIconController;
  // listen the listen offset or on...
  ScrollController _mScrollController;
  // the bool will check the user if dragging on the screen.
  bool _mIsDraging = false, _mReachMax = false;
  // the ScrollStart Drag Point Y
  double _mDragPointY = null;
  // key to get height header of footer
  final GlobalKey _mHeaderKey = new GlobalKey(), _mFooterKey = new GlobalKey();
  // the height must be  equals your headerBuilder
  double _mHeaderHeight = 0.0;

  //handle the scrollStartEvent
  bool _handleScrollStart(ScrollStartNotification notification) {
    // This is used to interupt useless callback when the pull up load rolls back.
    if ((notification.metrics.outOfRange && notification.dragDetails == null)) {
      return false;
    }
    if (_mIsDraging) return false;
    _mIsDraging = true;
    if (notification.metrics.outOfRange &&
        _mDragPointY == null &&
        (_isPullUp(notification) || _isPullDown(notification)))
      _mDragPointY = _mScrollController.offset;
    if (_isPullUp(notification))
      _changeMode(notification, RefreshMode.startDrag);
    return false;
  }

  //handle the scrollMoveEvent
  bool _handleScrollMoving(ScrollUpdateNotification notification) {
    bool down = _isPullDown(notification);
    if (_mDragPointY == null && notification.metrics.outOfRange)
      _mDragPointY = _mScrollController.offset;
    if (down) {
      _updateIndictorIfNeed(
          _measureRatio(-_mScrollController.offset), notification);
    }

    return false;
  }

  //handle the scrollEndEvent
  bool _handleScrollEnd(ScrollNotification notification) {
    bool up = _isPullDown(notification);
    if (!_mReachMax) {
      _changeMode(notification, up ? RefreshMode.idle : LoadMode.idle);
      _dismiss(up ? up : false);
    } else {
      if (up) {
        _modeChangeCallback(true, RefreshMode.refreshing);
      } else {
        _modeChangeCallback(false, LoadMode.loading);
      }
    }
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
    bool down = _isPullDown(notification);
    bool up = _isPullUp(notification);
    // the reason why should do this,because Early touch at a specific location makes triggerdistance smaller.
    if (!down && !up) {
      _mDragPointY = null;
      return false;
    }
    if (_mScrollController.position.outOfRange &&
        _mScrollController.position.extentAfter == 0) {
      if (widget.loadMode == LoadMode.idle)
        _changeMode(notification, LoadMode.loading);
    }
    if ((down &&
            (widget.refreshMode == RefreshMode.refreshing ||
                widget.refreshMode == RefreshMode.failed ||
                widget.refreshMode == RefreshMode.completed)) ||
        (up && (widget.loadMode == LoadMode.loading))) {
      return false;
    }
    if ((up && !widget.enablePullUpLoad) ||
        (down && !widget.enablePullDownRefresh)) return false;
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
      return _handleScrollEnd(notification);
    }

    return true;
  }

  //After the end of the drag, some variables are reduced to the default value
  void _resumeVal() {
    _mReachMax = false;
    _mIsDraging = false;
    _mDragPointY = null;
  }

  /**
    up indicate drag from top (pull down)
   */
  void _dismiss(bool up) {
    /**
     why the value is 0.00001?
     If this value is 0, no controls will
     cause Flutter to automatically retrieve widget.
    */
    if (up) {
      _mTopController.animateTo(0.000001).then((Null val) {
        _modeChangeCallback(true, RefreshMode.idle);
      });
    }
  }

  // the indictor will update update when offset change between 1.0
  void _updateIndictorIfNeed(
      double offset, ScrollUpdateNotification notification) {
    _mReachMax = offset >= 1.0;
    if (widget.onOffsetChange != null)
      widget.onOffsetChange(notification.metrics.extentBefore == 0, offset);
    if (notification.metrics.extentBefore == 0) if (_mReachMax) {
      _changeMode(notification, RefreshMode.canRefresh);
    } else {
      _changeMode(notification, RefreshMode.startDrag);
    }
  }

  // change the top or bottom mode
  void _changeMode(ScrollNotification notifi, mode) {
    if (_isPullDown(notifi)) {
      if (widget.refreshMode == mode) return;
      if (widget.refreshMode == RefreshMode.refreshing) return;
      _modeChangeCallback(true, mode);
      if (widget.headerBuilder == null && widget.enablePullDownRefresh) {
        if (mode == RefreshMode.canRefresh) {
          _mTIconController.animateTo(1.0);
        } else if (mode == RefreshMode.startDrag) {
          _mTIconController.animateTo(0.0);
        }
      }
    } else if (_isPullUp(notifi)) {
      if (widget.loadMode == mode) return;
      if (widget.loadMode == LoadMode.loading) return;
      if (mode.runtimeType == RefreshMode) return;
      _modeChangeCallback(false, mode);
    }
  }

  //check user is pulling up
  bool _isPullUp(ScrollNotification noti) {
    return noti.metrics.extentAfter == 0;
  }

  //check user is pulling down
  bool _isPullDown(ScrollNotification noti) {
    return noti.metrics.extentBefore == 0;
  }

  /**
      This method takes accounting to figure out how many distances the user dragged.
   */
  double _measureRatio(double offset) {
    return offset / widget.triggerDistance;
  }

  void _modeChangeCallback(isUp, mode) {
    if (isUp && this.widget.onRefreshChange != null) {
      widget.onRefreshChange(mode);
    } else if (!isUp && this.widget.onLoadChange != null) {
      widget.onLoadChange(mode);
    }
  }

  void _onAfterBuild() {
    setState(() {
      if (widget.enablePullDownRefresh)
        _mHeaderHeight = _mHeaderKey.currentContext.size.height;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _mTIconController.dispose();
    _mScrollController.dispose();
    _mTopController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mScrollController = new ScrollController();
    _mTopController = new AnimationController(
      vsync: this,
      lowerBound: 0.000001,
      duration: const Duration(milliseconds: 200),
    );
    _mTIconController = new AnimationController(
        vsync: this,
        upperBound: 0.5,
        duration: const Duration(milliseconds: 100));
    // not possible insite initState
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _onAfterBuild();
    });
  }

  @override
  void didUpdateWidget(SmartRefresher oldWidget) {
    // TODO: implement didUpdateWidget
    if (widget.refreshMode == oldWidget.refreshMode &&
        oldWidget.loadMode == widget.loadMode) {
      return;
    }
    super.didUpdateWidget(oldWidget);
    if (widget.refreshMode != oldWidget.refreshMode) {
      if (widget.refreshMode == RefreshMode.refreshing) {
        _mTopController.value = 1.0;
        // if set Refresh when offset>listview.height cause bug?
        _mScrollController.jumpTo(-widget.topVisibleRange);
      } else if (RefreshMode.completed == widget.refreshMode ||
          RefreshMode.failed == widget.refreshMode) {
        new Future<Null>.delayed(
            new Duration(milliseconds: widget.completeDuration), () {
          _dismiss(true);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(builder: (context, cons) {
      return new Stack(
        children: <Widget>[
          new Positioned(
              top: !widget.enablePullDownRefresh ? 0.0 : -_mHeaderHeight,
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: new NotificationListener(
                child: new SingleChildScrollView(
                    controller: _mScrollController,
                    physics: new RefreshScrollPhysics(),
                    child: new Column(
                      children: <Widget>[
                        !widget.enablePullDownRefresh
                            ? new Container()
                            : buildEmptySpace(
                                _mTopController, widget.topVisibleRange),
                        new Container(
                            key: _mHeaderKey,
                            child: !widget.enablePullDownRefresh
                                ? new Container()
                                : widget.headerBuilder != null
                                    ? widget.headerBuilder(
                                        context, widget.refreshMode)
                                    : buildDefaultHeader(context,
                                        widget.refreshMode, _mTIconController)),
                        new ConstrainedBox(
                          constraints: new BoxConstraints(
                              minHeight: cons.biggest.height),
                          child: widget.child,
                        ),
                        new Container(
                          key: _mFooterKey,
                          child: !widget.enablePullUpLoad
                              ? new Container()
                              : widget.footerBuilder != null
                                  ? widget.footerBuilder(
                                      context, widget.loadMode)
                                  : buildDefaultFooter(
                                      context, widget.loadMode),
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
