/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-01 11:39
*/

import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'internals/indicator_wrap.dart';
import 'internals/refresh_physics.dart';
import 'indicator/classic_indicator.dart';
import 'indicator/material_indicator.dart';

typedef void OnOffsetChange(bool up, double offset);

typedef IndicatorBuilder = Widget Function();

enum RefreshStatus {
  idle,
  canRefresh,
  refreshing,
  completed,
  failed,
  canTwoLevel,
  twoLevelOpening,
  twoLeveling,
  twoLevelClosing
}

enum LoadStatus { idle, loading, noMore, failed }

enum RefreshStyle { Follow, UnFollow, Behind, Front }

enum LoadStyle { ShowAlways, HideAlways, ShowWhenLoading }

const double default_refresh_triggerDistance = 80.0;

const double default_load_triggerDistance = 15.0;

final RefreshIndicator defaultHeader =
    defaultTargetPlatform == TargetPlatform.iOS
        ? ClassicHeader()
        : MaterialClassicHeader();

final LoadIndicator defaultFooter = ClassicFooter();

/*
    This is the most important component that provides drop-down refresh and up loading.
 */
class SmartRefresher extends StatefulWidget {
  //indicate your listView
  final Widget child;

  final RefreshIndicator header;
  final LoadIndicator footer;

  // This bool will affect whether or not to have the function of drop-up load.
  final bool enablePullUp;

  // controll whether open the second floor function
  final bool enableTwoLevel;

  //This bool will affect whether or not to have the function of drop-down refresh.
  final bool enablePullDown;

  // upper and downer callback when you drag out of the distance
  final Function onRefresh, onLoading, onTwoLevel;

  // This method will callback when the indicator changes from edge to edge.
  final OnOffsetChange onOffsetChange;

  //controll inner state
  final RefreshController controller;

  SmartRefresher(
      {Key key,
      @required this.controller,
      this.child,
      this.header,
      this.footer,
      this.enablePullDown: true,
      this.enablePullUp: false,
      this.enableTwoLevel: false,
      this.onRefresh,
      this.onLoading,
      this.onTwoLevel,
      this.onOffsetChange})
      : assert(controller != null),
        super(key: key);

  static SmartRefresher of(BuildContext context) {
    return context.ancestorWidgetOfExactType(SmartRefresher);
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SmartRefresherState();
  }
}

class _SmartRefresherState extends State<SmartRefresher> {
  void _updateController(
      BuildContext context, RefreshConfiguration configuration) {
    if (widget.child != null &&
        widget.child is ScrollView &&
        (widget.child as ScrollView).controller != null) {
      widget.controller.scrollController =
          (widget.child as ScrollView).controller;
    } else {
      widget.controller.scrollController = PrimaryScrollController.of(context);
    }
    widget.controller._headerTriggerDistance =
        -(configuration == null ? 80.0 : configuration.headerTriggerDistance);
    widget.controller._footerTriggerDistance =
        configuration?.footerTriggerDistance ?? 15.0;
  }

  //build slivers from child Widget
  List<Widget> _buildSliversByChild(
      BuildContext context, Widget child, RefreshConfiguration configuration) {
    List<Widget> slivers;
    if (child is ScrollView) {
      if (child is BoxScrollView) {
        //avoid system inject padding when own indicator top or bottom
        Widget sliver = child.buildChildLayout(context);
        if (child.padding != null) {
          slivers = [SliverPadding(sliver: sliver, padding: child.padding)];
        } else {
          slivers = [sliver];
        }
      } else {
        slivers = List.from(child.buildSlivers(context), growable: true);
      }
    } else {
      slivers = [
        SliverToBoxAdapter(
          child: child ?? Container(),
        )
      ];
    }
    if (widget.enablePullDown) {
      slivers.insert(
          0,
          widget.header ??
              (configuration?.headerBuilder != null
                  ? configuration?.headerBuilder()
                  : null) ??
              defaultHeader);
    }
    //insert header or footer
    if (widget.enablePullUp) {
      slivers.add(widget.footer ??
          (configuration?.footerBuilder != null
              ? configuration?.footerBuilder()
              : null) ??
          defaultFooter);
    }

    return slivers;
  }

  ScrollPhysics _getScrollPhysics(
      RefreshConfiguration conf, ScrollPhysics physics) {
    return RefreshPhysics(
            enablePullUp: widget.enablePullUp,
            enablePullDown: widget.enablePullDown,
            dragSpeedRatio: conf?.dragSpeedRatio,
            springDescription: conf?.springDescription,
            footerMode: widget.controller.footerMode,
            enableScrollWhenTwoLevel: conf?.enableScrollWhenTwoLevel ?? true,
            headerMode: widget.controller.headerMode,
            enableScrollWhenRefreshCompleted:
                conf?.enableScrollWhenRefreshCompleted ?? true,
            clamping: physics is ClampingScrollPhysics ||
                (physics is AlwaysScrollableScrollPhysics &&
                    defaultTargetPlatform != TargetPlatform.iOS),
            maxOverScrollExtent: conf?.maxOverScrollExtent,
            maxUnderScrollExtent: conf?.maxUnderScrollExtent)
        .applyTo(physics);
  }

  // build the customScrollView
  Widget _buildBodyBySlivers(
      Widget childView, List<Widget> slivers, RefreshConfiguration conf) {
    Widget body;
    if (childView is ScrollView) {
      body = CustomScrollView(
        physics: _getScrollPhysics(
            conf, childView.physics ?? AlwaysScrollableScrollPhysics()),
        controller: widget.controller.scrollController,
        cacheExtent: childView.cacheExtent,
        key: childView.key,
        scrollDirection: childView.scrollDirection,
        semanticChildCount: childView.semanticChildCount,
        slivers: slivers,
        dragStartBehavior: childView.dragStartBehavior,
        reverse: childView.reverse,
      );
    } else {
      body = CustomScrollView(
        physics: _getScrollPhysics(conf, AlwaysScrollableScrollPhysics()),
        controller: widget.controller.scrollController,
        slivers: slivers,
      );
    }
    return body;
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.controller.initialRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        /*
           if mounted,it avoid one stiuation: when init done,then dispose the widget before build.
           this   stiuation mostly TabBarView
        */
        if (mounted) widget.controller.requestRefresh();
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    widget.controller._detachPosition();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RefreshConfiguration configuration = RefreshConfiguration.of(context);
    _updateController(context, configuration);
    List<Widget> slivers =
        _buildSliversByChild(context, widget.child, configuration);
    Widget body = _buildBodyBySlivers(widget.child, slivers, configuration);
    if (configuration != null) {
      return body;
    } else {
      return RefreshConfiguration(child: body);
    }
  }
}

class RefreshController {
  ValueNotifier<RefreshStatus> headerMode;

  ValueNotifier<LoadStatus> footerMode;

  ScrollPosition position;
  double _headerTriggerDistance;
  double _footerTriggerDistance;
  @Deprecated(
      'advice set ScrollController to child,use it directly will cause bug when call jumpTo() and animateTo()')
  ScrollController scrollController;

  RefreshStatus get headerStatus => headerMode?.value;

  LoadStatus get footerStatus => footerMode?.value;

  bool get isRefresh => headerMode?.value == RefreshStatus.refreshing;

  bool get isTwoLevel => headerMode?.value == RefreshStatus.twoLeveling;

  bool get isLoading => footerMode?.value == LoadStatus.loading;

  final bool initialRefresh;

  RefreshController(
      {this.initialRefresh: false,
      RefreshStatus initialRefreshStatus,
      LoadStatus initialLoadStatus}) {
    this.headerMode = ValueNotifier(initialRefreshStatus ?? RefreshStatus.idle);
    this.footerMode = ValueNotifier(initialLoadStatus ?? LoadStatus.idle);
  }

  void onPositionUpdated(ScrollPosition newPosition) {
    assert(newPosition != null);
    position?.isScrollingNotifier?.removeListener(_listenScrollEnd);
    position = newPosition;
    position.isScrollingNotifier.addListener(_listenScrollEnd);
  }

  void _detachPosition() {
    position?.isScrollingNotifier?.removeListener(_listenScrollEnd);
  }

  // when bounce out of edge and stopped by overScroll or underScroll, it should be SpringBack to 0.0
  // but ScrollPhysics didn't provide one way to spring back when outOfEdge(stopped by applyBouncingCondition return != 0.0)
  // so for making it spring back, it should be trigger goBallistic make it spring back
  void _listenScrollEnd() {
    if (position.outOfRange) {
      position.activity.applyNewDimensions();
    }
  }

  void requestRefresh(
      {Duration duration: const Duration(milliseconds: 300),
      Curve curve: Curves.linear}) {
    assert(position != null,
        'Try not to call requestRefresh() before build,please call after the ui was rendered');
    if (isRefresh) return;
    position?.animateTo(_headerTriggerDistance,
        duration: duration, curve: curve);
  }

  void requestLoading(
      {Duration duration: const Duration(milliseconds: 300),
      Curve curve: Curves.linear}) {
    assert(position != null,
        'Try not to call requestLoading() before build,please call after the ui was rendered');
    if (isLoading) return;
    if (_footerTriggerDistance < 0) {
      position
          ?.animateTo(position.maxScrollExtent - _footerTriggerDistance,
              duration: duration, curve: curve)
          ?.whenComplete(() {
        footerMode.value = LoadStatus.loading;
      });
    } else
      position
          ?.animateTo(position.maxScrollExtent,
              duration: duration, curve: curve)
          ?.whenComplete(() {
        footerMode.value = LoadStatus.loading;
      });
  }

  void refreshCompleted({bool resetFooterState: false}) {
    headerMode?.value = RefreshStatus.completed;
    if (resetFooterState) {
      resetNoData();
    }
  }

  void twoLevelComplete(
      {Duration duration: const Duration(milliseconds: 500),
      Curve curve: Curves.linear}) {
    headerMode?.value = RefreshStatus.twoLevelClosing;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      position.activity.resetActivity();
      position
          .animateTo(0.0, duration: duration, curve: curve)
          .whenComplete(() {
        headerMode.value = RefreshStatus.idle;
      });
    });
  }

  void refreshFailed() {
    headerMode?.value = RefreshStatus.failed;
  }

  void refreshToIdle() {
    headerMode?.value = RefreshStatus.idle;
  }

  void loadComplete() {
    // change state after ui update,else it will have a bug:twice loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      footerMode?.value = LoadStatus.idle;
    });
  }

  void loadFailed() {
    // change state after ui update,else it will have a bug:twice loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      footerMode?.value = LoadStatus.failed;
    });
  }

  void loadNoData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

/*
    use to global setting indicator
 */
class RefreshConfiguration extends InheritedWidget {
  final Widget child;
  final IndicatorBuilder headerBuilder;
  final IndicatorBuilder footerBuilder;
  final SpringDescription springDescription;

  // If need to refreshing now when reaching triggerDistance
  final bool skipCanRefresh;

  // when listView data small(not enough one page) , it should be hide
  final bool hideFooterWhenNotFull;
  final double headerOffset;
  final bool autoLoad;
  final bool enableScrollWhenTwoLevel;
  final bool enableScrollWhenRefreshCompleted;
  final bool enableBallisticRefresh;
  final bool enableLoadingWhenFailed;
  final double headerTriggerDistance;
  final double twiceTriggerDistance;
  final double closeTwoLevelDistance;
  final double footerTriggerDistance;
  final double dragSpeedRatio;
  final double maxOverScrollExtent;
  final double maxUnderScrollExtent;

  RefreshConfiguration({
    @required this.child,
    this.headerBuilder,
    this.footerBuilder,
    this.dragSpeedRatio:1.0,
    this.enableScrollWhenTwoLevel: true,
    this.enableBallisticRefresh: false,
    this.springDescription,
    this.enableScrollWhenRefreshCompleted: true,
    this.headerOffset: 0.0,
    this.enableLoadingWhenFailed: false,
    this.twiceTriggerDistance: 150.0,
    this.closeTwoLevelDistance: 80.0,
    this.skipCanRefresh: false,
    this.autoLoad: true,
    this.maxOverScrollExtent,
    this.maxUnderScrollExtent,
    this.headerTriggerDistance: default_refresh_triggerDistance,
    this.footerTriggerDistance: default_load_triggerDistance,
    this.hideFooterWhenNotFull: true,
  });

  static RefreshConfiguration of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(RefreshConfiguration);
  }

  @override
  bool updateShouldNotify(RefreshConfiguration oldWidget) {
    return autoLoad != oldWidget.autoLoad ||
        skipCanRefresh != oldWidget.skipCanRefresh ||
        hideFooterWhenNotFull != oldWidget.hideFooterWhenNotFull ||
        headerOffset != oldWidget.headerOffset ||
        dragSpeedRatio!=oldWidget.dragSpeedRatio||
        springDescription!=oldWidget.springDescription||
        enableScrollWhenRefreshCompleted !=
            oldWidget.enableScrollWhenRefreshCompleted ||
        enableBallisticRefresh != oldWidget.enableBallisticRefresh ||
        enableScrollWhenTwoLevel != oldWidget.enableScrollWhenTwoLevel ||
        closeTwoLevelDistance != oldWidget.closeTwoLevelDistance ||
        footerTriggerDistance != oldWidget.footerTriggerDistance ||
        headerTriggerDistance != oldWidget.headerTriggerDistance ||
        twiceTriggerDistance != oldWidget.twiceTriggerDistance ||
        maxUnderScrollExtent != oldWidget.maxUnderScrollExtent ||
        oldWidget.maxOverScrollExtent != maxOverScrollExtent ||
        enableBallisticRefresh != oldWidget.enableBallisticRefresh ||
        enableLoadingWhenFailed != oldWidget.enableLoadingWhenFailed;
  }
}
