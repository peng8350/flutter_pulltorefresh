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
import 'package:flutter/scheduler.dart';

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
        ?.ancestorStateOfType(const TypeMatcher<SmartRefresherState>());
  }
}

class SmartRefresherState extends State<SmartRefresher> with TickerProviderStateMixin {
  // listen the listen offset or on...
  ScrollController scrollController;
  // check the header own height
  ValueNotifier<bool> hasHeaderLayout = ValueNotifier(false);

  @override
  void dispose() {
    // TODO: implement dispose
    if (!widget.isNestWrapped && widget.child.controller == null) {
      scrollController.dispose();
    }
    hasHeaderLayout.dispose();
    hasHeaderLayout = null;
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    if (!widget.isNestWrapped) {
      scrollController = widget.child.controller ?? ScrollController();
      widget.controller.scrollController = scrollController;
    }
    widget.controller._header = widget.header;
    if(widget.header.refreshStyle == RefreshStyle.Front){
      SchedulerBinding.instance.addPostFrameCallback((_){
        scrollController.jumpTo(widget.header.height);
      });
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    // there is no method to get PrimaryScrollController in initState
    if (widget.isNestWrapped) {
      scrollController = PrimaryScrollController.of(context);
      widget.controller.scrollController = scrollController;
    }

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(SmartRefresher oldWidget) {
    // TODO: implement didUpdateWidget
    if (widget.enablePullDown != oldWidget.enablePullDown) {
      widget.controller.headerMode.value = RefreshStatus.idle;
      hasHeaderLayout.value = false;
    }
    if (widget.enablePullUp != oldWidget.enablePullUp) {
      widget.controller.footerMode.value = LoadStatus.idle;
    }
    if (!widget.isNestWrapped && widget.child.controller != null) {
      scrollController = widget.child.controller;
    }

    if (widget.isNestWrapped) {
      scrollController = PrimaryScrollController.of(context);
    }
    widget.controller.scrollController = scrollController;
    widget.controller._header = widget.header;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> slivers =
        List.from(widget.child.buildSlivers(context), growable: true);

    if (widget.enablePullDown) {
      slivers.insert(0, widget.header);
    }
    if (widget.enablePullUp) {
      slivers.add(widget.footer);
    }
    return CustomScrollView(
      physics: widget.header.refreshStyle == RefreshStyle.Front
          ? RefreshClampPhysics(headerHeight: widget.header.height,provider: this)
          : RefreshBouncePhysics(),
      controller: scrollController,
      cacheExtent: widget.child.cacheExtent,
      key: widget.child.key,
      center: widget.child.center,
      anchor: widget.child.anchor,
      semanticChildCount: widget.child.semanticChildCount,
      slivers: slivers,
      reverse: widget.child.reverse,
    );
  }
}

class RefreshController {
  ValueNotifier<RefreshStatus> headerMode = ValueNotifier(RefreshStatus.idle);
  ValueNotifier<LoadStatus> footerMode = ValueNotifier(LoadStatus.idle);
  ScrollController scrollController;
  RefreshIndicator _header;

  RefreshStatus get headerStatus => headerMode?.value;

  LoadStatus get footerStatus => footerMode?.value;

  bool get isRefresh => headerMode?.value == RefreshStatus.refreshing;

  bool get isLoading => footerMode?.value == LoadStatus.loading;

  void requestRefresh(
      {bool needDownAnimate: true,
      Duration duration: const Duration(milliseconds: 300),
      Curve curve: Curves.linear}) {
    assert(scrollController != null,
        'Try not to call requestRefresh() before build,please call after the ui was rendered');
    if (headerMode?.value != RefreshStatus.idle) return;
    if (needDownAnimate) {
      scrollController.animateTo(-_header.triggerDistance,
          duration: duration, curve: curve);
    } else {
      headerMode?.value = RefreshStatus.refreshing;
      // only afte the header has Layout,else it will generate a bouncing effect
      SchedulerBinding.instance.addPostFrameCallback((_) {
        scrollController.jumpTo(0.0);
      });
    }
  }

  void requestLoading(
      {Duration duration: const Duration(milliseconds: 300),
      Curve curve: Curves.linear}) {
    assert(scrollController != null,
        'Try not to call requestLoading() before build,please call after the ui was rendered');
    if (footerStatus == LoadStatus.idle) {
      if(_header.refreshStyle==RefreshStyle.Front){
        // avoid trigger refresh together
        footerMode.value = LoadStatus.loading;
      }
      else{
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: duration, curve: curve).whenComplete((){
          footerMode.value = LoadStatus.loading;
        });
      }
    }
  }

  void refreshCompleted() {
    headerMode?.value = RefreshStatus.completed;
  }

  void refreshFailed() {
    headerMode?.value = RefreshStatus.failed;
  }

  void loadComplete() {
    // change state after ui update,else it will have a bug:twice loading
    SchedulerBinding.instance.addPostFrameCallback((_) {
      footerMode?.value = LoadStatus.idle;
    });
  }

  void loadNoData() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      footerMode?.value = LoadStatus.noMore;
    });
  }

  void resetNoData() {
    footerMode?.value = LoadStatus.idle;
  }

  void dispose() {
    headerMode.dispose();
    footerMode.dispose();
    headerMode = null;
    footerMode = null;
  }
}
