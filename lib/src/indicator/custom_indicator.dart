/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/4 下午9:49
 */

import 'package:flutter/widgets.dart';
import '../internals/indicator_wrap.dart';
import '../smart_refresher.dart';

/// custom header builder,you can use second paramter to know what header state is
typedef Widget HeaderBuilder(BuildContext context, RefreshStatus? mode);

/// custom footer builder,you can use second paramter to know what footerr state is
typedef Widget FooterBuilder(BuildContext context, LoadStatus? mode);

/// a custom Indicator for header
///
/// here is the very simple usage
///
/// ```dart
/// CustomHeader(
///      builder: (context,mode){
///        Widget body;
///        if(mode==RefreshStatus.idle){
///          body = Text("pull down refresh");
///        }
///       else if(mode==RefreshStatus.refreshing){
///          body = CupertinoActivityIndicator();
///        }
///        else if(mode==RefreshStatus.canRefresh){
///          body = Text("release to refresh");
///        }
///        else if(mode==RefreshStatus.completed){
///          body = Text("refreshCompleted!");
///       }
///        return Container(
///          height: 60.0,
///          child: Center(
///            child: body,
///          ),
///       );
///      },
///    )
/// ```
/// If you need to listen overScroll event do some animate,you should use [OnOffsetChange] callback in [SmartRefresher]
/// finally,If your indicator contain more complex animation and need to update frequently ,I suggest you extends [RefreshIndicator] to implements
///
/// See also
///
/// [CustomFooter], a custom Indicator for footer
class CustomHeader extends RefreshIndicator {
  final HeaderBuilder builder;

  final VoidFutureCallBack? readyToRefresh;

  final VoidFutureCallBack? endRefresh;

  final OffsetCallBack? onOffsetChange;

  final ModeChangeCallBack<RefreshStatus>? onModeChange;

  final VoidCallback? onResetValue;

  const CustomHeader({
    Key? key,
    required this.builder,
    this.readyToRefresh,
    this.endRefresh,
    this.onOffsetChange,
    this.onModeChange,
    this.onResetValue,
    double height: 60.0,
    Duration completeDuration: const Duration(milliseconds: 600),
    RefreshStyle refreshStyle: RefreshStyle.Follow,
  }) : super(
            key: key,
            completeDuration: completeDuration,
            refreshStyle: refreshStyle,
            height: height);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CustomHeaderState();
  }
}

class _CustomHeaderState extends RefreshIndicatorState<CustomHeader> {
  @override
  void onOffsetChange(double offset) {
    // TODO: implement onOffsetChange
    if (widget.onOffsetChange != null) {
      widget.onOffsetChange!(offset);
    }
    super.onOffsetChange(offset);
  }

  @override
  void onModeChange(RefreshStatus? mode) {
    // TODO: implement onModeChange
    if (widget.onModeChange != null) {
      widget.onModeChange!(mode);
    }
    super.onModeChange(mode);
  }

  @override
  Future<void> readyToRefresh() {
    // TODO: implement endRefresh
    if (widget.readyToRefresh != null) {
      return widget.readyToRefresh!();
    }
    return super.readyToRefresh();
  }

  @override
  Future<void> endRefresh() {
    // TODO: implement endRefresh
    if (widget.endRefresh != null) {
      return widget.endRefresh!();
    }
    return super.endRefresh();
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    // TODO: implement buildContent
    return widget.builder(context, mode);
  }
}

/// a custom Indicator for footer,the usage I have put in [CustomHeader],same with that
/// See also
///
/// [CustomHeader], a custom Indicator for header
class CustomFooter extends LoadIndicator {
  final FooterBuilder builder;

  final OffsetCallBack? onOffsetChange;

  final ModeChangeCallBack? onModeChange;

  final VoidFutureCallBack? readyLoading;

  final VoidFutureCallBack? endLoading;

  const CustomFooter({
    Key? key,
    double height: 60.0,
    this.onModeChange,
    this.onOffsetChange,
    this.readyLoading,
    this.endLoading,
    LoadStyle loadStyle: LoadStyle.ShowAlways,
    required this.builder,
    Function? onClick,
  }) : super(
            key: key,
            onClick: onClick as void Function()?,
            loadStyle: loadStyle,
            height: height);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CustomFooterState();
  }
}

class _CustomFooterState extends LoadIndicatorState<CustomFooter> {
  @override
  void onOffsetChange(double offset) {
    // TODO: implement onOffsetChange
    if (widget.onOffsetChange != null) {
      widget.onOffsetChange!(offset);
    }
    super.onOffsetChange(offset);
  }

  @override
  void onModeChange(LoadStatus? mode) {
    // TODO: implement onModeChange
    if (widget.onModeChange != null) {
      widget.onModeChange!(mode);
    }
    super.onModeChange(mode);
  }

  @override
  Future readyToLoad() {
    // TODO: implement readyToLoad
    if (widget.readyLoading != null) {
      return widget.readyLoading!();
    }
    return super.readyToLoad();
  }

  @override
  Future endLoading() {
    // TODO: implement endLoading
    if (widget.endLoading != null) {
      return widget.endLoading!();
    }
    return super.endLoading();
  }

  @override
  Widget buildContent(BuildContext context, LoadStatus? mode) {
    // TODO: implement buildContent
    return widget.builder(context, mode);
  }
}
