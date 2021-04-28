/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-08-02 19:20
 */

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:pull_to_refresh/src/internals/indicator_wrap.dart';
import 'dart:math' as math;
import 'package:flutter/physics.dart';

enum BezierDismissType { None, RectSpread, ScaleToCenter }

enum BezierCircleType { Raidal, Progress }

/// bezier container,if you need to implements indicator with bezier ,you can use consider about use this
/// this will add the bezier container effect
///
/// See also:
///
/// [BezierCircleHeader], bezier container +circle progress indicator
class BezierHeader extends RefreshIndicator {
  final OffsetCallBack? onOffsetChange;
  final ModeChangeCallBack? onModeChange;
  final VoidFutureCallBack? readyRefresh, endRefresh;
  final VoidCallback? onResetValue;
  final Color? bezierColor;
  // decide how to behave when bezier is ready to dismiss
  final BezierDismissType dismissType;
  final bool enableChildOverflow;
  final Widget child;
  // container height(not contain bezier)
  final double rectHeight;

  BezierHeader(
      {this.child: const Text(""),
      this.onOffsetChange,
      this.onModeChange,
      this.readyRefresh,
      this.enableChildOverflow: false,
      this.endRefresh,
      this.onResetValue,
      this.dismissType: BezierDismissType.RectSpread,
      this.rectHeight: 70,
      this.bezierColor})
      : super(refreshStyle: RefreshStyle.UnFollow, height: rectHeight);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BezierHeaderState();
  }
}

class _BezierHeaderState extends RefreshIndicatorState<BezierHeader>
    with TickerProviderStateMixin {
  late AnimationController _beizerBounceCtl, _bezierDismissCtl;

  @override
  void initState() {
    // TODO: implement initState
    _beizerBounceCtl = AnimationController(
        vsync: this, lowerBound: -10, upperBound: 50, value: 0);
    _bezierDismissCtl = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void onOffsetChange(double offset) {
    // TODO: implement onOffsetChange
    if (widget.onOffsetChange != null) {
      widget.onOffsetChange!(offset);
    }
    if (!_beizerBounceCtl.isAnimating || (!floating))
      _beizerBounceCtl.value = math.max(0, offset - widget.rectHeight);
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
  void dispose() {
    // TODO: implement dispose
    _bezierDismissCtl.dispose();
    _beizerBounceCtl.dispose();
    super.dispose();
  }

  @override
  Future<void> readyToRefresh() {
    // TODO: implement readyToRefresh
    final Simulation simulation = SpringSimulation(
        SpringDescription(
          mass: 3.4,
          stiffness: 10000.5,
          damping: 6,
        ),
        _beizerBounceCtl.value,
        0,
        1000);
    _beizerBounceCtl.animateWith(simulation);
    if (widget.readyRefresh != null) {
      return widget.readyRefresh!();
    }
    return super.readyToRefresh();
  }

  @override
  Future<void> endRefresh() async {
    // TODO: implement endRefresh
    if (widget.endRefresh != null) {
      await widget.endRefresh!();
    }
    return _bezierDismissCtl.animateTo(1.0,
        duration: Duration(milliseconds: 200));
  }

  @override
  void resetValue() {
    // TODO: implement resetValue
    _bezierDismissCtl.reset();
    _beizerBounceCtl.value = 0;
    if (widget.onResetValue != null) {
      widget.onResetValue!();
    }
    super.resetValue();
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    // TODO: implement buildContent

    return AnimatedBuilder(
      builder: (_, __) {
        return Stack(
          children: <Widget>[
            Positioned(
              child: AnimatedBuilder(
                builder: (_, __) {
                  return ClipPath(
                    child: ClipPath(
                      child: Container(
                        height: widget.rectHeight + 30,
                        color: widget.bezierColor ??
                            Theme.of(context).primaryColor,
                      ),
                      clipper: _BezierPainter(
                          value: _beizerBounceCtl.value,
                          startOffsetY: widget.rectHeight),
                    ),
                    clipper: _BezierDismissPainter(
                        value: _bezierDismissCtl.value,
                        dismissType: widget.dismissType),
                  );
                },
                animation: _bezierDismissCtl,
              ),
              bottom: -50,
              top: 0,
              left: 0,
              right: 0,
            ),
            !widget.enableChildOverflow
                ? ClipRect(
                    child: Container(
                      height: (_beizerBounceCtl.isAnimating ||
                                  mode == RefreshStatus.refreshing
                              ? 0
                              : math.max(0, _beizerBounceCtl.value)) +
                          widget.rectHeight,
                      child: widget.child,
                    ),
                  )
                : Container(
                    height: (_beizerBounceCtl.isAnimating ||
                                mode == RefreshStatus.refreshing
                            ? 0
                            : math.max(0, _beizerBounceCtl.value)) +
                        widget.rectHeight,
                    child: widget.child,
                  ),
          ],
        );
      },
      animation: _beizerBounceCtl,
    );
  }
}

class _BezierDismissPainter extends CustomClipper<Path> {
  final BezierDismissType? dismissType;

  final double? value;

  _BezierDismissPainter({this.dismissType, this.value});

  @override
  getClip(Size size) {
    // TODO: implement getClip
    Path path = Path();
    if (dismissType == BezierDismissType.None || value == 0) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, 0);
    } else if (dismissType == BezierDismissType.RectSpread) {
      Path path1 = Path();
      Path path2 = Path();
      double halfWidth = size.width / 2;
      path1.moveTo(0, 0);
      path1.lineTo(halfWidth - value! * halfWidth, 0);
      path1.lineTo(halfWidth - value! * halfWidth, size.height);
      path1.lineTo(0, size.height);
      path1.lineTo(0, 0);

      path2.moveTo(size.width, 0);
      path2.lineTo(halfWidth + value! * halfWidth, 0);
      path2.lineTo(halfWidth + value! * halfWidth, size.height);
      path2.lineTo(size.width, size.height);
      path2.lineTo(size.width, 0);
      path.addPath(path1, Offset(0, 0));
      path.addPath(path2, Offset(0, 0));
    } else {
      final double maxExtent =
          math.max(size.width, size.height) * (1.0 - value!);
      final double centerX = size.width / 2;
      final double centerY = size.height / 2;
      path.addOval(Rect.fromCircle(
          center: Offset(centerX, centerY), radius: maxExtent / 2));
    }
    return path;
  }

  @override
  bool shouldReclip(_BezierDismissPainter oldClipper) {
    // TODO: implement shouldReclip
    return dismissType != oldClipper.dismissType || value != oldClipper.value;
  }
}

class _BezierPainter extends CustomClipper<Path> {
  final double? startOffsetY;

  final double? value;

  _BezierPainter({this.value, this.startOffsetY});

  @override
  getClip(Size size) {
    // TODO: implement getClip
    Path path = Path();
    path.lineTo(0, startOffsetY!);
    path.quadraticBezierTo(
        size.width / 2, startOffsetY! + value! * 2, size.width, startOffsetY!);
    path.moveTo(size.width, startOffsetY!);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    return path;
  }

  @override
  bool shouldReclip(_BezierPainter oldClipper) {
    // TODO: implement shouldReclip
    return value != oldClipper.value;
  }
}

/// bezier + circle indicator,you can use this directly
///
///simple usage
///```dart
///header: BezierCircleHeader(
///bezierColor: Colors.red,
///circleColor: Colors.amber,
///dismissType: BezierDismissType.ScaleToCenter,
///circleType: BezierCircleType.Raidal,
///)
///```
class BezierCircleHeader extends StatefulWidget {
  final Color? bezierColor;
  // two style:radial or progress
  final BezierCircleType circleType;

  final double rectHeight;

  final Color circleColor;

  final double circleRadius;

  final bool enableChildOverflow;

  final BezierDismissType dismissType;

  BezierCircleHeader(
      {this.bezierColor,
      this.rectHeight: 70,
      this.circleColor: Colors.white,
      this.enableChildOverflow: false,
      this.dismissType: BezierDismissType.RectSpread,
      this.circleType: BezierCircleType.Progress,
      this.circleRadius: 12});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BezierCircleHeaderState();
  }
}

class _BezierCircleHeaderState extends State<BezierCircleHeader>
    with TickerProviderStateMixin {
  RefreshStatus mode = RefreshStatus.idle;
  late AnimationController _childMoveCtl;
  late Tween<AlignmentGeometry?> _childMoveTween;
  late AnimationController _dismissCtrl;
  late Tween<Offset> _disMissTween;
  late AnimationController _radialCtrl;

  @override
  void initState() {
    // TODO: implement initState
    _dismissCtrl = AnimationController(vsync: this);
    _childMoveCtl = AnimationController(vsync: this);
    _radialCtrl =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _childMoveTween = AlignmentGeometryTween(
        begin: Alignment.bottomCenter, end: Alignment.center);
    _disMissTween =
        Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(0.0, 1.5));
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _dismissCtrl.dispose();
    _childMoveCtl.dispose();
    _radialCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BezierHeader(
      bezierColor: widget.bezierColor,
      rectHeight: widget.rectHeight,
      dismissType: widget.dismissType,
      enableChildOverflow: widget.enableChildOverflow,
      readyRefresh: () async {
        await _childMoveCtl.animateTo(1.0,
            duration: Duration(milliseconds: 300));
      },
      onResetValue: () {
        _dismissCtrl.value = 0;
        _childMoveCtl.reset();
      },
      onModeChange: (m) {
        mode = m;
        if (m == RefreshStatus.refreshing)
          _radialCtrl.repeat(period: Duration(milliseconds: 500));
        setState(() {});
      },
      endRefresh: () async {
        _radialCtrl.reset();
        await _dismissCtrl.animateTo(1, duration: Duration(milliseconds: 550));
      },
      child: SlideTransition(
        position: _disMissTween.animate(_dismissCtrl),
        child: AlignTransition(
          child: widget.circleType == BezierCircleType.Progress
              ? Container(
                  height: widget.circleRadius * 2 + 5,
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Container(
                          height: widget.circleRadius * 2,
                          decoration: BoxDecoration(
                              color: widget.circleColor,
                              shape: BoxShape.circle),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          child: CircularProgressIndicator(
                            valueColor: mode == RefreshStatus.refreshing
                                ? AlwaysStoppedAnimation(widget.circleColor)
                                : AlwaysStoppedAnimation(Colors.transparent),
                            strokeWidth: 2,
                          ),
                          height: widget.circleRadius * 2 + 5,
                          width: widget.circleRadius * 2 + 5,
                        ),
                      )
                    ],
                  ),
                )
              : AnimatedBuilder(
                  builder: (_, __) {
                    return Container(
                      height: widget.circleRadius * 2,
                      child: CustomPaint(
                        painter: _RaidalPainter(
                            value: _radialCtrl.value,
                            circleColor: widget.circleColor,
                            circleRadius: widget.circleRadius,
                            refreshing: mode == RefreshStatus.refreshing),
                      ),
                    );
                  },
                  animation: _radialCtrl,
                ),
          alignment: _childMoveCtl
              .drive(_childMoveTween as Animatable<AlignmentGeometry>),
        ),
      ),
    );
  }
}

class _RaidalPainter extends CustomPainter {
  final double? value;

  final Color? circleColor;

  final double? circleRadius;

  final bool? refreshing;

  _RaidalPainter(
      {this.value, this.circleColor, this.circleRadius, this.refreshing});

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    Paint paint = Paint();
    paint.color = circleColor!;
    paint.strokeWidth = 2;
    paint.strokeCap = StrokeCap.round;
    paint.style = PaintingStyle.stroke;
    if (refreshing!) {
      canvas.drawArc(
          Rect.fromCircle(
              center: Offset(size.width / 2, size.height / 2),
              radius: circleRadius! + 3),
          -math.pi / 2,
          math.pi * 4,
          false,
          paint);
    }
    paint.style = PaintingStyle.fill;
    canvas.drawArc(
        Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: circleRadius!),
        -math.pi / 2,
        math.pi * 4,
        true,
        paint);
    paint.color = Color.fromRGBO(233, 233, 233, 0.8);
    canvas.drawArc(
        Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: circleRadius!),
        -math.pi / 2,
        math.pi * 4 * value!,
        true,
        paint);
    paint.style = PaintingStyle.stroke;
    if (refreshing!) {
      canvas.drawArc(
          Rect.fromCircle(
              center: Offset(size.width / 2, size.height / 2),
              radius: circleRadius! + 3),
          -math.pi / 2,
          math.pi * 4 * value!,
          false,
          paint);
    }
  }

  @override
  bool shouldRepaint(_RaidalPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return value != oldDelegate.value;
  }
}
