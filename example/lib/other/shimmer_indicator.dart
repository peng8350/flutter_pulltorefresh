/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-07-08 10:51
 */
import 'package:flutter/material.dart' as prefix0;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:shimmer/shimmer.dart';
/*
   use to implements indicaotr
   https://github.com/hnvn/flutter_shimmer
   how to use?
   in ui/example/customindicator/shimmer_indicaotr.dart,
   it will show you how to use
 */

class ShimmerHeader extends RefreshIndicator {
  final Color baseColor, highlightColor;
  final Widget text;
  final Duration period;
  final ShimmerDirection direction;
  final Function outerBuilder;

  ShimmerHeader(
      {@required this.text,
      this.baseColor = Colors.grey,
      this.highlightColor = Colors.white,
      this.outerBuilder,
      double height: 80.0,
      this.period = const Duration(milliseconds: 1000),
      this.direction = ShimmerDirection.ltr})
      : super(height: height, refreshStyle: RefreshStyle.Behind);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ShimmerHeaderState();
  }
}

class _ShimmerHeaderState extends RefreshIndicatorState<ShimmerHeader>
    with TickerProviderStateMixin {
  AnimationController _scaleController;
  AnimationController _fadeController;

  @override
  void initState() {
    // TODO: implement initState
    _scaleController = AnimationController(vsync: this);
    _fadeController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void onOffsetChange(double offset) {
    // TODO: implement onOffsetChange
    if (!floating) {
      _scaleController.value = offset / configuration.headerTriggerDistance;
      _fadeController.value = offset / configuration.footerTriggerDistance;
    }
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus mode) {
    // TODO: implement buildContent

    final Widget body = ScaleTransition(
      scale: _scaleController,
      child: FadeTransition(
        opacity: _fadeController,
        child: mode == RefreshStatus.refreshing
            ? Shimmer.fromColors(
                period: widget.period,
                direction: widget.direction,
                baseColor: widget.baseColor,
                highlightColor: widget.highlightColor,
                child: Center(
                  child: widget.text,
                ),
              )
            : Center(
                child: widget.text,
              ),
      ),
    );
    return widget.outerBuilder != null
        ? widget.outerBuilder(body)
        : Container(
            alignment: prefix0.Alignment.center,
            child: body,
            decoration: prefix0.BoxDecoration(color: Colors.black12),
          );
  }
}

class ShimmerFooter extends LoadIndicator {
  final Color baseColor, highlightColor;
  final Widget text, failed, noMore;
  final Duration period;
  final ShimmerDirection direction;
  final Function outerBuilder;

  ShimmerFooter(
      {@required this.text,
      this.baseColor = Colors.grey,
      this.highlightColor = Colors.white,
      this.outerBuilder,
      double height: 80.0,
      this.failed,
      this.noMore,
      this.period = const Duration(milliseconds: 1000),
      this.direction = ShimmerDirection.ltr,
      LoadStyle loadStyle: LoadStyle.ShowAlways})
      : super(height: height, loadStyle: loadStyle);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ShimmerFooterState();
  }
}

class _ShimmerFooterState extends LoadIndicatorState<ShimmerFooter> {
  @override
  Widget buildContent(BuildContext context, LoadStatus mode) {
    // TODO: implement buildContent

    final Widget body = mode == LoadStatus.failed
        ? widget.failed
        : mode == LoadStatus.noMore
            ? widget.noMore
            : mode == LoadStatus.idle
                ? Center(child: widget.text)
                : Shimmer.fromColors(
                    period: widget.period,
                    direction: widget.direction,
                    baseColor: widget.baseColor,
                    highlightColor: widget.highlightColor,
                    child: Center(
                      child: widget.text,
                    ),
                  );
    return widget.outerBuilder != null
        ? widget.outerBuilder(body)
        : Container(
            height: widget.height,
            child: body,
            decoration: prefix0.BoxDecoration(color: Colors.black12),
          );
  }
}
