library pulltorefresh;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'refreshPhysics.dart';

typedef void OnRefresh();
typedef void OnLoadmore();

enum RefreshMode { idel, startDrag, canRefresh, refreshing, completed }

class SmartRefresher extends StatefulWidget {
  /*
     first:indicate your listView
     second: the View when you pull down
     third: the View when you pull up
   */
  final Widget child, header, footer;
  // This bool will affect whether or not to have the function of drop-up load.
  final bool enablePullUpLoad;
  //This bool will affect whether or not to have the function of drop-down refresh.
  final bool enablePulldownRefresh;
  // This value represents the distance that can be refreshed and trigger the callback drag.
  final double triggerDistance;

  final Color headerColor, footerColor;
  // upper and downer callback when you drag out of the distance
  final OnRefresh onRefresh;
  final OnLoadmore onLoadmore;
  //this will influerence the RefreshMode
  final bool refreshing, loading;

  SmartRefresher(
      {@required this.child,
      this.enablePulldownRefresh: true,
      this.enablePullUpLoad: false,
      this.headerColor: const Color(0xffdddddd),
      this.footerColor: const Color(0xffdddddd),
      this.header,
      this.refreshing,
      this.loading,
      this.onRefresh,
      this.onLoadmore,
      this.triggerDistance: 100.0,
      this.footer})
      : assert(child != null);

  @override
  _SmartRefresherState createState() => new _SmartRefresherState();
}

class _SmartRefresherState extends State<SmartRefresher>
    with TickerProviderStateMixin {
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
      _mIsDraging = false;
      _mDragPointY = null;
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
      _changeMode(notification, RefreshMode.refreshing);
    }
    _mReachMax = false;
    _mIsDraging = false;
    _mDragPointY = null;
    return false;
  }

  /**
    this will handle the Scroll Event in ListView
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

    return false;
  }

  // if your renderHeader null, it will be replaced by it
  Widget _buildDefaultHeader(BuildContext context, RefreshMode mode) {
    return new Container(
      height: 50.0,
      alignment: Alignment.center,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CupertinoActivityIndicator(),
          new Text(mode == RefreshMode.canRefresh
              ? 'Refresh when release'
              : mode == RefreshMode.completed
                  ? 'Refresh Completed'
                  : mode == RefreshMode.refreshing
                      ? 'Refreshing....'
                      : 'pull down refresh')
        ],
      ),
    );
  }

  // if your renderFooter null, it will be replaced by it
  Widget _buildDefaultFooter(BuildContext context, RefreshMode mode) {
    return new Container(
      height: 50.0,
      alignment: Alignment.center,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CupertinoActivityIndicator(),
          new Text(mode == RefreshMode.startDrag
              ? 'pull up load'
              : mode == RefreshMode.canRefresh
                  ? 'Loadmore when release'
                  : mode == RefreshMode.completed
                      ? 'Load Completed'
                      : 'LoadMore....')
        ],
      ),
    );
  }

  void _changeMode(notifi, mode) {
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

  bool _isPullUp(ScrollNotification noti) {
    return noti.metrics.extentAfter == 0;
  }

  bool _isPullDown(ScrollNotification noti) {
    return noti.metrics.extentBefore == 0;
  }

  void _dismiss(bool up) {
    /*
     why the value is 0.01? if you set the value to 0.01?
     If this value is 0, no controls will
     cause Flutter to automatically retrieve controls.
    */
    if (up) {
      if (!_mTopController.isDismissed)
        _mTopController.animateTo(0.01,
            curve: new Cubic(0.0, 0.0, 1.0, 1.0),
            duration: const Duration(milliseconds: 150));
    } else {
      if (!_mBottomController.isDismissed)
        _mBottomController.animateTo(0.01,
            curve: new Cubic(0.0, 0.0, 1.0, 1.0),
            duration: const Duration(milliseconds: 150));
    }
  }

  // This method calculates the size of the head or tail that should be resized.
  double _measureRatio(double offset) {
    return offset / widget.triggerDistance;
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
      value: 0.01,
      duration: const Duration(milliseconds: 200),
    );
    _mBottomController = new AnimationController(
      vsync: this,
      value: 0.01,
      duration: const Duration(milliseconds: 200),
    );
  }

  Widget _buildEmptySpace(controller) {
    return new SizeTransition(
        sizeFactor: controller,
        child: new Container(
          color: Colors.red,
          height: 50.0,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(builder: (context, BoxConstraints size) {
      return new OverflowBox(
        maxHeight: size.biggest.height + 100.0,
        child: new NotificationListener(
          child: new ListView(
            controller: _mScrollController,
            physics: new RefreshScrollPhysics(),
            children: <Widget>[
              _buildEmptySpace(_mTopController),
              _buildDefaultHeader(context, _mTopMode),
              widget.child,
              _buildDefaultFooter(context, _mBottomMode),
              _buildEmptySpace(_mBottomController),
            ],
          ),
          onNotification: _dispatchScrollEvent,
        ),
      );
    });
  }
}
