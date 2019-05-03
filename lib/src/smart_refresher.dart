/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-01 11:39
 */

import 'package:flutter/material.dart';
import 'internals/default_constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:pull_to_refresh/src/internals/indicator_config.dart';
import 'package:pull_to_refresh/src/internals/indicator_wrap.dart';
import 'package:pull_to_refresh/src/internals/refresh_physics.dart';
import 'indicator/classic_indicator.dart';
import 'dart:math' as math;

import 'internals/refreshsliver.dart';

enum WrapperType { Refresh, Loading }

enum RefreshStatus { idle, canRefresh, refreshing, completed, failed }

enum LoadStatus { idle, loading, noMore }

enum RefreshStyle { Follow, UnFollow, Behind, Front }

/*
    This is the most important component that provides drop-down refresh and up loading.
 */
class SmartRefresher extends StatefulWidget {
  //indicate your listView
  final ScrollView child;

  final HeaderBuilder headerBuilder;
  final FooterBuilder footerBuilder;
  // configure your header and footer
  final RefreshConfig headerConfig;
  final LoadConfig footerConfig;
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
      HeaderBuilder headerBuilder,
      FooterBuilder footerBuilder,
      this.headerConfig: const RefreshConfig(),
      this.footerConfig: const LoadConfig(),
      this.enableOverScroll: default_enableOverScroll,
      this.enablePullDown: default_enablePullDown,
      this.enablePullUp: default_enablePullUp,
      this.onRefresh,
      this.onLoading,
      this.onOffsetChange,
      this.isNestWrapped: false})
      : assert(child != null),
        assert(controller != null),
        this.headerBuilder = headerBuilder ??
            ((BuildContext context, RefreshStatus mode) {
              return ClassicHeader(mode: mode);
            }),
        this.footerBuilder = footerBuilder ??
            ((BuildContext context, LoadStatus mode) {
              return ClassicFooter(mode: mode);
            }),
        super(key: key);

  @override
  _SmartRefresherState createState() => _SmartRefresherState();

  static SmartRefresher of(BuildContext context) {
    return context.ancestorWidgetOfExactType(SmartRefresher) as SmartRefresher;
  }
}

class _SmartRefresherState extends State<SmartRefresher> {
  // listen the listen offset or on...
  ScrollController _scrollController;
  // key to get height header of footer
  final GlobalKey _headerKey = GlobalKey(), _footerKey = GlobalKey();

  Widget _buildWrapperByConfig(Config config, bool up) {
    if (config is LoadConfig) {
      return LoadWrapper(
        key: up ? _headerKey : _footerKey,
        modeListener:
            up ? widget.controller.headerMode : widget.controller.footerMode,
        autoLoad: config.autoLoad,
        triggerDistance: config.triggerDistance,
        builder: up ? widget.headerBuilder : widget.footerBuilder,
      );
    } else if (config is RefreshConfig) {
      return RefreshWrapper(
        key: up ? _headerKey : _footerKey,
        modeLis:
            up ? widget.controller.headerMode : widget.controller.footerMode,
        refreshStyle: config.refreshStyle,
        completeDuration: config.completeDuration,
        triggerDistance: config.triggerDistance,
        height: config.height,
        builder: up ? widget.headerBuilder : widget.footerBuilder,
      );
    }
    return SliverToBoxAdapter();
  }

  //handle the scrollMoveEvent
  bool _handleScrollMoving(ScrollUpdateNotification notification) {
    GestureProcessor topWrap = _headerKey.currentState as GestureProcessor;
    GestureProcessor bottomWrap = _footerKey.currentState as GestureProcessor;
    if (widget.enablePullUp) bottomWrap.onDragMove(notification);
    if (widget.enablePullDown) topWrap.onDragMove(notification);
    return false;
  }

  //handle the scrollEndEvent
  bool _handleScrollEnd(ScrollNotification notification) {
    GestureProcessor topWrap = _headerKey.currentState as GestureProcessor;
    GestureProcessor bottomWrap = _footerKey.currentState as GestureProcessor;
    if (widget.enablePullUp) bottomWrap.onDragEnd(notification);
    if (widget.enablePullDown) topWrap.onDragEnd(notification);
    return false;
  }

  bool _dispatchScrollEvent(ScrollNotification notification) {
    // ignore the nested scrollview's notification
    if (notification.depth != 0) {
      return false;
    }
    // when is scroll in the ScrollInside,nothing to do
    if ((!_isPullUp(notification) && !_isPullDown(notification))) return false;
    if (notification is ScrollUpdateNotification) {
      //if dragDetails is null,This represents the user's finger out of the screen
      if (notification.dragDetails == null) {
        return _handleScrollEnd(notification);
      } else if (notification.dragDetails != null) {
        return _handleScrollMoving(notification);
      }
    }
    if (notification is ScrollEndNotification) {
      _handleScrollEnd(notification);
    }

    return false;
  }

  //check user is pulling up
  bool _isPullUp(ScrollNotification noti) {
    return noti.metrics.pixels < 0;
  }

  //check user is pulling down
  bool _isPullDown(ScrollNotification noti) {
    return noti.metrics.pixels > 0;
  }

  void _init() {
    widget.controller.headerMode.addListener(() {
      _didChangeMode(true, widget.controller.headerMode);
    });
    widget.controller.footerMode.addListener(() {
      _didChangeMode(false, widget.controller.footerMode);
    });
  }

  void _handleOffsetCallback() {
    final double overscrollPastStart = math.max(
        _scrollController.position.minScrollExtent -
            _scrollController.position.pixels,
        0.0);
    final double overscrollPastEnd = math.max(
        _scrollController.position.pixels -
            _scrollController.position.maxScrollExtent,
        0.0);
    if (overscrollPastStart > overscrollPastEnd) {
      if (widget.onOffsetChange != null) {
        widget.onOffsetChange(
            true,
            overscrollPastStart +
                ((RefreshStatus.refreshing ==
                        widget.controller.headerMode.value)
                    ? widget.headerConfig.height
                    : 0.0));
      }
    } else if (overscrollPastEnd > 0) {
      if (widget.onOffsetChange != null) {
        widget.onOffsetChange(false, overscrollPastEnd);
      }
    }
  }

  _didChangeMode(up,  mode) {
    if (up&&mode.value == RefreshStatus.refreshing && widget.onRefresh != null) {
      widget.onRefresh();
    }
    if(!up&&mode.value == LoadStatus.loading&&widget.onLoading!=null){
      widget.onLoading();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.removeListener(_handleOffsetCallback);
    if (!widget.isNestWrapped && widget.child.controller == null) {
      _scrollController.dispose();
    }

    widget.controller.headerMode.dispose();
    widget.controller.footerMode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (widget.isNestWrapped) {
      _scrollController = PrimaryScrollController.of(context);
    } else {
      _scrollController = widget.child.controller ?? ScrollController();
    }
    widget.controller.scrollController = _scrollController;
    _scrollController.addListener(_handleOffsetCallback);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(SmartRefresher oldWidget) {
    // TODO: implement didUpdateWidget

    _scrollController.removeListener(_handleOffsetCallback);

    if (!widget.isNestWrapped && widget.child.controller != null) {
      _scrollController = widget.child.controller;
    }
    if (widget.isNestWrapped) {
      _scrollController = PrimaryScrollController.of(context);
    }

    _scrollController.addListener(_handleOffsetCallback);
    widget.controller.scrollController = _scrollController;

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> slivers =
        List.from(widget.child.buildSlivers(context), growable: true);

    slivers.insert(0, _buildWrapperByConfig(widget.headerConfig, true));
    slivers.add(_buildWrapperByConfig(widget.footerConfig, false));

    return NotificationListener(
      child: CustomScrollView(
        physics:
            RefreshScrollPhysics(enableOverScroll: widget.enableOverScroll),
        controller: _scrollController,
        cacheExtent: widget.child.cacheExtent,
        slivers: slivers,
        reverse: widget.child.reverse,
      ),
      onNotification: _dispatchScrollEvent,
    );
  }
}

abstract class Indicator extends StatefulWidget {
  final  mode;

  const Indicator({Key key, this.mode}) : super(key: key);
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

  void refreshCompleted(){
    headerMode.value = RefreshStatus.completed;
  }

  void refreshFailed(){
    headerMode.value = RefreshStatus.failed;
  }

  void loadComplete(){
    footerMode.value = LoadStatus.idle;
  }

  void loadNoData(){
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
