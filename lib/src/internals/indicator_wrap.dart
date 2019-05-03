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
import 'refreshsliver.dart';

abstract class Wrapper extends StatefulWidget {
  final  modeListener;

  final  builder;

  final double triggerDistance;

  bool get _isRefreshing => this.mode == RefreshStatus.refreshing;

  bool get _isComplete =>
      this.mode != RefreshStatus.idle &&
      this.mode != RefreshStatus.refreshing &&
      this.mode != RefreshStatus.canRefresh;

  get mode => this.modeListener.value;

  set mode(mode) => this.modeListener.value = mode;

  Wrapper(
      {Key key,
      @required this.modeListener,
      this.builder,
      this.triggerDistance})
      : assert(modeListener != null),
        super(key: key);
}

class RefreshWrapper extends Wrapper {
  final int completeDuration;

  final double height;

  final RefreshStyle refreshStyle;

  RefreshWrapper({
    Key key,
    HeaderBuilder builder,
    ValueNotifier<RefreshStatus> modeLis,
    this.refreshStyle,
    this.completeDuration: default_completeDuration,
    double triggerDistance: default_refresh_triggerDistance,
    this.height: default_height,
  }) : super(
          key: key,
          modeListener: modeLis,
          builder: builder,
          triggerDistance: triggerDistance,
        );

  @override
  State<StatefulWidget> createState() {
    return RefreshWrapperState();
  }
}

class RefreshWrapperState extends State<RefreshWrapper>
    with TickerProviderStateMixin
    implements GestureProcessor {
  bool _hasLayout = false;

  RefreshStatus get mode => widget.modeListener.value;

  double _measure(ScrollNotification notification) {
    return (notification.metrics.minScrollExtent -
            notification.metrics.pixels) /
        widget.triggerDistance;
  }

  @override
  void onDragMove(ScrollUpdateNotification notification) {
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
    if (widget._isComplete || widget._isRefreshing) return;

    bool reachMax = _measure(notification) >= 1.0;
    if (reachMax) {
      widget.mode = RefreshStatus.refreshing;
    }
  }

  void _handleModeChange() {
    setState(() {});
    switch (mode) {
      case RefreshStatus.refreshing:
        _hasLayout = true;
        break;
      case RefreshStatus.completed:
        Future.delayed(Duration(milliseconds: widget.completeDuration), () {
          _hasLayout = false;
          widget.mode = RefreshStatus.idle;
          setState(() {});
        });
        break;
      case RefreshStatus.failed:
        Future.delayed(Duration(milliseconds: widget.completeDuration), () {
          _hasLayout = false;

          widget.mode = RefreshStatus.idle;
          setState(() {});
        });
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    widget.modeListener.addListener(_handleModeChange);
  }

  @override
  Widget build(BuildContext context) {
    return SliverRefresh(
      hasLayoutExtent: _hasLayout,
      refreshIndicatorLayoutExtent: widget.height,
      refreshStyle: widget.refreshStyle,
      child: widget.builder(context, widget.mode),
    );
  }
}

class LoadWrapper extends Wrapper {
  final bool autoLoad;

  LoadWrapper(
      {Key key,
      @required ValueNotifier<LoadStatus> modeListener,
      double triggerDistance: default_load_triggerDistance,
      this.autoLoad,
      FooterBuilder builder})
      : assert(modeListener != null),
        super(
          key: key,
          builder: builder,
          modeListener: modeListener,
          triggerDistance: triggerDistance,
        );

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoadWrapperState();
  }
}

class LoadWrapperState extends State<LoadWrapper> implements GestureProcessor {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: widget.builder(context, widget.mode));
  }

  @override
  void initState() {
    super.initState();
    widget.modeListener.addListener(() {
      setState(() {});
    });
  }

  @override
  void onDragMove(ScrollUpdateNotification notification) {
    if (notification.metrics.extentAfter <= widget.triggerDistance &&
        notification.scrollDelta > 1.0) widget.mode = LoadStatus.loading;
  }

  @override
  void onDragEnd(ScrollNotification notification) {
    if (widget._isRefreshing || widget._isComplete) return;
    if (widget.autoLoad) {
      if (notification.metrics.extentAfter <= widget.triggerDistance)
        widget.mode = LoadStatus.loading;
    }
  }
}

abstract class GestureProcessor {
  void onDragMove(ScrollUpdateNotification notification);

  void onDragEnd(ScrollNotification notification);
}
