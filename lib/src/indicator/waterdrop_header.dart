/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/5 下午2:37
 */

import 'dart:async';
import 'package:flutter/material.dart' hide RefreshIndicatorState, RefreshIndicator;
import 'package:flutter/foundation.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/cupertino.dart';

/// QQ ios refresh header effect
class WaterDropHeader extends RefreshIndicator {
  /// refreshing content
  final Widget? refresh;

  /// complete content
  final Widget? complete;

  /// failed content
  final Widget? failed;

  /// idle Icon center in waterCircle
  final Widget idleIcon;

  /// waterDrop color,default grey
  final Color waterDropColor;

  // Color of the loading indicator, uses system default if not specified.
  final Color? loadingIndicatorColor;

  // Color of text and icons, defaults to grey.
  final Color textColor;

  const WaterDropHeader({
    Key? key,
    this.refresh,
    this.complete,
    Duration completeDuration: const Duration(milliseconds: 600),
    this.failed,
    this.waterDropColor: Colors.grey,
    this.loadingIndicatorColor,
    this.textColor: Colors.grey,
    this.idleIcon: const Icon(
      Icons.autorenew,
      size: 15,
      color: Colors.white,
    ),
  }) : super(
          key: key,
          height: 60.0,
          completeDuration: completeDuration,
          refreshStyle: RefreshStyle.UnFollow,
        );

  @override
  State<StatefulWidget> createState() => _WaterDropHeaderState();
}

class _WaterDropHeaderState extends RefreshIndicatorState<WaterDropHeader>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  late AnimationController _dismissCtl;

  @override
  void onOffsetChange(double offset) {
    final double realOffset = offset - 44.0; //55.0 mean circleHeight(24) + originH (20) in Painter
    // when readyTorefresh
    if (!_animationController!.isAnimating) _animationController!.value = realOffset;
  }

  @override
  Future<void> readyToRefresh() {
    _dismissCtl.animateTo(0.0);
    return _animationController!.animateTo(0.0);
  }

  @override
  void initState() {
    _dismissCtl =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400), value: 1.0);
    _animationController = AnimationController(
        vsync: this, lowerBound: 0.0, upperBound: 50.0, duration: Duration(milliseconds: 400));
    super.initState();
  }

  @override
  bool needReverseAll() {
    // TODO: implement needReverseAll
    return false;
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    // TODO: implement buildContent
    Widget? child;
    if (mode == RefreshStatus.refreshing) {
      child = widget.refresh ??
          SizedBox(
            width: 25.0,
            height: 25.0,
            child: defaultTargetPlatform == TargetPlatform.iOS
                ? CupertinoActivityIndicator(
                    color: widget.loadingIndicatorColor,
                  )
                : CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: widget.loadingIndicatorColor,
                  ),
          );
    } else if (mode == RefreshStatus.completed) {
      child = widget.complete ??
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.done,
                color: widget.textColor,
              ),
              Container(
                width: 15.0,
              ),
              Text(
                (RefreshLocalizations.of(context)?.currentLocalization ?? EnRefreshString())
                    .refreshCompleteText!,
                style: TextStyle(color: widget.textColor),
              )
            ],
          );
    } else if (mode == RefreshStatus.failed) {
      child = widget.failed ??
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.close,
                color: widget.textColor,
              ),
              Container(
                width: 15.0,
              ),
              Text(
                  (RefreshLocalizations.of(context)?.currentLocalization ?? EnRefreshString())
                      .refreshFailedText!,
                  style: TextStyle(color: widget.textColor))
            ],
          );
    } else if (mode == RefreshStatus.idle || mode == RefreshStatus.canRefresh) {
      return FadeTransition(
          child: Container(
            child: Stack(
              children: <Widget>[
                RotatedBox(
                  child: CustomPaint(
                    child: Container(
                      height: 60.0,
                    ),
                    painter: _QqPainter(
                      color: widget.waterDropColor,
                      listener: _animationController,
                    ),
                  ),
                  quarterTurns: Scrollable.of(context)!.axisDirection == AxisDirection.up ? 10 : 0,
                ),
                Container(
                  alignment: Scrollable.of(context)!.axisDirection == AxisDirection.up
                      ? Alignment.bottomCenter
                      : Alignment.topCenter,
                  margin: Scrollable.of(context)!.axisDirection == AxisDirection.up
                      ? EdgeInsets.only(bottom: 12.0)
                      : EdgeInsets.only(top: 12.0),
                  child: widget.idleIcon,
                )
              ],
            ),
            height: 60.0,
          ),
          opacity: _dismissCtl);
    }
    return Container(
      height: 60.0,
      child: Center(
        child: child,
      ),
    );
  }

  @override
  void resetValue() {
    _animationController!.reset();
    _dismissCtl.value = 1.0;
  }

  @override
  void dispose() {
    _dismissCtl.dispose();
    _animationController!.dispose();
    super.dispose();
  }
}

class _QqPainter extends CustomPainter {
  final Color? color;
  final Animation<double>? listener;

  double get value => listener!.value;
  final Paint painter = Paint();

  _QqPainter({this.color, this.listener}) : super(repaint: listener);

  @override
  void paint(Canvas canvas, Size size) {
    final double originH = 20.0;
    final double middleW = size.width / 2;

    final double circleSize = 12.0;

    final double scaleRatio = 0.1;

    final double offset = value;

    painter.color = color!;
    canvas.drawCircle(Offset(middleW, originH), circleSize, painter);
    Path path = Path();
    path.moveTo(middleW - circleSize, originH);

    //drawleft
    path.cubicTo(middleW - circleSize, originH, middleW - circleSize + value * scaleRatio,
        originH + offset / 5, middleW - circleSize + value * scaleRatio * 2, originH + offset);
    path.lineTo(middleW + circleSize - value * scaleRatio * 2, originH + offset);
    //draw right
    path.cubicTo(
        middleW + circleSize - value * scaleRatio * 2,
        originH + offset,
        middleW + circleSize - value * scaleRatio,
        originH + offset / 5,
        middleW + circleSize,
        originH);
    //draw upper circle
    path.moveTo(middleW - circleSize, originH);
    path.arcToPoint(Offset(middleW + circleSize, originH), radius: Radius.circular(circleSize));

    //draw lower circle
    path.moveTo(middleW + circleSize - value * scaleRatio * 2, originH + offset);
    path.arcToPoint(Offset(middleW - circleSize + value * scaleRatio * 2, originH + offset),
        radius: Radius.circular(value * scaleRatio));
    path.close();
    canvas.drawPath(path, painter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
