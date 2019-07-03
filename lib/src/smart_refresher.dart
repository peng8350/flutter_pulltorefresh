/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-01 11:39
*/

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
class SmartRefresher extends StatelessWidget {
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

  void _updateController(
      BuildContext context, RefreshConfiguration configuration) {
    if (child != null &&
        child is ScrollView &&
        (child as ScrollView).controller != null) {
      controller.scrollController = (child as ScrollView).controller;
    } else {
      controller.scrollController = PrimaryScrollController.of(context);
    }
    controller._triggerDistance =
        -(configuration == null ? 80.0 : configuration.headerTriggerDistance);
  }

  void onPositionUpdated(ScrollPosition newPosition) {
    assert(newPosition != null);
    controller?.position?.isScrollingNotifier?.removeListener(_listenScrollEnd);
    controller.position = newPosition;
    controller.position.isScrollingNotifier.addListener(_listenScrollEnd);
  }

  // when bounce out of edge and stopped by overScroll or underScroll, it should be SpringBack to 0.0
  // but ScrollPhysics didn't provide one way to spring back when outOfEdge(stopped by applyBouncingCondition return != 0.0)
  // so for making it spring back, it should be trigger goBallistic make it spring back
  void _listenScrollEnd() {
    if (controller.position.outOfRange) {
      controller.position.activity.applyNewDimensions();
    }
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
    if (enablePullDown) {
      slivers.insert(
          0,
          header ??
              (configuration?.headerBuilder != null
                  ? configuration?.headerBuilder()
                  : null) ??
              defaultHeader);
    }
    //insert header or footer
    if (enablePullUp) {
      slivers.add(footer ??
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
            enablePullUp: enablePullUp,
            enablePullDown: enablePullDown,
            footerMode: controller.footerMode,
            enableScrollWhenTwoLevel: conf?.enableScrollWhenTwoLevel ?? true,
            headerMode: controller.headerMode,
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
        controller: controller.scrollController,
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
        controller: controller.scrollController,
        slivers: slivers,
      );
    }
    return body;
  }

  @override
  Widget build(BuildContext context) {
    final RefreshConfiguration configuration = RefreshConfiguration.of(context);
    _updateController(context, configuration);
    List<Widget> slivers = _buildSliversByChild(context, child, configuration);
    Widget body = _buildBodyBySlivers(child, slivers, configuration);
    if (configuration != null) {
      return body;
    } else {
      return RefreshConfiguration(child: body);
    }
  }

  static SmartRefresher of(BuildContext context) {
    return context.ancestorWidgetOfExactType(SmartRefresher);
  }
}

class RefreshController {
  ValueNotifier<RefreshStatus> headerMode;

  ValueNotifier<LoadStatus> footerMode;

  ScrollPosition position;
  double _triggerDistance;
  @Deprecated(
      'advice set ScrollController to child,use it directly will cause bug when call jumpTo() and animateTo()')
  ScrollController scrollController;

  RefreshStatus get headerStatus => headerMode?.value;

  LoadStatus get footerStatus => footerMode?.value;

  bool get isRefresh => headerMode?.value == RefreshStatus.refreshing;

  bool get isTwoLevel => headerMode?.value == RefreshStatus.twoLeveling;

  bool get isLoading => footerMode?.value == LoadStatus.loading;

  RefreshController(
      {bool initialRefresh: false,
      RefreshStatus initialRefreshStatus,
      LoadStatus initialLoadStatus}) {
    this.headerMode = ValueNotifier(initialRefreshStatus ?? RefreshStatus.idle);
    this.footerMode = ValueNotifier(initialLoadStatus ?? LoadStatus.idle);
    if (initialRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        requestRefresh();
      });
    }
  }

  void requestRefresh(
      {Duration duration: const Duration(milliseconds: 300),
      Curve curve: Curves.linear}) {
    assert(position != null,
        'Try not to call requestRefresh() before build,please call after the ui was rendered');
    if (isRefresh) return;
    position?.animateTo(_triggerDistance, duration: duration, curve: curve);
  }

  void requestLoading(
      {Duration duration: const Duration(milliseconds: 300),
      Curve curve: Curves.linear}) {
    assert(position != null,
        'Try not to call requestLoading() before build,please call after the ui was rendered');
    if (isLoading) return;
    position
        ?.animateTo(position.maxScrollExtent, duration: duration, curve: curve)
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
  final IndicatorBuilder headerBuilder;
  final IndicatorBuilder footerBuilder;

  // If need to refreshing now when reaching triggerDistance
  final bool skipCanRefresh;

  // when listView data small(not enough one page) , it should be hide
  final bool hideFooterWhenNotFull;
  final double headerOffset;
  final bool autoLoad;
  final bool enableScrollWhenTwoLevel;
  final bool enableScrollWhenRefreshCompleted;
  final bool enableBallisticRefresh;
  final Widget child;
  final double headerTriggerDistance;
  final double twiceTriggerDistance;
  final double closeTwoLevelDistance;
  final double footerTriggerDistance;
  final double maxOverScrollExtent;
  final double maxUnderScrollExtent;

  RefreshConfiguration({
    @required this.child,
    this.headerBuilder,
    this.footerBuilder,
    this.enableScrollWhenTwoLevel: true,
    this.enableBallisticRefresh: false,
    this.enableScrollWhenRefreshCompleted: true,
    this.headerOffset: 0.0,
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
        enableScrollWhenRefreshCompleted !=
            oldWidget.enableScrollWhenRefreshCompleted ||
        enableBallisticRefresh != oldWidget.enableBallisticRefresh ||
        enableScrollWhenTwoLevel != oldWidget.enableScrollWhenTwoLevel ||
        closeTwoLevelDistance != oldWidget.closeTwoLevelDistance ||
        footerTriggerDistance != oldWidget.footerTriggerDistance ||
        headerTriggerDistance != oldWidget.headerTriggerDistance ||
        twiceTriggerDistance != oldWidget.twiceTriggerDistance ||
        maxUnderScrollExtent != oldWidget.maxUnderScrollExtent ||
        oldWidget.maxOverScrollExtent != maxOverScrollExtent;
  }
}
