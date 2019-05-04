/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-01 11:39
 */

import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'internals/default_constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:pull_to_refresh/src/internals/indicator_wrap.dart';
import 'package:pull_to_refresh/src/internals/refresh_physics.dart';
import 'indicator/classic_indicator.dart';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';

enum RefreshStatus { idle, canRefresh, refreshing, completed, failed }

enum LoadStatus { idle, loading, noMore }

enum RefreshStyle { Follow, UnFollow, Behind, Front }

/*
    This is the most important component that provides drop-down refresh and up loading.
 */
class SmartRefresher extends StatefulWidget {
  //indicate your listView
  final ScrollView child;

  final RefreshIndicator header;
  final LoadIndicator footer;
  // This bool will affect whether or not to have the function of drop-up load.
  final bool enablePullUp;
  //This bool will affect whether or not to have the function of drop-down refresh.
  final bool enablePullDown;
  // if open OverScroll if you use RefreshIndicator and LoadFooter
  final bool enableOverScroll;
  // upper and downer callback when you drag out of the distance
  final Function onRefresh, onLoading;
  // This method will callback when the indicator changes from edge to edge.
  final OnOffsetChange onOffsetChange;
  //controll inner state
  final RefreshController controller;
  // When SmartRefresher is wrapped in some ScrollView,if true:it will find the primaryScrollController in parent widget
  final bool isNestWrapped;

  SmartRefresher(
      {Key key,
      @required this.child,
      @required this.controller,
      RefreshIndicator header,
      LoadIndicator footer,
      this.enableOverScroll: default_enableOverScroll,
      this.enablePullDown: default_enablePullDown,
      this.enablePullUp: default_enablePullUp,
      this.onRefresh,
      this.onLoading,
      this.onOffsetChange,
      this.isNestWrapped: false})
      : assert(child != null),
        assert(controller != null),
        this.header = header ?? ClassicHeader(),
        this.footer = footer ?? ClassicFooter(),
        super(key: key);

  @override
  SmartRefresherState createState() => SmartRefresherState();

  static SmartRefresherState of(BuildContext context) {
    return context
        .ancestorStateOfType(const TypeMatcher<SmartRefresherState>());
  }
}

class SmartRefresherState extends State<SmartRefresher> {
  // listen the listen offset or on...
  ScrollController scrollController;
  // check if user is dragging
  ValueNotifier<bool> draggingNotifier = ValueNotifier(false);

  //handle the scrollStartvent
  bool _handleScrollStart(ScrollNotification notification) {
    draggingNotifier.value = true;
    return false;
  }

  //handle the scrollEndEvent
  bool _handleScrollEnd(ScrollNotification notification) {
    draggingNotifier.value = false;
    return false;
  }

  bool _dispatchScrollEvent(ScrollNotification notification) {
    // ignore the nested scrollview's notification

    if (notification.depth != 0) {
      return false;
    }
    if (notification is ScrollStartNotification) {
      _handleScrollStart(notification);
    }
    if (notification is ScrollUpdateNotification &&
        notification.dragDetails == null) {
      _handleScrollEnd(notification);
    }

    return false;
  }

  void _handleOffsetCallback() {
    final double overscrollPastStart = math.max(
        scrollController.position.minScrollExtent -
            scrollController.position.pixels,
        0.0);
    final double overscrollPastEnd = math.max(
        scrollController.position.pixels -
            scrollController.position.maxScrollExtent,
        0.0);
    if (overscrollPastStart > overscrollPastEnd) {
      if (widget.onOffsetChange != null) {
        widget.onOffsetChange(
            true,
            overscrollPastStart +
                ((RefreshStatus.refreshing ==
                        widget.controller.headerMode.value)
                    ? widget.header.height
                    : 0.0));
      }
    } else if (overscrollPastEnd > 0) {
      if (widget.onOffsetChange != null) {
        widget.onOffsetChange(false, overscrollPastEnd);
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    scrollController.removeListener(_handleOffsetCallback);
    if (!widget.isNestWrapped && widget.child.controller == null) {
      scrollController.dispose();
    }

    widget.controller.headerMode.dispose();
    widget.controller.footerMode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (widget.isNestWrapped) {
      scrollController = PrimaryScrollController.of(context);
    } else {
      scrollController = widget.child.controller ?? ScrollController();
    }
    widget.controller.scrollController = scrollController;
    scrollController.addListener(_handleOffsetCallback);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(SmartRefresher oldWidget) {
    // TODO: implement didUpdateWidget
    scrollController.removeListener(_handleOffsetCallback);

    if (!widget.isNestWrapped && widget.child.controller != null) {
      scrollController = widget.child.controller;
    }
    if (widget.isNestWrapped) {
      scrollController = PrimaryScrollController.of(context);
    }

    scrollController.addListener(_handleOffsetCallback);
    widget.controller.scrollController = scrollController;

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> slivers =
        List.from(widget.child.buildSlivers(context), growable: true);
    slivers.insert(0, widget.header);
    slivers.add(widget.footer);
    return NotificationListener(
      child: CustomScrollView(
        physics:
            RefreshScrollPhysics(enableOverScroll: widget.enableOverScroll),
        controller: scrollController,
        cacheExtent: widget.child.cacheExtent,
        slivers: slivers,
        reverse: widget.child.reverse,
      ),
      onNotification: _dispatchScrollEvent,
    );
  }
}

class RefreshController {
  ValueNotifier<RefreshStatus> headerMode = ValueNotifier(RefreshStatus.idle);
  ValueNotifier<LoadStatus> footerMode = ValueNotifier(LoadStatus.idle);
  ScrollController scrollController;

  void requestRefresh(bool up) {
    assert(scrollController != null,
        'Try not to call requestRefresh() before build,please call after the ui was rendered');
    if (up) {
      if (headerMode.value == RefreshStatus.idle)
        headerMode.value = RefreshStatus.refreshing;
      scrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 200), curve: Curves.linear);
    } else {
      if (footerMode.value == LoadStatus.idle) {
        footerMode.value = LoadStatus.loading;
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.linear);
      }
    }
  }

  void refreshCompleted() {
    headerMode.value = RefreshStatus.completed;
  }

  void refreshFailed() {
    headerMode.value = RefreshStatus.failed;
  }

  void loadComplete() {
    footerMode.value = LoadStatus.idle;
  }

  void loadNoData() {
    footerMode.value = LoadStatus.noMore;
  }

  RefreshStatus get headerStatus => headerMode.value;

  LoadStatus get footerStatus => footerMode.value;

  isRefresh(bool up) {
    if (up) {
      return headerMode.value == RefreshStatus.refreshing;
    } else {
      return footerMode.value == LoadStatus.loading;
    }
  }
}
