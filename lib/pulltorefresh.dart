library pulltorefresh;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'refreshPhysics.dart';

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

  final double triggerDistance;

  final Color headerColor, footerColor;

  SmartRefresher(
      {@required this.child,
      this.enablePulldownRefresh: true,
      this.enablePullUpLoad: false,
      this.headerColor: const Color(0xffdddddd),
      this.footerColor: const Color(0xffdddddd),
      this.header,
      this.triggerDistance: 150.0,
      this.footer})
      : assert(child != null);

  @override
  _SmartRefresherState createState() => new _SmartRefresherState();
}

class _SmartRefresherState extends State<SmartRefresher>
    with TickerProviderStateMixin {
  AnimationController _topController, _bottomController;
  ScrollController _scrollController = new ScrollController();
  RefreshMode _topMode = RefreshMode.idel, _bottomMode = RefreshMode.idel;
  // the bool will check the user if dragging on the screen
  bool _isDraging,_reachMax;
  double _dragPointY;

  //handle the scrollStartEvent
  bool _handleScrollStart(ScrollStartNotification notification) {
    _isDraging = true;
    _dragPointY = notification.dragDetails.globalPosition.dy;
    _changeMode(notification, RefreshMode.startDrag);
    return false;
  }

  //handle the scrollMoveEvent
  bool _handleScrollMoving(ScrollUpdateNotification notification) {
    if (isPullUp(notification)&&_topMode!=RefreshMode.refreshing) {

      _topController.value = _measureRatio(
          notification.dragDetails.globalPosition.dy - _dragPointY);
      _reachMax = _topController.value == 1.0;
    } else if(_bottomMode!=RefreshMode.refreshing){
      _bottomController.value = _measureRatio(
          _dragPointY - notification.dragDetails.globalPosition.dy);
      _reachMax = _bottomController.value == 1.0;
    }
    if (_reachMax) {
      _changeMode(notification, RefreshMode.canRefresh);
    } else {
      _changeMode(notification, RefreshMode.startDrag);
    }
    return false;
  }

  //handle the scrollEndEvent
  bool _handleScrollEnd(ScrollUpdateNotification notification) {

    if(!_reachMax) {
      _changeMode(notification, RefreshMode.idel);
      _dismiss();
    }
    else{
      _changeMode(notification, RefreshMode.refreshing);
    }
    _isDraging = false;
    _dragPointY = 0.0;
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
      if (notification.dragDetails == null && _isDraging) {
        return _handleScrollEnd(notification);
      }
      if (notification.dragDetails != null)
        return _handleScrollMoving(notification);
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
          new Text(mode == RefreshMode.startDrag
              ? 'pull down refresh'
              : mode == RefreshMode.canRefresh
                  ? 'Refresh when release'
                  : mode == RefreshMode.completed?'Refresh Completed': 'Refreshing....')
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
              : mode == RefreshMode.completed?'Load Completed': 'LoadMore....')
        ],
      ),
    );
  }

  void _changeMode(ScrollNotification notifi, RefreshMode mode) {

    if (notifi.metrics.extentBefore == 0) {
      if (_topMode == mode) return;
      if(_topMode==RefreshMode.refreshing)return;
        setState(() {
        _topMode = mode;
      });
    } else {
      if (_bottomMode == mode) return;
      if(_bottomMode==RefreshMode.refreshing)return;
      setState(() {
        _bottomMode = mode;
      });
    }
  }

  bool isPullUp(ScrollNotification noti) {
    return noti.metrics.extentBefore == 0;
  }

  void _dismiss() {
    if (!_topController.isDismissed)
      _topController.animateTo(0.0,
          curve: new Cubic(0.0, 0.0, 1.0, 1.0),
          duration: const Duration(milliseconds: 150));
    if (!_bottomController.isDismissed)
      _bottomController.animateTo(0.0,
          curve: new Cubic(0.0, 0.0, 1.0, 1.0),
          duration: const Duration(milliseconds: 150));
  }

  // This method calculates the size of the head or tail that should be resized.
  double _measureRatio(double offset) {
    return offset.abs() / widget.triggerDistance;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _topController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bottomController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  Widget _buildEmptySpace(sizeFactor) {
    return new Container(
      child: new SizeTransition(
          sizeFactor: sizeFactor,
          child: new Container(
            height: 50.0,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(builder: (context, BoxConstraints size) {
      print(size.biggest.height);
      return new OverflowBox(
        maxHeight: size.biggest.height + 100.0,
        child: new NotificationListener(
          child: new ListView(
            controller: _scrollController,
            physics: new RefreshScrollPhysics(),
            children: <Widget>[
              _buildEmptySpace(_topController),
              _buildDefaultHeader(context, _topMode),
              widget.child,
              _buildDefaultFooter(context, _bottomMode),
              _buildEmptySpace(_bottomController),
            ],
          ),
          onNotification: _dispatchScrollEvent,
        ),
      );
    });
  }
}
