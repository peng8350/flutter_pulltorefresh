/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 15:39
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'default_constants.dart';
import 'dart:math' as math;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'slivers.dart';

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

  final bool hideWhenNotFull;

  const LoadIndicator(
      {Key key,
      double triggerDistance: 15.0,
      this.autoLoad: true,
      this.hideWhenNotFull: true,
      this.onClick})
      : super(key: key, triggerDistance: triggerDistance);
}

abstract class RefreshIndicatorState<T extends RefreshIndicator>
    extends State<T> {
  SmartRefresherState get refresher => SmartRefresher.of(context);

  get mode => refresher?.widget?.controller?.headerStatus;

  set mode(mode) => _headerMode?.value = mode;

  // if true,the indicator has a height which happen in refreshing mode
  set floating(floating) => refresher?.hasHeaderLayout?.value = floating;

  bool get floating => refresher?.hasHeaderLayout?.value;

  ScrollController _scrollController;

  ValueNotifier<RefreshStatus> _headerMode;

  void _handleOffsetChange() {
    if (!mounted) {
      return;
    }
    final overscrollPast = calculateScrollOffset(_scrollController);
    if (overscrollPast < 0.0) {
      return;
    }
    if (refresher.widget.onOffsetChange != null) {
      refresher.widget.onOffsetChange(true, overscrollPast);
    }
    handleDragMove(overscrollPast);

    onOffsetChange(overscrollPast);
  }

  double calculateScrollOffset(ScrollController controller) {
    if (widget.refreshStyle == RefreshStyle.Front) {
      return widget.height - controller.position.extentBefore;
    }
    return (floating ? widget.height : 0.0) - _scrollController.offset;
  }

  void update() {
    if (mounted) setState(() {});
  }

  // handle the  state change between canRefresh and idle canRefresh  before refreshing
  void handleDragMove(double offset) {
    if (floating) return;
    if (_scrollController.position.activity.velocity == 0.0) {
      if (offset >= widget.triggerDistance) {
        mode = RefreshStatus.canRefresh;
      } else {
        mode = RefreshStatus.idle;
      }
    } else if (RefreshStatus.canRefresh == mode) {
      floating = true;
      update();
      readyToRefresh().then((_) {
        mode = RefreshStatus.refreshing;
      });
    }
  }

  void handleModeChange() {
    if (!mounted) {
      return;
    }

    update();
    if (mode == RefreshStatus.completed || mode == RefreshStatus.failed) {
      endRefresh().then((_) {
        floating = false;
        update();
        if(widget.refreshStyle==RefreshStyle.Front){
          mode= RefreshStatus.idle;
        }
        // make gesture release
        if (widget.refreshStyle != RefreshStyle.Front)
          (_scrollController.position as ScrollActivityDelegate).goIdle();
      });
    } else if (mode == RefreshStatus.refreshing) {
      floating = true;
      update();
      if (refresher.widget.onRefresh != null) refresher.widget.onRefresh();
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
  void dispose() {
    // TODO: implement dispose
    _scrollController.removeListener(_handleOffsetChange);
    _headerMode.removeListener(handleModeChange);
    _headerMode = null;
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState

    _scrollController = refresher.scrollController;

    _headerMode = refresher.widget.controller.headerMode;
    // it is necessary,sometime the widget may be dispose ,it should be resume the state
    _headerMode.value = RefreshStatus.idle;
    floating = false;

    if (refresher.widget.enablePullDown) {
      _scrollController.addListener(_handleOffsetChange);
      _headerMode.addListener(handleModeChange);
    }
    super.initState();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    // TODO: implement didUpdateWidget
    // needn't to update _headerMode,because it's state will never change
    _scrollController.removeListener(_handleOffsetChange);
    _scrollController = refresher.scrollController;
    if (refresher.widget.enablePullDown) {
      _scrollController.addListener(_handleOffsetChange);
    }
    super.didUpdateWidget(oldWidget);
  }
}

abstract class LoadIndicatorState<T extends LoadIndicator> extends State<T> {
  SmartRefresherState get refresher => SmartRefresher.of(context);

  LoadStatus get mode => refresher.widget.controller.footerStatus;

  double get offset => refresher.widget.controller.scrollController.offset;

  set mode(mode) => _footerMode.value = mode;

  bool get _isRefreshing =>
      refresher.widget.controller.footerMode.value == LoadStatus.loading;

  ScrollController _scrollController;

  ValueNotifier<LoadStatus> _footerMode;
  // use to update between one page and above one page
  ValueNotifier<bool> _enableLayout = ValueNotifier(null);

  double calculateScrollOffset(ScrollController controller) {
    final double overscrollPastEnd = math.max(
        controller.position.pixels - controller.position.maxScrollExtent, 0.0);
    return overscrollPastEnd;
  }

  void _handleVisiable() {
    if (_enableLayout.value ||!widget.hideWhenNotFull) {
      _footerMode.addListener(handleModeChange);
      _scrollController.addListener(_handleOffsetChange);
    } else  {
      _footerMode.removeListener(handleModeChange);
      _scrollController.removeListener(_handleOffsetChange);
    }
  }

  void _handleOffsetChange() {
    if (!mounted) {
      return;
    }
    final double overscrollPast = calculateScrollOffset(_scrollController);
    if (refresher.widget.onOffsetChange != null &&
        _scrollController.position.extentAfter == 0.0) {
      refresher.widget.onOffsetChange(false, overscrollPast);
    }
    handleDragMove();
    onOffsetChange(overscrollPast);
  }

  void update() {
    if (mounted) {
      setState(() {});
    }
  }

  void handleModeChange() {
    if (!mounted) {
      return;
    }
    update();
    if (mode == LoadStatus.loading) {
      if (refresher.widget.onLoading != null) {
        refresher.widget.onLoading();
      }
    }
  }

  void handleDragMove() {
    if (_scrollController.position.userScrollDirection.index==2&&_scrollController.position.extentAfter <= widget.triggerDistance &&
        widget.autoLoad &&
        mode == LoadStatus.idle) mode = LoadStatus.loading;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = refresher.widget.controller.scrollController;

    _footerMode = refresher.widget.controller.footerMode;
    // it is necessary
    _footerMode.value = LoadStatus.idle;

    _enableLayout.addListener(_handleVisiable);
  }

  @override
  void didUpdateWidget(T oldWidget) {
    // TODO: implement didUpdateWidget
    // there is no need to update _footerMode,it will not change
    _scrollController = refresher.widget.controller.scrollController;
    _scrollController.removeListener(_handleOffsetChange);
    if (refresher.widget.enablePullUp && _enableLayout.value) {
      _scrollController.addListener(_handleOffsetChange);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.removeListener(_handleOffsetChange);
    _footerMode.removeListener(handleModeChange);
    _enableLayout.removeListener(_handleVisiable);
    _enableLayout.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SliverLoading(
        enableLayout: _enableLayout,
        hideWhenNotFull: widget.hideWhenNotFull,
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

  void onOffsetChange(double offset) {}
}
