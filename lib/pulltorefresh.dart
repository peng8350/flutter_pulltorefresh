/**
 Author: Jpeng
 Email: peng8350@gmail.com
 createTime:2018-05-01 11:39
 */

library pulltorefresh;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pulltorefresh/BuildFactory.dart';
import 'refreshPhysics.dart';

typedef void OnRefresh();
typedef void OnLoadmore();
typedef Widget HeaderBuilder(BuildContext context,RefreshMode mode);
typedef Widget FooterBuilder(BuildContext context,RefreshMode mode);

enum RefreshMode { idel, startDrag, canRefresh, refreshing, completed }

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
  final bool enablePulldownRefresh;
  // This value represents the distance that can be refreshed and trigger the callback drag.
  final double triggerDistance;
  // completed show time
  final int completDuration;
  final Color bottomColor;
  // upper and downer callback when you drag out of the distance
  final OnRefresh onRefresh;
  final OnLoadmore onLoadmore;
  //this will influerence the RefreshMode
  final bool refreshing, loading;

  SmartRefresher(
      {@required this.child,
      this.enablePulldownRefresh: true,
      this.enablePullUpLoad: false,
      this.bottomColor: const Color(0xffdddddd),
      this.headerBuilder,this.footerBuilder,
      this.refreshing: false,
      this.loading: false,
      this.completDuration:800,
      this.onRefresh,
      this.onLoadmore,
      this.triggerDistance: 100.0,
      })
      : assert(child != null);

  @override
  _SmartRefresherState createState() => new _SmartRefresherState();
}

class _SmartRefresherState extends State<SmartRefresher>
    with TickerProviderStateMixin, BuildFactory {
  // the two controllers can controll the top and bottom empty spacing widgets.
  AnimationController _mTopController, _mBottomController;
  ScrollController _mScrollController;
  // Represents the state of the upper and lower two refreshes.
  RefreshMode _mTopMode, _mBottomMode;
  // the bool will check the user if dragging on the screen.
  bool _mIsDraging = false, _mReachMax = false;
  // the ScrollStart Drag Point Y
  double _mDragPointY = 0.0;

  //handle the scrollStartEvent
  bool _handleScrollStart(ScrollStartNotification notification) {
    // This is used to interupt useless callback when the pull up load rolls back.
    if (notification.metrics.outOfRange && notification.dragDetails == null) {
      print("out");
      return true;
    }
    if (_mIsDraging) return false;
    _mIsDraging = true;
    if (_mDragPointY == null &&
        (_isPullUp(notification) || _isPullDown(notification)))
      _mDragPointY = _mScrollController.offset;
    _changeMode(notification, RefreshMode.startDrag);
    return false;
  }

  //handle the scrollMoveEvent
  bool _handleScrollMoving(ScrollUpdateNotification notification) {
    bool isDown = _isPullDown(notification);
    bool isUp = _isPullUp(notification);
    // the reason why should do this,because Early touch at a specific location makes triggerdistance smaller.

    if (!isDown && !isUp) {
      return false;
    }
    if (_mDragPointY == null) _mDragPointY = _mScrollController.offset;
    if (isDown && _mTopMode != RefreshMode.refreshing) {
      _mTopController.value =
          _measureRatio(_mDragPointY - _mScrollController.offset);
      _mReachMax = _mTopController.value == 1.0;
      if (_mReachMax) {
        _changeMode(notification, RefreshMode.canRefresh);
      } else {
        _changeMode(notification, RefreshMode.startDrag);
      }
    } else if (isUp && _mBottomMode != RefreshMode.refreshing) {
      _mBottomController.value =
          _measureRatio(_mScrollController.offset - _mDragPointY);
      _mReachMax = _mBottomController.value == 1.0;
      if (_mReachMax) {
        _changeMode(notification, RefreshMode.canRefresh);
      } else {
        _changeMode(notification, RefreshMode.startDrag);
      }
    }

    return false;
  }

  //handle the scrollEndEvent
  bool _handleScrollEnd(ScrollNotification notification) {
    bool down = _isPullDown(notification);
    bool up = _isPullUp(notification);

    if ((!down && !up) ||
        (down && _mTopMode == RefreshMode.refreshing) ||
        (up && _mBottomMode == RefreshMode.refreshing)) {
      _resumeVal();
      return false;
    }
    if (!_mReachMax) {
      _changeMode(notification, RefreshMode.idel);
      _dismiss(down ? down : false);
    } else {
      if (up) {
        if (widget.onLoadmore != null) {
          widget.onLoadmore();
        }
      } else {
        if (widget.onRefresh != null) {
          widget.onRefresh();
        }
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
      if (_mIsDraging) {
        return _handleScrollEnd(notification);
      }
    }

    return true;
  }

  void _resumeVal() {
    _mReachMax = false;
    _mIsDraging = false;
    _mDragPointY = null;
  }

  //up indicate drag from top (pull down)
  void _dismiss(bool up) {
    /*
     why the value is 0.01?
     If this value is 0, no controls will
     cause Flutter to automatically retrieve controls.
    */
    if (up) {
      if (!_mTopController.isDismissed)
        _mTopController.animateTo(0.01,
            curve: new Cubic(0.0, 0.0, 1.0, 1.0),
            duration: const Duration(milliseconds: 200));
    } else {
      if (!_mBottomController.isDismissed)
        _mBottomController.animateTo(0.01,
            curve: new Cubic(0.0, 0.0, 1.0, 1.0),
            duration: const Duration(milliseconds: 200));
    }
  }

  void _changeMode(ScrollNotification notifi, mode) {
    if (_isPullDown(notifi)) {
      if (_mTopMode == mode) return;
      if (_mTopMode == RefreshMode.refreshing) return;
      setState(() {
        _mTopMode = mode;
      });
    } else if (_isPullUp(notifi)) {
      if (_mBottomMode == mode) return;
      if (_mBottomMode == RefreshMode.refreshing) return;
      setState(() {
        _mBottomMode = mode;
      });
    }
  }

  //up indicate drag from top (pull down)
  void _changeMode2(bool isUp, mode) {
    if (isUp) {
      if (_mTopMode == mode) return;
      if (_mTopMode == RefreshMode.refreshing) return;
      setState(() {
        _mTopMode = mode;
      });
    } else {
      if (_mBottomMode == mode) return;
      if (_mBottomMode == RefreshMode.refreshing) return;
      setState(() {
        _mBottomMode = mode;
      });
    }
  }

  bool _isPullUp(ScrollNotification noti) {
    return noti.metrics.extentAfter == 0;
  }

  bool _isPullDown(ScrollNotification noti) {
    return noti.metrics.extentBefore == 0;
  }

  // This method calculates the size of the head or tail that should be resized.
  double _measureRatio(double offset) {
    return offset / widget.triggerDistance;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _mScrollController.dispose();
    _mBottomController.dispose();
    _mTopController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mBottomMode = RefreshMode.idel;
    _mTopMode = RefreshMode.idel;
    _mScrollController = new ScrollController();
    _mTopController = new AnimationController(
      vsync: this,
      lowerBound: 0.01,
      duration: const Duration(milliseconds: 200),
    );
    _mBottomController = new AnimationController(
      vsync: this,
      lowerBound: 0.01,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didUpdateWidget(SmartRefresher oldWidget) {
    // TODO: implement didUpdateWidget
    if (widget.refreshing == oldWidget.refreshing &&
        oldWidget.loading == widget.loading) return;
    if (widget.refreshing != oldWidget.refreshing) {
      if (widget.refreshing) {
        this._mTopMode = RefreshMode.refreshing;
      } else {

        this._mTopMode = RefreshMode.completed;
        new Future<Null>.delayed(new Duration(milliseconds: widget.completDuration),(){
          this._mTopMode = RefreshMode.idel;
          _dismiss(true);
        });
      }
    } else if (oldWidget.loading != widget.loading) {
      if (widget.loading) {
        this._mBottomMode = RefreshMode.refreshing;
      } else {
        this._mBottomMode = RefreshMode.completed;
        new Future<Null>.delayed(new Duration(milliseconds: widget.completDuration),(){
          this._mBottomMode = RefreshMode.idel;
          _dismiss(false);
        });

      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(builder: (context, BoxConstraints size) {
      return new Container(
        color: widget.bottomColor,
        child: new OverflowBox(
          maxHeight: size.biggest.height + 100.0,
          child: new NotificationListener(
            child: new ListView(
              controller: _mScrollController,
              physics: new RefreshScrollPhysics(),
              children: <Widget>[
                buildEmptySpace(_mTopController),
                widget.headerBuilder!=null?widget.headerBuilder(context,_mTopMode):buildDefaultHeader(context, _mTopMode),
                widget.child,
                widget.footerBuilder!=null?widget.footerBuilder(context, _mBottomMode):buildDefaultFooter(context, _mBottomMode),
                buildEmptySpace(_mBottomController),
              ],
            ),
            onNotification: _dispatchScrollEvent,
          ),
        ),
      );
    });
  }
}
