/**
 Author: Jpeng
 Email: peng8350@gmail.com
 createTime:2018-05-01 11:39
 */
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:pull_to_refresh/src/build_factory.dart';
import 'package:pull_to_refresh/src/refresh_physics.dart';

typedef void OnModeChange(bool isUp, RefreshMode mode);
typedef void OnOffsetChange(double offset);
typedef Widget HeaderBuilder(BuildContext context, RefreshMode mode);
typedef Widget FooterBuilder(BuildContext context, RefreshMode mode);

enum RefreshMode { idel, startDrag, canRefresh, refreshing, completed, failed }

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
  //this will influerence the RefreshMode
  final RefreshMode refreshMode, loadMode;
  // completed show time
  final int completeDuration;
  // This value represents the distance that can be refreshed and trigger the callback drag.
  final double triggerDistance;
  // The scope of the display when the indicator enters a refresh state
  final double topVisibleRange, bottomVisibleRange;
  // the height must be  equals your headerBuilder
  final double headerHeight, footerHeight;
  // upper and downer callback when you drag out of the distance
  final OnModeChange onModeChange;
  // This method will callback when the indicator changes from edge to edge.
  final OnOffsetChange onOffsetChange;

  SmartRefresher({
    Key key,
    @required this.child,
    this.enablePullDownRefresh: true,
    this.enablePullUpLoad: false,
    this.headerBuilder,
    this.footerBuilder,
    this.refreshMode: RefreshMode.idel,
    this.bottomVisibleRange: 50.0,
    this.topVisibleRange: 50.0,
    this.headerHeight: 50.0,
    this.footerHeight: 50.0,
    this.loadMode: RefreshMode.idel,
    this.completeDuration: 800,
    this.onModeChange,
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
  AnimationController _mTopController, _mBottomController;
  // animate change for icon top and bottom
  AnimationController _mTIconController, _mBIconController;
  // listen the listen offset or on...
  ScrollController _mScrollController;
  // the bool will check the user if dragging on the screen.
  bool _mIsDraging = false, _mReachMax = false;
  // the ScrollStart Drag Point Y
  double _mDragPointY = null;

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
    } else {
      _updateIndictorIfNeed(
          _measureRatio(_mScrollController.offset - _mDragPointY),
          notification);
    }

    return false;
  }

  //handle the scrollEndEvent
  bool _handleScrollEnd(ScrollNotification notification) {
    bool up = _isPullDown(notification);
    if (!_mReachMax) {
      _changeMode(notification, RefreshMode.idel);
      _dismiss(up ? up : false);
    } else {
      if (up) {
        _modeChangeCallback(true, RefreshMode.refreshing);
      } else {
        _modeChangeCallback(false, RefreshMode.refreshing);
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
    if ((down &&
            (widget.refreshMode == RefreshMode.refreshing || widget.refreshMode == RefreshMode.failed||
                widget.refreshMode == RefreshMode.completed)) ||
        (up &&
            (widget.loadMode == RefreshMode.refreshing || widget.loadMode == RefreshMode.failed||
                widget.loadMode == RefreshMode.completed))) {
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
      if (!_mTopController.isDismissed) _mTopController.animateTo(0.000001);
    } else {
      if (!_mBottomController.isDismissed)
        _mBottomController.animateTo(0.000001);
    }
  }

  // the indictor will update update when offset change between 1.0
  void _updateIndictorIfNeed(
      double offset, ScrollUpdateNotification notification) {
    _mReachMax = offset >= 1.0;
    if (widget.onOffsetChange != null) widget.onOffsetChange(offset);
    if (_mReachMax) {
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
      if (widget.loadMode == RefreshMode.refreshing) return;
      _modeChangeCallback(false, mode);
      if (widget.footerBuilder == null && widget.enablePullUpLoad) {
        if (mode == RefreshMode.canRefresh) {
          _mBIconController.animateTo(0.0);
        } else if (mode == RefreshMode.startDrag) {
          _mBIconController.animateTo(1.0);
        }
      }
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
    if (this.widget.onModeChange != null) {
      widget.onModeChange(isUp, mode);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _mBIconController.dispose();
    _mTIconController.dispose();
    _mScrollController.dispose();
    _mBottomController.dispose();
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
    )..addStatusListener((status){
      if(_mTopController.value==0.000001&&status==AnimationStatus.completed){
        _modeChangeCallback(true, RefreshMode.idel);
      }
    });
    _mBottomController = new AnimationController(
      vsync: this,
      lowerBound: 0.000001,
      duration: const Duration(milliseconds: 200),
    )..addStatusListener((status){
      if(_mBottomController.value==0.000001&&status==AnimationStatus.completed){
       _modeChangeCallback(false, RefreshMode.idel);
      }
    });
    _mBIconController = new AnimationController(
        vsync: this,
        upperBound: 0.5,
        value: 0.5,
        duration: const Duration(milliseconds: 100));
    _mTIconController = new AnimationController(
        vsync: this,
        upperBound: 0.5,
        duration: const Duration(milliseconds: 100));
  }

  @override
  void didUpdateWidget(SmartRefresher oldWidget) {
    // TODO: implement didUpdateWidget
    if (widget.refreshMode == oldWidget.refreshMode &&
        oldWidget.loadMode == widget.loadMode) return;
    if (widget.refreshMode != oldWidget.refreshMode) {
      if (widget.refreshMode == RefreshMode.refreshing) {
        _mTopController.animateTo(1.0);
      } else if (RefreshMode.completed == widget.refreshMode||RefreshMode.failed==widget.refreshMode) {
        new Future<Null>.delayed(
            new Duration(milliseconds: widget.completeDuration), () {
          _dismiss(true);
        });
      }
    } else if (oldWidget.loadMode != widget.loadMode) {
      if (widget.loadMode == RefreshMode.refreshing) {
        _mBottomController.animateTo(1.0);
      } else if (widget.loadMode == RefreshMode.completed||RefreshMode.failed==widget.loadMode) {
        new Future<Null>.delayed(
            new Duration(milliseconds: widget.completeDuration), () {
          _dismiss(false);
        });
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(builder: (context, BoxConstraints size) {
      return new Stack(
        children: <Widget>[
          new Positioned(
              top: !widget.enablePullDownRefresh ? 0.0 : -widget.headerHeight,
              bottom: !widget.enablePullUpLoad ? 0.0 : -widget.footerHeight,
              left: 0.0,
              right: 0.0,
              child: new NotificationListener(
                child: new ListView(
                  controller: _mScrollController,
                  physics: new RefreshScrollPhysics(),
                  children: <Widget>[
                    !widget.enablePullDownRefresh
                        ? new Container()
                        : buildEmptySpace(
                            _mTopController, widget.topVisibleRange),
                    !widget.enablePullDownRefresh
                        ? new Container()
                        : widget.headerBuilder != null
                            ? widget.headerBuilder(context, widget.refreshMode)
                            : buildDefaultHeader(
                                context, widget.refreshMode, _mTIconController),
                    widget.child,
                    !widget.enablePullUpLoad
                        ? new Container()
                        : widget.footerBuilder != null
                            ? widget.footerBuilder(context, widget.loadMode)
                            : buildDefaultFooter(
                                context, widget.loadMode, _mBIconController),
                    !widget.enablePullUpLoad
                        ? new Container()
                        : buildEmptySpace(
                            _mBottomController, widget.bottomVisibleRange),
                  ],
                ),
                onNotification: _dispatchScrollEvent,
              ))
        ],
      );
    });
  }
}
