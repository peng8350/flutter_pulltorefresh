import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class IndicatorImpl<T> {
  T _mode;

  bool up;

  Widget buildWrapper();

  void onRefresh() {}

  bool onDragStart(ScrollStartNotification notification) {}

  bool onDragMove(ScrollUpdateNotification notification) {}

  bool onDragEnd(ScrollNotification notification) {}

  bool changeMode(T mode) {
    if (this._mode == mode) return false;
    this._mode = mode;
    return true;
  }

  get mode => this._mode;
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
      this.visibleRange,
      this.triggerDistance: 80.0})
      : assert(vsync != null) {
    _mode = RefreshMode.idle;
    this._sizeController =
        new AnimationController(vsync: vsync, lowerBound: minSpace);
  }

  @override
  bool changeMode(RefreshMode mode) {
    // TODO: implement changeMode

    if (super.changeMode(mode) && mode == RefreshMode.refreshing) {
      onRefresh();
      return true;
    }
    return false;
  }

  @override
  bool onDragMove(ScrollUpdateNotification notification) {
    // TODO: implement onDragMove
    double offset =
        notification.metrics.pixels - notification.metrics.minScrollExtent;
    print(notification.metrics.pixels - notification.metrics.maxScrollExtent);
    if (offset < -100.0) {
      return changeMode(RefreshMode.canRefresh);
    } else {
      return changeMode(RefreshMode.idle);
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
