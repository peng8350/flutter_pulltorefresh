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



  Indicator({Key key, this.triggerDistance}) : super(key: key);
}

abstract class RefreshIndicator extends Indicator {
  final RefreshStyle refreshStyle;

  final double height;

  RefreshIndicator(
      {@required this.height,
      Key key,
      double triggerDistance,
      this.refreshStyle})
      : super(key: key, triggerDistance: triggerDistance);
}

abstract class LoadIndicator extends Indicator {
  final bool autoLoad;

  LoadIndicator({Key key, double triggerDistance: 15.0, this.autoLoad: true})
      : super(key: key, triggerDistance: triggerDistance);
}

abstract class RefreshIndicatorState<T extends RefreshIndicator>
    extends State<T> {
  SmartRefresherState get refresher => SmartRefresher.of(context);

  get mode => refresher.widget.controller.headerStatus;

  get offset => scrollController.offset;

  get scrollController => refresher.scrollController;

  ValueNotifier get draggingNotifier => refresher.draggingNotifier;

  bool get isDragging => draggingNotifier.value == true;

  set mode(mode) => refresher.widget.controller.headerMode.value = mode;

  bool get _isComplete =>
      mode == RefreshStatus.completed || mode == RefreshStatus.failed;

  bool get _isRefreshing => mode == RefreshStatus.refreshing;
  // if true,the indicator has a height which happen in refreshing mode
  bool hasLayout = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    draggingNotifier.addListener(() {
      // by this,it mean the user release gesture on screen
      if (!isDragging) {
        if (mode == RefreshStatus.canRefresh) {
          mode = RefreshStatus.refreshing;
        }
      }
    });
    scrollController.addListener(_handleOffsetChange);
    refresher.widget.controller.headerMode.addListener(_handleModeChange);
  }

  void _handleOffsetChange() {
    if (mounted) setState(() {});
    final overscrollPast = calculateScrollOffset(scrollController);
    if (overscrollPast <= 0.0) {
      return;
    }
    onDragMove(overscrollPast);

    onOffsetChange(overscrollPast);
  }

  double calculateScrollOffset(ScrollController controller) {
    return (hasLayout?widget.height:0.0)-scrollController.offset;
  }

  void _handleModeChange() {
    if (mounted) setState(() {});
    switch (mode) {
      case RefreshStatus.refreshing:
        hasLayout = true;
        if (refresher.widget.onRefresh != null) refresher.widget.onRefresh();
        break;
      case RefreshStatus.completed:
        endRefresh().whenComplete(() {
          hasLayout = false;
          if (mounted) setState(() {});
        });
        break;
      case RefreshStatus.failed:
        Future.delayed(Duration(milliseconds: 800), () {
          endRefresh().whenComplete(() {
            hasLayout = false;
            print(mounted);
            if (mounted) setState(() {});
          });
        });
        break;
      default:
        break;
    }
  }


  @override
  void onDragMove(double offset) {
    if(offset<=1.0){
      mode = RefreshStatus.idle;
    }
    if (_isComplete || _isRefreshing) return;
    if (offset >= widget.triggerDistance) {
      mode = RefreshStatus.canRefresh;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverRefresh(
        child: buildContent(context, mode),
        hasLayoutExtent: hasLayout,
        refreshIndicatorLayoutExtent: widget.height,
        refreshStyle: widget.refreshStyle);
  }

  Future<void> readyToRefresh() {
    return Future.delayed(Duration(milliseconds: 800));
  }

  Future<void> endRefresh() {
    return Future.delayed(Duration(milliseconds: 800));
  }

  void onOffsetChange(double offset) {
  }

  Widget buildContent(BuildContext context, RefreshStatus mode);
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
    final double overscrollPast =
        calculateScrollOffset(scrollController);
    onOffsetChange(overscrollPast);

    onDragMove();
  }

  void handleModeChange(){
    if (mounted) setState(() {});
    if(mode==LoadStatus.loading){
      if(refresher.widget.onLoading!=null){
        refresher.widget.onLoading();
      }
    }
  }

  @override
  void onDragMove() {
    if (scrollController.position.extentAfter <= widget.triggerDistance)
      mode = LoadStatus.loading;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SliverToBoxAdapter(child: buildContent(context, mode));
  }

  Widget buildContent(BuildContext context, LoadStatus mode);

  void onOffsetChange(double offset) {}
}
