/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-01 11:39
*/

import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'internals/default_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:pull_to_refresh/src/internals/indicator_wrap.dart';
import 'package:pull_to_refresh/src/internals/refresh_physics.dart';
import 'indicator/classic_indicator.dart';
import 'indicator/material_indicator.dart';

typedef void OnOffsetChange(bool up, double offset);

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
      this.enablePullDown: default_enablePullDown,
      this.enablePullUp: default_enablePullUp,
      this.onRefresh,
      this.onLoading,
      this.onOffsetChange,
      this.headerInsertIndex:0})
      : assert(child != null),
        assert(controller != null),
        super(key: key);

  @override
  SmartRefresherState createState() => SmartRefresherState();

  static SmartRefresher of(BuildContext context) {
    return context.ancestorWidgetOfExactType(SmartRefresher) as SmartRefresher;
  }
}

class SmartRefresherState extends State<SmartRefresher> {
  IndicatorConfiguration _configuration;
  RefreshIndicator _header;
  LoadIndicator _footer;

  void _updateController() {
    _configuration = IndicatorConfiguration.of(context);
    widget.controller.scrollController =
        widget.child.controller ?? PrimaryScrollController.of(context);
    if (_configuration == null) {
      _header = widget.header ??
          (defaultTargetPlatform == TargetPlatform.iOS
              ? ClassicHeader()
              : MaterialClassicHeader());
      _footer = widget.footer ?? ClassicFooter();
    } else {
      if (_configuration.headerBuilder != null) {
        _header = widget.header ?? _configuration.headerBuilder();
      } else {
        _header = widget.header ??
            (defaultTargetPlatform == TargetPlatform.iOS
                ? ClassicHeader()
                : MaterialClassicHeader());
      }
      if (_configuration.footerBuilder != null) {
        _footer = widget.footer ?? _configuration.footerBuilder();
      } else {
        _footer = widget.footer ?? ClassicFooter();
      }
    }
    widget.controller._header = _header;

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
    List<Widget> slivers;
    if (widget.child is BoxScrollView) {
      //avoid system inject padding when own indicator top or bottom
      Widget sliver = (widget.child as BoxScrollView).buildChildLayout(context);
      EdgeInsets effectPadding = (widget.child as BoxScrollView).padding;
      if (effectPadding == null) {
        final MediaQueryData mediaQuery = MediaQuery.of(context, nullOk: true);
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
    } else {
      slivers = List.from(widget.child.buildSlivers(context), growable: true);
    }
    assert(widget.headerInsertIndex<slivers.length);
    if(_header.refreshStyle==RefreshStyle.Front)
    assert(widget.headerInsertIndex==0,"FrontStyle only support place in first slivers!");
    if (widget.enablePullDown) {
      slivers.insert(widget.headerInsertIndex, _header);
    }
    //insert header or footer
    if (widget.enablePullUp) {
      slivers.add(_footer);
    }

    return CustomScrollView(
      physics: _getScrollPhysics(),
      controller: widget.controller.scrollController,
      cacheExtent: widget.child.cacheExtent,
      key: widget.child.key,
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

  final bool initialRefresh;

  RefreshStatus get headerStatus => headerMode?.value;

  LoadStatus get footerStatus => footerMode?.value;

  bool get isRefresh => headerMode?.value == RefreshStatus.refreshing;

  bool get isLoading => footerMode?.value == LoadStatus.loading;

  RefreshController({this.initialRefresh: false});

  void requestRefresh(
      {Duration duration: const Duration(milliseconds: 300),
      Curve curve: Curves.linear}) {
    assert(scrollController != null,
        'Try not to call requestRefresh() before build,please call after the ui was rendered');
    if (headerMode?.value != RefreshStatus.idle) return;
    scrollController.animateTo(
        _header.refreshStyle == RefreshStyle.Front
            ? 0.0
            : -_header.triggerDistance,
        duration: duration,
        curve: curve);
  }

  void requestLoading(
      {Duration duration: const Duration(milliseconds: 300),
      Curve curve: Curves.linear}) {
    assert(scrollController != null,
        'Try not to call requestLoading() before build,please call after the ui was rendered');
    if (footerStatus == LoadStatus.idle) {
      if (_header.refreshStyle == RefreshStyle.Front) {
        if (scrollController.position.maxScrollExtent - _header.height < 0.0) {
          footerMode.value = LoadStatus.loading;
        } else
          scrollController
              .animateTo(scrollController.position.maxScrollExtent,
                  duration: duration, curve: curve)
              .whenComplete(() {
            footerMode.value = LoadStatus.loading;
          });
      } else {
        scrollController
            .animateTo(scrollController.position.maxScrollExtent,
                duration: duration, curve: curve)
            .whenComplete(() {
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

typedef IndicatorBuilder = Indicator Function();

class IndicatorConfiguration extends InheritedWidget {
  final IndicatorBuilder headerBuilder;
  final IndicatorBuilder footerBuilder;
  final Widget child;

  IndicatorConfiguration({
    @required this.child,
    this.headerBuilder,
    this.footerBuilder,
  });

  static IndicatorConfiguration of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(IndicatorConfiguration);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
