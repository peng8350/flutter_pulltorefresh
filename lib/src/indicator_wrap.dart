/**
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 15:39
 */

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef Widget Builder(int status);

abstract class Indicator {
  ScrollController _scrollController;
  ValueNotifier<int> modeListener;

  bool up = false;

  Builder builder;


  Widget buildContent(){
    return builder(mode);
  }

  Indicator({@required this.up,this.builder}){
    modeListener = new ValueNotifier(RefreshStatus.idle);
  }

  Widget buildWrapper();

  void onRefresh() {}

  void onDragStart(ScrollStartNotification notification) {}

  void onDragMove(ScrollUpdateNotification notification) {

  }

  void onDragEnd(ScrollNotification notification) {}

  void sendStatus(int status){
      mode = status;
  }

  set scrollController(ScrollController controller) =>
      this._scrollController = controller;

  set mode(int mode) {
    if (mode == this.mode) return;
    this.modeListener.value = mode;
  }

  int get mode => this.modeListener.value;

  bool get isRefreshing => this.mode == RefreshStatus.refreshing;

  bool get isComplete => this.mode == RefreshStatus.completed || this.mode==RefreshStatus.failed;
}

class RefreshIndicator extends Indicator {
  static final double minSpace = 0.00001;

  final int completeTime;

  final double visibleRange;

  final TickerProvider vsync;

  AnimationController _sizeController;

  final double triggerDistance;

  RefreshIndicator(
      {@required this.vsync,
      this.completeTime: 800,
      this.visibleRange: 50.0,
        Builder builder,
      bool up:false,
      this.triggerDistance: 80.0})
      : assert(vsync != null,up!=null),
        super(up: up,builder:builder) {

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
      this.mode = RefreshStatus.idle;
    });
  }

  @override
  set mode(int mode) {
    // TODO: implement changeMode
    super.mode = mode;
    switch (mode) {
      case RefreshStatus.refreshing:
        if(up) {
//          _scrollController.jumpTo(-visibleRange);
        }
        _sizeController.value = 1.0;
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
          this.mode = RefreshStatus.idle;
        });
        break;
    }
  }

  @override
  void onDragEnd(ScrollNotification notification) {
    // TODO: implement onDragEnd
    if (isRefreshing||isComplete) return;
//    if (widget.refreshMode == mode) return;
//    _modeChangeCallback(true, mode);
    bool reachMax = measure(notification) >= 1.0;
    if (!reachMax) {
      _sizeController.animateTo(0.0);
      return;
    } else {
      this.mode = RefreshStatus.refreshing;
    }
  }




  @override
  void onDragMove(ScrollUpdateNotification notification) {
    // TODO: implement onDragMove
    if (isRefreshing||isComplete) return;
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
    // TODO: implement buildWrapper
    if (up) {
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
    return new Column(
      children: <Widget>[
        buildContent(),
        new SizeTransition(
          sizeFactor: _sizeController,
          child: new Container(height: visibleRange),
        )
      ],
    );
  }

}

//status: failed,nomore,completed,idle,refreshing
class LoadIndicator extends Indicator {

  final bool autoLoad;

  final bool up;

  LoadIndicator({@required this.up,Builder builder,this.autoLoad:true}):assert(up!=null),super(up:up,builder:builder);


  @override
  Widget buildWrapper() {
    // TODO: implement buildWrapper
    return buildContent();
  }

  @override
  void onDragMove(ScrollUpdateNotification notification) {
    // TODO: implement onDragMove
    if(notification.metrics.outOfRange&&autoLoad){
      this.mode = RefreshStatus.refreshing;
    }
  }


}
