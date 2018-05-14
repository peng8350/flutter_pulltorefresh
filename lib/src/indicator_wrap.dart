import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/**
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 15:39
 */
abstract class IndicatorImpl {

  ScrollController _scrollController;
  ValueNotifier<int> modeListener;

  bool up = false;

  IndicatorImpl({this.up});

  Widget buildWrapper();

  void onRefresh() {}

  void onDragStart(ScrollStartNotification notification) {
  }

  void onDragMove(ScrollUpdateNotification notification) {
  }

  void onDragEnd(ScrollNotification notification) {
  }

  set scrollController(ScrollController controller) => this._scrollController = controller;


  set mode(int mode){

  }

  int get mode => this.modeListener.value;
}

abstract class RefreshWrapper extends IndicatorImpl{
  static final double minSpace = 0.00001;

  final int completeTime;

  final double visibleRange;

  final TickerProvider vsync;

  AnimationController _sizeController;

  final double triggerDistance;

  RefreshWrapper(
      {@required this.vsync,
      this.completeTime: 800,
      this.visibleRange: 50.0,
      bool up: true,
      this.triggerDistance: 80.0})
      : assert(vsync != null),
        super(up: up) {
    modeListener = new ValueNotifier(RefreshStatus.idle);
    this._sizeController = new AnimationController(
        vsync: vsync,
        lowerBound: minSpace,
        duration: const Duration(milliseconds: 300));
  }

  /**
      up indicate drag from top (pull down)
   */
  void _dismiss() {
    /**
        why the value is 0.00001?
        If this value is 0, no controls will
        cause Flutter to automatically retrieve widget.
     */
    _sizeController.animateTo(minSpace).then((Null val) {
      this.mode =RefreshStatus.idle;
    });
  }

  @override
  set mode(int mode) {
    // TODO: implement changeMode
    if (mode == this.mode) return ;
    this.modeListener.value = mode;
    switch (mode) {
      case RefreshStatus.refreshing:
        _sizeController.value = 1.0;
        this.mode = RefreshStatus.completed;
        break;
      case RefreshStatus.completed:
        new Future.delayed(new Duration(milliseconds: completeTime), () {

          _dismiss();
        });
        break;
      case RefreshStatus.failed:
        new Future.delayed(new Duration(milliseconds: completeTime), () {
          _dismiss();
        }).then((val) {
          this.mode =RefreshStatus.idle;
        });
        break;
    }

  }

  @override
  void onDragEnd(ScrollNotification notification) {
    // TODO: implement onDragEnd
//    if (widget.refreshMode == mode) return;
    if (mode == RefreshStatus.refreshing) return ;
//    _modeChangeCallback(true, mode);
    bool reachMax = measure(notification) >= 1.0;
    if (!reachMax) {
      _sizeController.animateTo(0.0);
      return ;
    } else {
      this.mode = RefreshStatus.refreshing;
    }
  }

  bool get isRefreshing => this.mode == RefreshStatus.refreshing;

  @override
  void onDragMove(ScrollUpdateNotification notification) {
    // TODO: implement onDragMove
    if (isRefreshing) return ;
    double offset = measure(notification);
    if (offset >= 1.0) {
      this.mode = RefreshStatus.canRefresh;
    } else {
      this.mode = RefreshStatus.idle;
    }
  }

  double measure(ScrollNotification notification) {
    if (up) {
      return (notification.metrics.minScrollExtent -
              notification.metrics.pixels) /
          triggerDistance;
    } else {
      return (notification.metrics.pixels -
              notification.metrics.maxScrollExtent) /
          triggerDistance;
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

//abstract class LoadWrapper extends IndicatorImpl<LoadMode> {}
