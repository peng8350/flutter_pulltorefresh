/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 15:39
 */

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'default_constants.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class Wrapper extends StatefulWidget {
  final ValueNotifier<int> modeListener;

  final IndicatorBuilder builder;

  final bool up;

  final double triggerDistance;

  bool get _isRefreshing => this.mode == RefreshStatus.refreshing;

  bool get _isComplete =>
      this.mode != RefreshStatus.idle &&
      this.mode != RefreshStatus.refreshing &&
      this.mode != RefreshStatus.canRefresh;

  int get mode => this.modeListener.value;

  set mode(int mode) => this.modeListener.value = mode;

  Wrapper(
      {Key key,
      @required this.up,
      @required this.modeListener,
      this.builder,
      this.triggerDistance})
      : assert(up != null, modeListener != null),
        super(key: key);

  bool _isScrollToOutSide(ScrollNotification notification) {
    if (up) {
      if (notification.metrics.minScrollExtent - notification.metrics.pixels >
          0) {
        return true;
      }
    } else {
      if (notification.metrics.pixels - notification.metrics.maxScrollExtent >
          0) {
        return true;
      }
    }
    return false;
  }
}

//idle,refreshing,completed,failed,canRefresh
class RefreshWrapper extends Wrapper {
  final int completeDuration;

  final Function onOffsetChange;

  final double visibleRange;

  RefreshWrapper({
    Key key,
    IndicatorBuilder builder,
    ValueNotifier<int> modeLis,
    this.onOffsetChange,
    this.completeDuration: default_completeDuration,
    double triggerDistance,
    this.visibleRange: default_VisibleRange,
    bool up: true,
  })  : assert(up != null),
        super(
          up: up,
          key: key,
          modeListener: modeLis,
          builder: builder,
          triggerDistance: triggerDistance,
        );

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new RefreshWrapperState();
  }
}

class RefreshWrapperState extends State<RefreshWrapper>
    with TickerProviderStateMixin
    implements GestureProcessor {
  AnimationController _sizeController;

  /*
      up indicate drag from top (pull down)
   */
  void _dismiss() {
    /*
        why the value is 0.00001?
        If this value is 0, no controls will
        cause Flutter to automatically retrieve widget.
     */
    _sizeController.animateTo(minSpace).then((var _) {
      widget.mode = RefreshStatus.idle;
    });
  }

  int get mode => widget.modeListener.value;

  double _measure(ScrollNotification notification) {
    if (widget.up) {
      return (notification.metrics.minScrollExtent -
              notification.metrics.pixels) /
          widget.triggerDistance;
    } else {
      return (notification.metrics.pixels -
              notification.metrics.maxScrollExtent) /
          widget.triggerDistance;
    }
  }

  @override
  void onDragStart(ScrollStartNotification notification) {
    // TODO: implement onDragStart
  }

  @override
  void onDragMove(ScrollUpdateNotification notification) {
    // TODO: implement onDragMove
    if (!widget._isScrollToOutSide(notification)) {
      return;
    }
    if (widget._isComplete || widget._isRefreshing) return;

    double offset = _measure(notification);
    if (offset >= 1.0) {
      widget.mode = RefreshStatus.canRefresh;
    } else {
      widget.mode = RefreshStatus.idle;
    }
  }

  @override
  void onDragEnd(ScrollNotification notification) {
    // TODO: implement onDragEnd
    if (!widget._isScrollToOutSide(notification)) {
      return;
    }
    if (widget._isComplete || widget._isRefreshing) return;
    bool reachMax = _measure(notification) >= 1.0;
    if (!reachMax) {
      _sizeController.animateTo(0.0);
      return;
    } else {
      widget.mode = RefreshStatus.refreshing;
    }
  }

  void _handleOffsetCallBack() {
    if (widget.onOffsetChange != null) {
      widget.onOffsetChange(
          widget.up, _sizeController.value * widget.visibleRange);
    }
  }

  void _handleModeChange() {
    switch (mode) {
      case RefreshStatus.refreshing:
        _sizeController.value = 1.0;
        break;
      case RefreshStatus.completed:
        new Future.delayed(new Duration(milliseconds: widget.completeDuration),
            () {
          _dismiss();
        });
        break;
      case RefreshStatus.failed:
        new Future.delayed(new Duration(milliseconds: widget.completeDuration),
            () {
          _dismiss();
        }).then((val) {
          widget.mode = RefreshStatus.idle;
        });
        break;
    }
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    widget.modeListener.removeListener(_handleModeChange);
    _sizeController.removeListener(_handleOffsetCallBack);
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this._sizeController = new AnimationController(
        vsync: this,
        lowerBound: minSpace,
        duration: const Duration(milliseconds: spaceAnimateMill))
      ..addListener(_handleOffsetCallBack);
    widget.modeListener.addListener(_handleModeChange);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (widget.up) {
      return new Column(
        children: <Widget>[
          new SizeTransition(
            sizeFactor: _sizeController,
            child: new Container(height: widget.visibleRange),
          ),
          widget.builder(context, widget.mode)
        ],
      );
    }
    return new Column(
      children: <Widget>[
        widget.builder(context, widget.mode),
        new SizeTransition(
          sizeFactor: _sizeController,
          child: new Container(height: widget.visibleRange),
        )
      ],
    );
  }
}

//status: failed,nomore,idle,refreshing
class LoadWrapper extends Wrapper {
  final bool autoLoad;

  LoadWrapper(
      {Key key,
      @required bool up,
      @required ValueNotifier<int> modeListener,
      double triggerDistance,
      this.autoLoad,
      IndicatorBuilder builder})
      : assert(up != null, modeListener != null),
        super(
          key: key,
          up: up,
          builder: builder,
          modeListener: modeListener,
          triggerDistance: triggerDistance,
        );

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new LoadWrapperState();
  }
}

class LoadWrapperState extends State<LoadWrapper> implements GestureProcessor {
  Function _updateListener;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return widget.builder(context, widget.mode);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _updateListener = () {
      setState(() {});
    };
    widget.modeListener.addListener(_updateListener);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    widget.modeListener.removeListener(_updateListener);
    super.dispose();
  }

  @override
  void onDragStart(ScrollStartNotification notification) {
    // TODO: implement onDragStart
  }

  @override
  void onDragMove(ScrollUpdateNotification notification) {
    // TODO: implement onDragMove
//    if (!widget._isScrollToOutSide(notification)) {
//      return;
//    }
    if (widget._isRefreshing || widget._isComplete) return;
    if (widget.autoLoad) {
      if (widget.up &&
          notification.metrics.extentBefore <= widget.triggerDistance)
        widget.mode = RefreshStatus.refreshing;
      if (!widget.up &&
          notification.metrics.extentAfter <= widget.triggerDistance)
        widget.mode = RefreshStatus.refreshing;
    }
  }

  @override
  void onDragEnd(ScrollNotification notification) {
    // TODO: implement onDragEnd
    if (widget._isRefreshing || widget._isComplete) return;
    if (widget.autoLoad) {
      if (widget.up &&
          notification.metrics.extentBefore <= widget.triggerDistance)
        widget.mode = RefreshStatus.refreshing;
      if (!widget.up &&
          notification.metrics.extentAfter <= widget.triggerDistance)
        widget.mode = RefreshStatus.refreshing;
    }
  }
}

abstract class GestureProcessor {
  void onDragStart(ScrollStartNotification notification);

  void onDragMove(ScrollUpdateNotification notification);

  void onDragEnd(ScrollNotification notification);
}
