/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 15:39
 */

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'default_constants.dart';
import 'dart:math' as math;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'refreshsliver.dart';

abstract class Indicator extends StatefulWidget {
  final double triggerDistance;

  const Indicator({Key key, this.triggerDistance}) : super(key: key);
}

abstract class RefreshIndicator extends Indicator {
  final RefreshStyle refreshStyle;

  final double height;

  const RefreshIndicator(
      {this.height: default_height,
      Key key,
      double triggerDistance: 100.0,
      this.refreshStyle: RefreshStyle.Follow})
      : super(key: key, triggerDistance: triggerDistance);
}

abstract class LoadIndicator extends Indicator {
  final bool autoLoad;

  final Function onClick;

  const LoadIndicator(
      {Key key,
      double triggerDistance: 15.0,
      this.autoLoad: true,
      this.onClick})
      : super(key: key, triggerDistance: triggerDistance);
}

abstract class RefreshIndicatorState<T extends RefreshIndicator>
    extends State<T> {
  SmartRefresherState get refresher => SmartRefresher.of(context);

  get mode => refresher?.widget?.controller?.headerStatus;

  get scrollController => refresher?.scrollController;

  bool get isDragging => refresher.isDragging;

  set mode(mode) => refresher?.widget?.controller?.headerMode?.value = mode;

  bool get _isComplete =>
      mode == RefreshStatus.completed || mode == RefreshStatus.failed;

  bool get _isRefreshing => mode == RefreshStatus.refreshing;
  // if true,the indicator has a height which happen in refreshing mode
  bool floating = false;

  void _handleOffsetChange() {
    final overscrollPast = calculateScrollOffset(scrollController);

    if (overscrollPast < 0.0) {
      return;
    }
    handleDragMove(overscrollPast);

    onOffsetChange(overscrollPast);
  }

  double calculateScrollOffset(ScrollController controller) {
    return (floating ? widget.height : 0.0) - scrollController.offset;
  }

  void update() {
    if (mounted) setState(() {});
  }

  // handle the  state change between canRefresh and idle canRefresh  before refreshing
  void handleDragMove(double offset) {
    if (_isComplete || _isRefreshing) return;

    if (floating) return;

    if (!isDragging && RefreshStatus.canRefresh == mode) {
      floating = true;
      update();
      readyToRefresh().then((_) {
        mode = RefreshStatus.refreshing;
      });
    }
    if (isDragging) {
      if (offset >= widget.triggerDistance) {
        mode = RefreshStatus.canRefresh;
      } else {
        mode = RefreshStatus.idle;
      }
    }
  }

  //
  void handleModeChange() {
    update();
    switch (mode) {
      case RefreshStatus.refreshing:
        floating = true;
        update();
        readyToRefresh().then((_) {
          if (refresher.widget.onRefresh != null) refresher.widget.onRefresh();
        });
        break;
      case RefreshStatus.completed:
        endRefresh().then((_) {
          floating = false;
          update();

          return Future.delayed(Duration(milliseconds: 150));
        }).whenComplete(() {
          mode = RefreshStatus.idle;
        });

        break;
      case RefreshStatus.failed:
        endRefresh().then((_) {
          floating = false;
          update();
          return Future.delayed(Duration(milliseconds: 150));
        }).whenComplete(() {
          mode = RefreshStatus.idle;
        });
        break;
      default:
        break;
    }
  }

  // the method can provide a callback to implements some animation
  Future<void> readyToRefresh() {
    return Future.value();
  }

  // it mean the state will enter success or fail
  Future<void> endRefresh() {
    return Future.delayed(Duration(milliseconds: 800));
  }

  void onOffsetChange(double offset) {
    update();
  }

  // indicator render layout
  Widget buildContent(BuildContext context, RefreshStatus mode);

  @override
  Widget build(BuildContext context) {
    return SliverRefresh(
        child: buildContent(context, mode),
        floating: floating,
        refreshIndicatorLayoutExtent: widget.height,
        refreshStyle: widget.refreshStyle);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    scrollController.addListener(_handleOffsetChange);
    refresher.widget.controller.headerMode.addListener(handleModeChange);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }
}

abstract class LoadIndicatorState<T extends LoadIndicator> extends State<T> {
  SmartRefresherState get refresher => SmartRefresher.of(context);

  LoadStatus get mode => refresher.widget.controller.footerStatus;

  double get offset => refresher.widget.controller.scrollController.offset;

  ScrollController get scrollController =>
      refresher.widget.controller.scrollController;

  set mode(mode) => refresher.widget.controller.footerMode.value = mode;

  bool get _isRefreshing =>
      refresher.widget.controller.footerMode.value == LoadStatus.loading;

  @override
  void initState() {
    super.initState();
    refresher.widget.controller.footerMode.addListener(handleModeChange);
    scrollController.addListener(_handleOffsetChange);
  }

  double calculateScrollOffset(ScrollController controller) {
    final double overscrollPastStart = math.max(
        controller.position.minScrollExtent - controller.position.pixels, 0.0);
    final double overscrollPastEnd = math.max(
        controller.position.pixels - controller.position.maxScrollExtent, 0.0);
    return math.max(overscrollPastStart, overscrollPastEnd);
  }

  void _handleOffsetChange() {
    final double overscrollPast = calculateScrollOffset(scrollController);
    handleDragMove();
    onOffsetChange(overscrollPast);

  }

  void update() {
    if (mounted) {
      setState(() {});
    }
  }

  void handleModeChange() {
    update();
    if (mode == LoadStatus.loading) {
      if (refresher.widget.onLoading != null) {
        refresher.widget.onLoading();
      }
    }
  }

  void handleDragMove() {
    if (scrollController.position.extentAfter <= widget.triggerDistance&&widget.autoLoad)
      mode = LoadStatus.loading;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SliverToBoxAdapter(
        child: GestureDetector(
      onTap: () {
        if (widget.onClick != null) {
          widget.onClick();
        }
      },
      child: buildContent(context, mode),
    ));
  }

  Widget buildContent(BuildContext context, LoadStatus mode);

  void onOffsetChange(double offset) {

  }
}
