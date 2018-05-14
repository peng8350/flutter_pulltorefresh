import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class IndicatorImpl<T> {
  T _mode;

  bool up=false;

  IndicatorImpl({this.up});

  Widget buildWrapper();

  void onRefresh() {}

  bool onDragStart(ScrollStartNotification notification) {
    return false;
  }

  bool onDragMove(ScrollUpdateNotification notification) {
    return false;
  }

  bool onDragEnd(ScrollNotification notification) {
    return false;
  }

  bool changeMode(T mode) {
    if (this._mode == mode) return false;
    this._mode = mode;
    return true;
  }

  T get mode => this._mode;
}

abstract class RefreshWrapper extends IndicatorImpl<RefreshMode> {
  static final double minSpace = 0.00001;

  final int completeTime;

  final double visibleRange;

  final TickerProvider vsync;

  AnimationController _sizeController;

  final double triggerDistance;

  RefreshWrapper(
      {@required this.vsync,
      this.completeTime: 800,
      this.visibleRange:50.0,
      this.triggerDistance: 80.0})
      : assert(vsync != null),super(up:true) {
    _mode = RefreshMode.idle;
    this._sizeController =
        new AnimationController(vsync: vsync, lowerBound: minSpace,duration: const Duration(milliseconds: 300));
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
      _sizeController.animateTo(minSpace).then((Null val) {

      });
    }
  }

  @override
  bool changeMode(RefreshMode mode) {
    // TODO: implement changeMode
    if(mode==_mode)return false;
    if (mode == RefreshMode.refreshing) {
      onRefresh();
    }
    this._mode = mode;
    return true;
  }

  @override
  bool onDragEnd(ScrollNotification notification) {
    // TODO: implement onDragEnd
//    if (widget.refreshMode == mode) return;
    if (mode == RefreshMode.refreshing) return false;
//    _modeChangeCallback(true, mode);
    bool reachMax = measure(notification)>=1.0;
    if(!reachMax) {
        _sizeController.animateTo(0.0);
      return false;
    }
    else{
      _sizeController.animateTo(1.0);
      changeMode(RefreshMode.refreshing);
      return true;
    }
    return false;
  }

  @override
  bool onDragMove(ScrollUpdateNotification notification) {
    // TODO: implement onDragMove
    double offset =
        measure(notification);
    if (offset >=1.0) {
      return changeMode(RefreshMode.canRefresh);

    } else {
      return changeMode(RefreshMode.idle);
    }
  }


  double measure(ScrollNotification notification){
    if(up){
      return (notification.metrics.minScrollExtent-notification.metrics.pixels)/triggerDistance;
    }
    else{
      return (notification.metrics.pixels-notification.metrics.maxScrollExtent)/triggerDistance;
    }
  }

  @override
  Widget buildWrapper() {
    //注意这里要判断up的情况
    // TODO: implement buildWrapper
    return new Column(
      children: <Widget>[
        new SizeTransition(
          sizeFactor: _sizeController,
          child: new Container(height: visibleRange),
        ),
        buildContent()
      ],
    );
  }

  Widget buildContent();
}

abstract class LoadWrapper extends IndicatorImpl<LoadMode> {}

class NormalIndicator extends RefreshWrapper {

  AnimationController rorateController;

  NormalIndicator(
      {@required TickerProvider vsync,
      int completeTime: 800,
      double visibleRange:50.0,
      double triggerDistance: 80.0})
      : super(
            vsync: vsync,
            completeTime: completeTime,
            visibleRange: visibleRange,
            triggerDistance: triggerDistance) {
    rorateController = new AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 100));
  }

  @override
  bool onDragMove(ScrollUpdateNotification notification) {
    // TODO: implement onDragMove
    double offset = measure(notification);
    rorateController.value = offset;
    return super.onDragMove(notification);


  }

  @override
  Widget buildContent() {
    // TODO: implement buildContent
    return new Container(
      height: 50.0,
      alignment: Alignment.center,
      child: new Center(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            mode == RefreshMode.refreshing
                ? new SizedBox(
              width: 25.0,
              height: 25.0,
              child: const CircularProgressIndicator(strokeWidth: 2.0),
            )
                : mode == RefreshMode.completed
                ? const Icon(Icons.done, color: Colors.grey)
                : mode == RefreshMode.failed
                ? const Icon(Icons.clear, color: Colors.grey)
                : new RotationTransition(
                turns: rorateController,
                child: const Icon(Icons.arrow_downward,
                    color: Colors.grey)),
            new Container(
              child: new Text(
                mode == RefreshMode.canRefresh
                    ? 'Refresh when release'
                    : mode == RefreshMode.completed
                    ? 'Refresh Completed'
                    : mode == RefreshMode.failed
                    ? 'Refresh Failed'
                    : mode == RefreshMode.refreshing
                    ? 'Refreshing....'
                    : 'pull down refresh',
                style: new TextStyle(color: const Color(0xff555555)),
              ),
              margin: const EdgeInsets.only(left: 10.0),
            )
          ],
        ),
      ),
    );
  }
}
