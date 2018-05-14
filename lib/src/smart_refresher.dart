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
import 'package:pull_to_refresh/src/indicator_wrap.dart';
import 'package:pull_to_refresh/src/refresh_physics.dart';

typedef void OnRefreshChange(RefreshStatus mode);
typedef void OnLoadChange(RefreshStatus mode);
typedef void OnOffsetChange(bool isUp, double offset);
typedef Widget HeaderBuilder(BuildContext context, RefreshStatus mode);
typedef Widget FooterBuilder(BuildContext context, RefreshStatus mode);


class RefreshStatus{

  static const int idle=0;
  static const int canRefresh=1;
  static const int refreshing=2;
  static const int completed =3;
  static const int failed=4;
  static const int noMore=5;

}


/**
    This is the most important component that provides drop-down refresh and up loading.
 */
class SmartRefresher extends StatefulWidget {
  //indicate your listView
  final Widget child;

  final IndicatorImpl header;
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
  final RefreshStatus refreshMode,loadMode;
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
    this.header,
    this.enablePullDownRefresh: true,
    this.enablePullUpLoad: false,
    this.enableAutoLoadMore: true,
    this.headerBuilder,
    this.footerBuilder,
    this.topVisibleRange: 50.0,
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
  bool _mIsDraging = false;
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
//    if (notification.metrics.outOfRange &&
//        _mDragPointY == null &&
//        (_isPullUp(notification) || _isPullDown(notification)))
//      _mDragPointY = _mScrollController.offset;
//    if (_isPullUp(notification))
//      _changeMode(notification, RefreshStatus.startDrag);
    return false;
  }

  //handle the scrollMoveEvent
  bool _handleScrollMoving(ScrollUpdateNotification notification) {
    bool down = _isPullDown(notification);
    if (down) {
//      if (widget.onOffsetChange != null)
//        widget.onOffsetChange(notification.metrics.extentBefore == 0, offset);
    }
    widget.header.onDragMove(notification);

    return false;
  }

  //handle the scrollEndEvent
  bool _handleScrollEnd(ScrollNotification notification) {
//    bool up = _isPullDown(notification);
//    if (!_mReachMax) {
//      _changeMode(notification, up ? RefreshMode.idle : LoadMode.idle);
////      _dismiss(up ? up : false);
//    } else {
//      if (up) {
//        _modeChangeCallback(true, RefreshMode.refreshing);
//      } else {
//        _modeChangeCallback(false, LoadMode.loading);
//      }
//    }
    widget.header.onDragEnd(notification);
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
//    if ((down &&
//            (widget.refreshMode == RefreshMode.refreshing ||
//                widget.refreshMode == RefreshMode.failed ||
//                widget.refreshMode == RefreshMode.completed)) ||
//        (up && (widget.loadMode == LoadMode.loading))) {
//      return false;
//    }
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
    widget.header.scrollController = _mScrollController;
    widget.header.modeListener.addListener((){
      setState(() {
      });
    });
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
                        new Container(
                          key: _mHeaderKey,
                          child: widget.header.buildWrapper(),
                        )
                        ,
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
