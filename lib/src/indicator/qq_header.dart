/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/5 下午2:37
 */

import 'dart:async';

import 'package:flutter/material.dart'
    hide RefreshIndicatorState, RefreshIndicator;
import '../internals/indicator_wrap.dart';
import 'package:flutter/cupertino.dart';
import '../smart_refresher.dart';

class QqHeader extends RefreshIndicator {
  final Widget refresh;

  final Widget complete;

  final Widget failed;

  final Widget idleIcon;

  final bool reverse;

  QqHeader({
    Key key,
    this.refresh,
    this.reverse: false,
    this.complete,
    this.failed,
    this.idleIcon,
    double triggerDistance: 110.0,
  }) : super(
            key: key,
            triggerDistance: triggerDistance,
            refreshStyle: RefreshStyle.UnFollow);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _QqHeaderState();
  }
}

class _QqHeaderState extends RefreshIndicatorState<QqHeader>
    with TickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void onOffsetChange(double offset) {
    // TODO: implement onOffsetChange
    final double realOffset =
        offset - 55.0; //55.0 mean circleHeight(30) + originH (25) in Painter
    // when readyTorefresh
    if (!_animationController.isAnimating)
      _animationController.value = realOffset;
    super.onOffsetChange(offset);
  }

  @override
  Future<void> readyToRefresh() {
    // TODO: implement readyToRefresh
//    update();
    floating = true;
    update();
    return _animationController.animateTo(0.0);
  }

  @override
  void initState() {
    // TODO: implement initState
    _animationController = AnimationController(
        vsync: this,
        lowerBound: 0.0,
        upperBound: 50.0,
        duration: Duration(milliseconds: 400));
    super.initState();
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus mode) {
    // TODO: implement buildContent
    Widget child;
    if (mode == RefreshStatus.refreshing) {
      if (widget.refresh != null) child = widget.refresh;
      child = CupertinoActivityIndicator();
    } else if (mode == RefreshStatus.completed) {
      if (widget.complete != null) child = widget.complete;
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.done,
            color: Colors.grey,
          ),
          Container(
            width: 15.0,
          ),
          Text(
            "刷新完成",
            style: TextStyle(color: Colors.grey),
          )
        ],
      );
    } else if (mode == RefreshStatus.failed) {
      if (widget.failed != null) child = widget.failed;
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.close,
            color: Colors.grey,
          ),
          Container(
            width: 15.0,
          ),
          Text("刷新失败", style: TextStyle(color: Colors.grey))
        ],
      );
    } else if (mode == RefreshStatus.idle || mode == RefreshStatus.canRefresh) {
      return Container(
        height: 80.0,
        color: Theme.of(context).appBarTheme.color,
        child: CustomPaint(
          child: Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.only(top: 15.0),
            child: widget.idleIcon != null
                ? widget.idleIcon
                : const Icon(
                    Icons.airplanemode_active,
                    size: 15,
                    color: Colors.white,
                  ),
          ),
          painter: _QqPainter(
              color: Colors.grey,
              value: _animationController.value,
              reverse: widget.reverse),
        ),
      );
    }
    return Container(
      height: 60.0,
      child: Center(
        child: child,
      ),
    );
  }
}

class _QqPainter extends CustomPainter {
  final Color color;
  final double value;
  final Paint painter = Paint();
  final bool reverse;
  _QqPainter({this.color, this.value, this.reverse});

  @override
  void paint(Canvas canvas, Size size) {
    final double originH = 25.0;

    final double middleW = size.width / 2;

    final double circleSize = 15.0;

    final double scaleRatio = 0.1;

    final double offset = reverse ? -value : value;

    painter.color = color;
//    canvas.drawCircle(Offset(middleW, originH), 15.0, painter);
    Path path = Path();
    path.moveTo(middleW - circleSize, originH);

    //drawleft
    path.cubicTo(
        middleW - circleSize,
        originH,
        middleW - circleSize + value * scaleRatio,
        originH + offset / 5,
        middleW - circleSize + value * scaleRatio * 2,
        originH + offset);
    path.lineTo(
        middleW + circleSize - value * scaleRatio * 2, originH + offset);
    //draw right
    path.cubicTo(
        middleW + circleSize - value * scaleRatio * 2,
        originH + offset,
        middleW + circleSize - value * scaleRatio,
        originH + offset / 5,
        middleW + circleSize,
        originH);
    //draw upper circle
    if (!reverse) {
      path.moveTo(middleW - circleSize, originH);
      path.arcToPoint(Offset(middleW + circleSize, originH),
          radius: Radius.circular(circleSize));

      //draw lowwer circle
      path.moveTo(
          middleW + circleSize - value * scaleRatio * 2, originH + offset);
      path.arcToPoint(
          Offset(
              middleW - circleSize + value * scaleRatio * 2, originH + offset),
          radius: Radius.circular( value * scaleRatio));
    } else {
      path.moveTo(middleW + circleSize, originH);
      path.arcToPoint(Offset(middleW - circleSize, originH),
          radius: Radius.circular(circleSize));

      //draw lowwer circle

      path.moveTo(
          middleW - circleSize + value * scaleRatio * 2, originH + offset);
      path.arcToPoint(
          Offset(
              middleW + circleSize - value * scaleRatio * 2, originH + offset),
          radius: Radius.circular(value*scaleRatio));
    }

    path.close();
    canvas.drawPath(path, painter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return oldDelegate != this;
  }
}
