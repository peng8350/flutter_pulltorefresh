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

enum RefreshStatus { idle, canRefresh, refreshing, completed, failed }

enum LoadStatus { idle, loading, noMore }

enum RefreshStyle { Follow, UnFollow, Behind, Front }

const double default_refresh_triggerDistance = 80.0;

const double default_load_triggerDistance = 15.0;

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

  //This bool will affect whether or not to have the function of drop-down refresh.
  final bool enablePullDown;

  // upper and downer callback when you drag out of the distance
  final Function onRefresh, onLoading;

  // This method will callback when the indicator changes from edge to edge.
  final OnOffsetChange onOffsetChange;

  //controll inner state
  final RefreshController controller;

  final int headerInsertIndex;

  SmartRefresher(
      {Key key,
      @required this.child,
      @required this.controller,
      this.header,
      this.footer,
      this.enablePullDown: true,
      this.enablePullUp: false,
      this.onRefresh,
      this.onLoading,
      this.onOffsetChange,
      this.headerInsertIndex: 0})
      : assert(controller != null),
        super(key: key);

  @override
  SmartRefresherState createState() => SmartRefresherState();

  static SmartRefresherState of(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<SmartRefresherState>() ) ;
  }
}

class SmartRefresherState extends State<SmartRefresher> {
  RefreshConfiguration _configuration;
  RefreshIndicator _header;
  LoadIndicator _footer;

  void _updateController() {
    final Widget defaultHeader = (defaultTargetPlatform == TargetPlatform.iOS
        ? ClassicHeader()
        : MaterialClassicHeader());
    final child = widget.child;
    final Widget defaultFooter = ClassicFooter();
    _configuration = RefreshConfiguration.of(context);
    if(child!=null&&child is ScrollView&&child.controller!=null){
      widget.controller.scrollController = child.controller;
    }
    else{
      widget.controller.scrollController = PrimaryScrollController.of(context);
    }

    if (_configuration == null) {
      _header = widget.header ?? defaultHeader;
      ;
      _footer = widget.footer ?? defaultFooter;
    } else {
      if (_configuration.headerBuilder != null) {
        _header = widget.header ?? _configuration.headerBuilder();
      } else {
        _header = widget.header ?? defaultHeader;
      }
      if (_configuration.footerBuilder != null) {
        _footer = widget.footer ?? _configuration.footerBuilder();
      } else {
        _footer = widget.footer ?? defaultFooter;
      }
    }
    widget.controller._triggerDistance =
        _header.refreshStyle == RefreshStyle.Front
            ? 0.0
            : -(_configuration==null?80.0:_configuration.headerTriggerDistance);
  }

  void onPositionUpdated(ScrollPosition newPosition){
    widget.controller.position = newPosition;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.controller.initialRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.requestRefresh();
      });
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    _updateController();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(SmartRefresher oldWidget) {
    // TODO: implement didUpdateWidget
    if (widget.enablePullDown != oldWidget.enablePullDown) {
      widget.controller.headerMode.value = RefreshStatus.idle;
    }
    if (widget.enablePullUp != oldWidget.enablePullUp) {
      widget.controller.footerMode.value = LoadStatus.idle;
    }
    _updateController();
    super.didUpdateWidget(oldWidget);
  }

  ScrollPhysics _getScrollPhysics() {
    if (_header.refreshStyle == RefreshStyle.Front) {
      return widget.enablePullDown
          ? RefreshClampPhysics(springBackDistance: _header.height)
          : ClampingScrollPhysics();
    } else {
      return RefreshBouncePhysics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = widget.child;
    List<Widget> slivers;
    Widget body;
    if(child is ScrollView) {
      if (widget.child is BoxScrollView) {
        //avoid system inject padding when own indicator top or bottom
        Widget sliver = (widget.child as BoxScrollView).buildChildLayout(
            context);
        EdgeInsets effectPadding = (widget.child as BoxScrollView).padding;
        if (effectPadding == null) {
          final MediaQueryData mediaQuery = MediaQuery.of(
              context, nullOk: true);
          if (mediaQuery != null) {
            effectPadding = mediaQuery.padding.copyWith(
                left: 0.0,
                right: 0.0,
                top: widget.enablePullDown ? 0.0 : null,
                bottom: widget.enablePullUp ? 0.0 : null);
            sliver = MediaQuery(
              child: sliver,
              data: mediaQuery.copyWith(
                padding: effectPadding,
              ),
            );
          }
        }
        if (effectPadding != null) {
          sliver = SliverPadding(padding: effectPadding, sliver: sliver);
        }
        slivers = [sliver];
      } else  {
        slivers = List.from(child.buildSlivers(context), growable: true);
      }
      body =  CustomScrollView(
        physics: _getScrollPhysics(),
        controller: widget.controller.scrollController,
        cacheExtent: child?.cacheExtent,
        key: widget.child.key,
        semanticChildCount: child?.semanticChildCount,
        slivers: slivers,
        reverse: child?.reverse,
      );
    }
    else{
      slivers = [SliverToBoxAdapter(child: child ?? Container(),)];
      body =  CustomScrollView(
        physics: _getScrollPhysics(),
        controller: widget.controller.scrollController,
        key: widget.child?.key,
        slivers: slivers,
      );
    }
    assert(widget.headerInsertIndex < slivers.length);
    if (_header.refreshStyle == RefreshStyle.Front)
      assert(widget.headerInsertIndex == 0,
          "FrontStyle only support place in first slivers!");
    if (widget.enablePullDown) {
      slivers.insert(widget.headerInsertIndex, _header);
    }
    //insert header or footer
    if (widget.enablePullUp) {
      slivers.add(_footer);
    }

    if (_configuration != null) {
      return body;
    } else {
      return RefreshConfiguration(child: body);
    }
  }
}

class RefreshController {
  ValueNotifier<RefreshStatus> headerMode = ValueNotifier(RefreshStatus.idle);
  ValueNotifier<LoadStatus> footerMode = ValueNotifier(LoadStatus.idle);
  @Deprecated('use position instead,jumpTo and animateTo will lead to refresh together with mutiple ScrollView depend on the same ScrollController')
  ScrollController scrollController;
  ScrollPosition position;
  double _triggerDistance;

  final bool initialRefresh;

  RefreshStatus get headerStatus => headerMode?.value;

  LoadStatus get footerStatus => footerMode?.value;

  bool get isRefresh => headerMode?.value == RefreshStatus.refreshing;

  bool get isLoading => footerMode?.value == LoadStatus.loading;

  RefreshController({this.initialRefresh: false});

  void requestRefresh(
      {Duration duration: const Duration(milliseconds: 300),
      Curve curve: Curves.linear}) {
    assert(position != null,
        'Try not to call requestRefresh() before build,please call after the ui was rendered');
    if(isRefresh)return;
    position?.animateTo(_triggerDistance,
        duration: duration, curve: curve);

  }

  void requestLoading(
      {Duration duration: const Duration(milliseconds: 300),
      Curve curve: Curves.linear}) {
    assert(position != null,
        'Try not to call requestLoading() before build,please call after the ui was rendered');
      if(isLoading)return;
      position
          ?.animateTo(position.maxScrollExtent,
              duration: duration, curve: curve)
         ;
  }

  void refreshCompleted() {
    headerMode?.value = RefreshStatus.completed;
  }

  void refreshFailed() {
    headerMode?.value = RefreshStatus.failed;
  }

  void loadComplete() {
    // change state after ui update,else it will have a bug:twice loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      footerMode?.value = LoadStatus.idle;
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
  final bool clickLoadingWhenIdle;
  final bool autoLoad;
  final Widget child;
  final double headerTriggerDistance;
  final double footerTriggerDistance;

  RefreshConfiguration({
    @required this.child,
    this.headerBuilder,
    this.footerBuilder,
    this.headerOffset: 0.0,
    this.clickLoadingWhenIdle: false,
    this.skipCanRefresh: false,
    this.autoLoad: true,
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
        clickLoadingWhenIdle != oldWidget.clickLoadingWhenIdle ||
        oldWidget.runtimeType != runtimeType;
  }
}
