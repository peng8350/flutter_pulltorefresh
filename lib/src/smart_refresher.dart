/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-01 11:39
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'internals/indicator_wrap.dart';
import 'internals/refresh_physics.dart';
import 'indicator/classic_indicator.dart';
import 'indicator/material_indicator.dart';

// ignore_for_file: INVALID_USE_OF_PROTECTED_MEMBER
// ignore_for_file: INVALID_USE_OF_VISIBLE_FOR_TESTING_MEMBER

/// callback when the indicator scroll out of edge
/// up: indicate header or footer callback
/// offset: the distance of indicator out of edge
typedef void OnOffsetChange(bool up, double offset);

/// when viewport not full one page, for different state,whether it should follow the content
typedef bool ShouldFollowContent(LoadStatus status);

/// global default indicator builder
typedef IndicatorBuilder = Widget Function();

/// a builder for attaching refresh function with the physics
typedef Widget RefresherBuilder(BuildContext context,RefreshPhysics physics);

/// header state
enum RefreshStatus {
  /// Initial state, when not being overscrolled into, or after the overscroll
  /// is canceled or after done and the sliver retracted away.
  idle,

  /// Dragged far enough that the onRefresh callback will callback
  canRefresh,

  /// the indicator is refreshing,waiting for the finish callback
  refreshing,

  /// the indicator refresh completed
  completed,

  /// the indicator refresh failed
  failed,

  ///  Dragged far enough that the onTwoLevel callback will callback
  canTwoLevel,

  ///  indicator is opening twoLevel
  twoLevelOpening,

  /// indicator is in twoLevel
  twoLeveling,

  ///  indicator is closing twoLevel
  twoLevelClosing
}

///  footer state
enum LoadStatus {
  /// Initial state, which can be triggered loading more by gesture pull up
  idle,

  /// indicator is loading more data
  loading,

  /// indicator is no more data to loading,this state doesn't allow to load more whatever
  noMore,

  /// indicator load failed,Initial state, which can be click retry,If you need to pull up trigger load more,you should set enableLoadingWhenFailed = true in RefreshConfiguration
  failed
}

/// header indicator display style
enum RefreshStyle {
  // indicator box always follow content
  Follow,
  // indicator box follow content,When the box reaches the top and is fully visible, it does not follow content.
  UnFollow,

  /// Let the indicator size zoom in with the boundary distance,look like showing behind the content
  Behind,

  /// this style just like flutter RefreshIndicator,showing above the content
  Front
}

/// footer indicator display style
enum LoadStyle {
  /// indicator always own layoutExtent whatever the state
  ShowAlways,

  /// indicator always own 0.0 layoutExtent whatever the state
  HideAlways,

  /// indicator always own layoutExtent when loading state, the other state is 0.0 layoutExtent
  ShowWhenLoading
}

/// This is the most important component that provides drop-down refresh and up loading.
/// [RefreshController] must not be null,Only one controller to one SmartRefresher
/// If you need to custom header or footer,You should check out [CustomHeader] or [CustomFooter]
///
/// See also:
///
/// * [RefreshConfiguration], A global configuration for all SmartRefresher in subtrees
///
/// * [RefreshController], A controller controll header and footer  indicators state
class SmartRefresher extends StatefulWidget {
  /// Refresh Content
  ///
  /// notice that: If child is  extends ScrollView,It will help you get the internal slivers and add footer and header in it.
  /// else it will put child into SliverToBoxAdapter and add footer and header
  final Widget child;

  /// header indicator displace before content
  ///
  /// If reverse is false,header displace at the top of content.
  /// If reverse is true,header displace at the bottom of content.
  /// if scrollDirection = Axis.horizontal,it will display at left or right
  final RefreshIndicator header;

  /// footer indicator display after content
  ///
  /// If reverse is true,header displace at the top of content.
  /// If reverse is false,header displace at the bottom of content.
  /// if scrollDirection = Axis.horizontal,it will display at left or right
  final LoadIndicator footer;
  // This bool will affect whether or not to have the function of drop-up load.
  final bool enablePullUp;

  /// controll whether open the second floor function
  final bool enableTwoLevel;

  /// This bool will affect whether or not to have the function of drop-down refresh.
  final bool enablePullDown;

  /// callback when header refresh
  ///
  /// when the callback is happening,you should use [RefreshController]
  /// to end refreshing state,else it will keep refreshing state
  final VoidCallback onRefresh;

  /// callback when footer loading more data
  ///
  /// when the callback is happening,you should use [RefreshController]
  /// to end loading state,else it will keep loading state
  final VoidCallback onLoading;

  /// callback when header ready to twoLevel
  ///
  /// If you want to close twoLevel,you should use [RefreshController.closeTwoLevel]
  final VoidCallback onTwoLevel;

  /// callback when the indicator scroll out of edge
  final OnOffsetChange onOffsetChange;

  /// Controll inner state
  final RefreshController controller;

  /// child content builder
  final RefresherBuilder builder;

  /// creates a widget help attach the refresh and load more function
  /// controller must not be null,
  /// child is your refresh content,Note that there's a big difference between children inheriting from ScrollView or not.
  /// If child is extends ScrollView,inner will get the slivers from ScrollView,if not,inner will wrap child into SliverToBoxAdapter.
  /// If your child inner container Scrollable,please consider about converting to Sliver,and use CustomScrollView,or use [builder] constructor
  /// such as AnimatedList,RecordableList,doesn't allow to put into child,it will wrap it into SliverToBoxAdapter
  /// If you don't need pull down refresh ,just enablePullDown = false,
  /// If you  need pull up load ,just enablePullUp = true
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
      : assert(controller != null),builder = null,
        super(key: key);

  /// creates a widget help attach the refresh and load more function
  /// controller must not be null,builder must not be null
  /// this constructor use to handle some special third party widgets,this widget need to pass slivers ,but they are
  /// not extends ScrollView,so my widget inner will wrap child to SliverToBoxAdapter,which cause scrollable wrapping scrollable.
  /// for example,NestedScrollView is a StalessWidget,it's headerSliversbuilder can return a slivers array,So if we want to do
  /// refresh above NestedScrollVIew,we must use this constrctor to implements refresh above NestedScrollView,but for now,NestedScrollView
  /// can not support overscroll out of edge
  SmartRefresher.builder(
      {Key key,
        @required this.controller,
        @required this.builder,
        this.enablePullDown: true,
        this.enablePullUp: false,
        this.enableTwoLevel: false,
        this.onRefresh,
        this.onLoading,
        this.onTwoLevel,
        this.onOffsetChange})
      : assert(controller != null),header =null,footer=null,child=null,
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
  RefreshPhysics _physics;
  bool _updatePhysics = false;

  final RefreshIndicator defaultHeader =
  defaultTargetPlatform == TargetPlatform.iOS
      ? ClassicHeader()
      : MaterialClassicHeader();

  final LoadIndicator defaultFooter = ClassicFooter();

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
    } else if (child is! Scrollable) {
      slivers = [
        SliverToBoxAdapter(
          child: child ?? Container(),
        )
      ];
    }
    if (widget.enablePullDown || widget.enableTwoLevel) {
      slivers?.insert(
          0,
          widget.header ??
              (configuration?.headerBuilder != null
                  ? configuration?.headerBuilder()
                  : null) ??
              defaultHeader);
    }
    //insert header or footer
    if (widget.enablePullUp) {
      slivers?.add(widget.footer ??
          (configuration?.footerBuilder != null
              ? configuration?.footerBuilder()
              : null) ??
          defaultFooter);
    }

    return slivers;
  }

  ScrollPhysics _getScrollPhysics(
      RefreshConfiguration conf) {
    return _physics = RefreshPhysics(
        dragSpeedRatio: conf?.dragSpeedRatio,
        springDescription: conf?.springDescription,
        footerMode: widget.controller.footerMode,
        enableScrollWhenTwoLevel: conf?.enableScrollWhenTwoLevel ?? true,
        headerMode: widget.controller.headerMode,
        updateFlag: _updatePhysics ? 0 : 1,
        enableScrollWhenRefreshCompleted:
        conf?.enableScrollWhenRefreshCompleted ?? false,
        maxOverScrollExtent: conf?.maxOverScrollExtent,
        maxUnderScrollExtent: conf?.maxUnderScrollExtent
    );
  }

  // build the customScrollView
  Widget _buildBodyBySlivers(
      Widget childView, List<Widget> slivers, RefreshConfiguration conf) {
    Widget body;
    if (childView is ScrollView) {
      body = CustomScrollView(
        physics: _getScrollPhysics(
            conf).applyTo(childView.physics ?? AlwaysScrollableScrollPhysics()),
        // ignore: DEPRECATED_MEMBER_USE_FROM_SAME_PACKAGE
        controller: widget.controller.scrollController =
            childView.controller ?? PrimaryScrollController.of(context),
        cacheExtent: childView.cacheExtent,
        key: childView.key,
        scrollDirection: childView.scrollDirection,
        semanticChildCount: childView.semanticChildCount,
        slivers: slivers,
        dragStartBehavior: childView.dragStartBehavior,
        reverse: childView.reverse,
      );
    } else if (childView is Scrollable) {
      body = Scrollable(
        physics: _getScrollPhysics(
            conf).applyTo( childView.physics ?? AlwaysScrollableScrollPhysics()),
        controller: childView.controller,
        axisDirection: childView.axisDirection,
        semanticChildCount: childView.semanticChildCount,
        dragStartBehavior: childView.dragStartBehavior,
        viewportBuilder: (context, offset) {
          Viewport viewport = childView.viewportBuilder(context, offset);
          if (widget.enablePullDown) {
            viewport.children.insert(
                0,
                widget.header ??
                    (conf?.headerBuilder != null
                        ? conf?.headerBuilder()
                        : null) ??
                    defaultHeader);
          }
          //insert header or footer
          if (widget.enablePullUp) {
            viewport.children.add(widget.footer ??
                (conf?.footerBuilder != null ? conf?.footerBuilder() : null) ??
                defaultFooter);
          }
          return viewport;
        },
      );
    } else {
      body = CustomScrollView(
        physics: _getScrollPhysics(conf).applyTo(AlwaysScrollableScrollPhysics()),
        controller: PrimaryScrollController.of(context),
        slivers: slivers,
      );
    }
    return body;
  }

  bool _ifNeedUpdatePhysics() {
    RefreshConfiguration conf = RefreshConfiguration.of(context);
    if (conf == null || _physics == null) {
      return false;
    }

    if (conf.maxOverScrollExtent != _physics.maxOverScrollExtent ||
        _physics.maxUnderScrollExtent != conf.maxUnderScrollExtent ||
        _physics.dragSpeedRatio != conf.dragSpeedRatio ||
        _physics.enableScrollWhenTwoLevel != conf.enableScrollWhenTwoLevel ||
        _physics.enableScrollWhenRefreshCompleted !=
            conf.enableScrollWhenRefreshCompleted) {
      return true;
    }
    return false;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (_ifNeedUpdatePhysics()) {
      _updatePhysics = !_updatePhysics;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.controller.initialRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //  if mounted,it avoid one situation: when init done,then dispose the widget before build.
        //  this   situation mostly TabBarView
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
    if(widget.builder!=null) return RefreshConfiguration(
      child: widget.builder(context,_getScrollPhysics(configuration)),

    );

    widget.controller._headerTriggerDistance =
    -(configuration == null ? 80.0 : configuration.headerTriggerDistance);
    widget.controller._footerTriggerDistance =
        configuration?.footerTriggerDistance ?? 15.0;
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
/// A controller controll header and footer state,
/// it  can trigger  driving request Refresh ,set the initalRefresh,status if needed
///
/// See also:
///
/// [SmartRefresher],a widget help you attach refresh and load more function easily
class RefreshController {
  /// header status mode controll
  ValueNotifier<RefreshStatus> headerMode;

  /// footer status mode controll
  ValueNotifier<LoadStatus> footerMode;

  /// the scrollable inner's position
  ///
  /// notice that: position is null before build,
  /// the value is get when the header or footer callback onPositionUpdated
  ScrollPosition position;
  double _headerTriggerDistance;
  double _footerTriggerDistance;

  /// deprecated member,not suggest to use it,it contain share position bug
  @Deprecated(
      'advice set ScrollController to child,use it directly will cause bug when call jumpTo() and animateTo()')
  ScrollController scrollController;

  RefreshStatus get headerStatus => headerMode?.value;

  LoadStatus get footerStatus => footerMode?.value;

  bool get isRefresh => headerMode?.value == RefreshStatus.refreshing;

  bool get isTwoLevel => headerMode?.value == RefreshStatus.twoLeveling;

  bool get isLoading => footerMode?.value == LoadStatus.loading;

  final bool initialRefresh;

  /// initialRefresh:When SmartRefresher is init,it will call requestRefresh at once
  ///
  /// initialRefreshStatus: headerMode default value
  ///
  /// initialLoadStatus: footerMode default value
  RefreshController(
      {this.initialRefresh: false,
        RefreshStatus initialRefreshStatus,
        LoadStatus initialLoadStatus}) {
    this.headerMode = ValueNotifier(initialRefreshStatus ?? RefreshStatus.idle);
    this.footerMode = ValueNotifier(initialLoadStatus ?? LoadStatus.idle);
  }

  /// callback when the indicator is builded,and catch the scrollable's inner position
  void onPositionUpdated(ScrollPosition newPosition) {
    assert(newPosition != null);
    position?.isScrollingNotifier?.removeListener(_listenScrollEnd);
    position = newPosition;
    position.isScrollingNotifier.addListener(_listenScrollEnd);
  }

  void _detachPosition() {
    position?.isScrollingNotifier?.removeListener(_listenScrollEnd);
  }

  /// when bounce out of edge and stopped by overScroll or underScroll, it should be SpringBack to 0.0
  /// but ScrollPhysics didn't provide one way to spring back when outOfEdge(stopped by applyBouncingCondition return != 0.0)
  /// so for making it spring back, it should be trigger goBallistic make it spring back
  void _listenScrollEnd() {
    if (position.outOfRange) {
      position.activity.applyNewDimensions();
    }
  }

  /// make the header enter refreshing state,and callback onRefresh
  void requestRefresh(
      {Duration duration: const Duration(milliseconds: 500),
        Curve curve: Curves.linear}) {
    assert(position != null,
    'Try not to call requestRefresh() before build,please call after the ui was rendered');
    if (isRefresh) return;
    position?.animateTo(_headerTriggerDistance,
        duration: duration, curve: curve);
  }

  /// make the footer enter loading state,and callback onLoading
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

  /// request complete,the header will enter complete state,
  ///
  /// resetFooterState : it will set the footer state from noData to idle
  void refreshCompleted({bool resetFooterState: false}) {
    headerMode?.value = RefreshStatus.completed;
    if (resetFooterState) {
      resetNoData();
    }
  }

  /// end twoLeveling,will return back first floor
  void twoLevelComplete(
      {Duration duration: const Duration(milliseconds: 500),
        Curve curve: Curves.linear}) {
    headerMode?.value = RefreshStatus.twoLevelClosing;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      position
          .animateTo(0.0, duration: duration, curve: curve)
          .whenComplete(() {
        headerMode.value = RefreshStatus.idle;
      });
    });
  }

  /// request failed,the header display failed state
  void refreshFailed() {
    headerMode?.value = RefreshStatus.failed;
  }

  /// not show success or failed, it will set header state to idle and spring back at once
  void refreshToIdle() {
    headerMode?.value = RefreshStatus.idle;
  }

  /// after data returned,set the footer state to idle
  void loadComplete() {
    // change state after ui update,else it will have a bug:twice loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      footerMode?.value = LoadStatus.idle;
    });
  }

  /// If catchError happen,you may call loadFailed indicate fetch data from network failed
  void loadFailed() {
    // change state after ui update,else it will have a bug:twice loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      footerMode?.value = LoadStatus.failed;
    });
  }

  /// load more success without error,but no data returned
  void loadNoData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      footerMode?.value = LoadStatus.noMore;
    });
  }

  /// reset footer noData state  to idle
  void resetNoData() {
    if(footerMode.value==LoadStatus.noMore) {
      footerMode?.value = LoadStatus.idle;
    }
  }

  /// for some special situation, you should call dispose() for safe,it may throw errors after parent widget dispose
  void dispose() {
    headerMode.dispose();
    footerMode.dispose();
    headerMode = null;
    footerMode = null;
  }
}

/// Controls how SmartRefresher widgets behave in a subtree.the usage just like [ScrollConfiguration]
///
/// The refresh configuration determines smartRefresher some behaviours,global setting default indicator
///
/// see also:
///
/// [SmartRefresher], a widget help attach the refresh and load more function
class RefreshConfiguration extends InheritedWidget {
  final Widget child;

  /// global default header builder
  final IndicatorBuilder headerBuilder;

  /// global default footer builder
  final IndicatorBuilder footerBuilder;

  /// custom spring animate
  final SpringDescription springDescription;

  /// If need to refreshing now when reaching triggerDistance
  final bool skipCanRefresh;

  /// if it should follow content for different state
  final ShouldFollowContent shouldFooterFollowWhenNotFull;

  /// when listView data small(not enough one page) , it should be hide
  final bool hideFooterWhenNotFull;

  /// header offset Y for layout
  final double headerOffset;

  /// whether footer can trigger load by reaching footerDistance when idle
  final bool autoLoad;

  /// whether user can drag viewport when twoLeveling
  final bool enableScrollWhenTwoLevel;

  /// whether user can drag viewport when refresh complete and spring back
  final bool enableScrollWhenRefreshCompleted;

  /// whether trigger refresh by  BallisticScrollActivity
  final bool enableBallisticRefresh;

  /// whether footer can trigger load by reaching footerDistance when failed state
  final bool enableLoadingWhenFailed;

  /// overScroll distance of trigger refresh
  final double headerTriggerDistance;

  ///	the overScroll distance of trigger twoLevel
  final double twiceTriggerDistance;

  /// Close the bottom crossing distance on the second floor, premise:enableScrollWhenTwoLevel is true
  final double closeTwoLevelDistance;

  /// the extentAfter distance of trigger loading
  final double footerTriggerDistance;

  /// the speed ratio when dragging overscroll ,compute=origin physics dragging speed *dragSpeedRatio
  final double dragSpeedRatio;

  /// max overScroll distance when out of edge
  final double maxOverScrollExtent;

  /// 	max underScroll distance when out of edge
  final double maxUnderScrollExtent;

  RefreshConfiguration({
    @required this.child,
    this.headerBuilder,
    this.footerBuilder,
    this.dragSpeedRatio: 1.0,
    this.shouldFooterFollowWhenNotFull,
    this.enableScrollWhenTwoLevel: true,
    this.enableBallisticRefresh: false,
    this.springDescription,
    this.enableScrollWhenRefreshCompleted: false,
    this.headerOffset: 0.0,
    this.enableLoadingWhenFailed: false,
    this.twiceTriggerDistance: 150.0,
    this.closeTwoLevelDistance: 80.0,
    this.skipCanRefresh: false,
    this.autoLoad: true,
    this.maxOverScrollExtent,
    this.maxUnderScrollExtent,
    this.headerTriggerDistance: 80.0,
    this.footerTriggerDistance: 15.0,
    this.hideFooterWhenNotFull: false,
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
        dragSpeedRatio != oldWidget.dragSpeedRatio ||
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
