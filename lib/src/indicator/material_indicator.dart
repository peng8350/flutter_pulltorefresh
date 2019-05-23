/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/19 下午9:23
 */

import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import '../../pull_to_refresh.dart';

// How much the scroll's drag gesture can overshoot the RefreshIndicator's
// displacement; max displacement = _kDragSizeFactorLimit * displacement.
const double _kDragSizeFactorLimit = 1.5;

class MaterialClassicHeader extends RefreshIndicator {
  final String semanticsLabel;
  final String semanticsValue;
  final Color color;
  final double distance;
  final Color backgroundColor;

  const MaterialClassicHeader({
    Key key,
    this.semanticsLabel,
    this.semanticsValue,
    double offset: 0.0,
    this.color,
    this.distance: 50.0,
    this.backgroundColor,
  }) : super(
          key: key,
          refreshStyle: RefreshStyle.Front,
          height: 100.0,
          offset: offset,
        );

  const MaterialClassicHeader.asSliver({
    Key key,
    @required OnRefresh onRefresh,
    bool offStage:false,
    this.semanticsLabel,
    this.semanticsValue,
    double offset: 0.0,
    this.color,
    this.distance: 50.0,
    this.backgroundColor,
  }) : super(
          key: key,
          onRefresh: onRefresh,
          offStage:offStage,
          refreshStyle: RefreshStyle.Front,
          height: 100.0,
          offset: offset,
        );

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return _MaterialClassicHeaderState();
  }
}

class _MaterialClassicHeaderState
    extends RefreshIndicatorState<MaterialClassicHeader>
    with TickerProviderStateMixin {
  Animation<Offset> _positionFactor;
  Animation<Color> _valueColor;
  AnimationController _scaleFactor;
  AnimationController _positionController;
  AnimationController _valueAni;

  @override
  void initState() {
    // TODO: implement initState
    _valueAni = AnimationController(
        vsync: this,
        value: 0.0,
        lowerBound: 0.0,
        upperBound: 1.0,
        duration: Duration(milliseconds: 500));
    _positionController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _scaleFactor = AnimationController(
        vsync: this,
        value: 1.0,
        lowerBound: 0.0,
        upperBound: 1.0,
        duration: Duration(milliseconds: 300));
    _positionFactor = _positionController.drive(Tween<Offset>(
        begin: Offset(0.0, -40.0 / widget.height), end: Offset(0.0, 1.0)));
    super.initState();
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus mode) {
    // TODO: implement buildContent
    return SlideTransition(
      child: ScaleTransition(
        scale: _scaleFactor,
        child: Align(
          alignment: Alignment.topCenter,
          child: RefreshProgressIndicator(
            semanticsLabel: widget.semanticsLabel ??
                MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
            semanticsValue: widget.semanticsValue,
            value: floating ? null : _valueAni.value,
            valueColor: _valueColor,
            backgroundColor: widget.backgroundColor,
          ),
        ),
      ),
      position: _positionFactor,
    );
  }

  @override
  void onOffsetChange(double offset) {
    // TODO: implement onOffsetChange
    if (!floating) {
      _valueAni.value = offset / widget.triggerDistance;
      _positionController.value = offset / widget.height;
    }
    super.onOffsetChange(offset);
  }

  @override
  void handleModeChange() {
    // TODO: implement handleModeChange
    super.handleModeChange();
    if (mode == RefreshStatus.idle) {
      //reset the state
      _scaleFactor.value = 1.0;
      _positionController.value = 0.0;
      _valueAni.value = 0.0;
    }
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _valueColor = _positionController.drive(
      ColorTween(
        begin: (widget.color ?? theme.accentColor).withOpacity(0.0),
        end: (widget.color ?? theme.accentColor).withOpacity(1.0),
      ).chain(
          CurveTween(curve: const Interval(0.0, 1.0 / _kDragSizeFactorLimit))),
    );
    super.didChangeDependencies();
  }

  @override
  Future<void> readyToRefresh() {
    // TODO: implement readyToRefresh
    return _positionController.animateTo(widget.distance / widget.height);
  }

  @override
  Future<void> endRefresh() {
    // TODO: implement endRefresh
    return _scaleFactor.animateTo(0.0);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _valueAni.dispose();
    _scaleFactor.dispose();
    _positionController.dispose();
    super.dispose();
  }
}

class WaterDropMaterialHeader extends MaterialClassicHeader {
  const WaterDropMaterialHeader({
    Key key,
    String semanticsLabel,
    double distance: 120.0,
    double offset: 0.0,
    String semanticsValue,
    Color color: Colors.white,
    Color backgroundColor: Colors.blueAccent,
  }) : super(
            key: key,
            offset: offset,
            color: color,
            distance: distance,
            backgroundColor: backgroundColor,
            semanticsValue: semanticsValue,
            semanticsLabel: semanticsLabel);

  const WaterDropMaterialHeader.asSliver({
    Key key,
    @required OnRefresh onRefresh,
    bool offStage:false,
    String semanticsLabel,
    double distance: 120.0,
    double offset: 0.0,
    String semanticsValue,
    Color color: Colors.white,
    Color backgroundColor: Colors.blueAccent,
  }) : super.asSliver(
            key: key,
            onRefresh: onRefresh,
            offStage:offStage,
            offset: offset,
            color: color,
            distance: distance,
            backgroundColor: backgroundColor,
            semanticsValue: semanticsValue,
            semanticsLabel: semanticsLabel);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _WaterDropMaterialHeaderState();
  }
}

class _WaterDropMaterialHeaderState extends _MaterialClassicHeaderState {
  AnimationController _BezierController;
  bool _showWater = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _BezierController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
        upperBound: 1.5,
        lowerBound: 0.0,
        value: 0.0);
    _BezierController.addListener(() {
      update();
    });
    _positionController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300),
        upperBound: 2.0,
        lowerBound: 0.0,
        value: 0.0);
    _positionFactor = _positionController.drive(Tween<Offset>(
        begin: Offset(0.0, 0.0),
        end: Offset(0.0, widget.distance / widget.height)));
  }

  @override
  Future<void> readyToRefresh() {
    // TODO: implement readyToRefresh
    _BezierController.value = 1.01;
    _showWater = true;
    _BezierController.animateTo(1.5,
        curve: Curves.bounceOut, duration: Duration(milliseconds: 550));

    return _positionController
        .animateTo(1.0,
            curve: Curves.bounceOut, duration: Duration(milliseconds: 550))
        .then((_) {
      _showWater = false;
    });
  }

  @override
  Future<void> endRefresh() {
    // TODO: implement endRefresh
    _showWater = false;
    return super.endRefresh();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _BezierController.dispose();
    super.dispose();
  }

  @override
  void onOffsetChange(double offset) {
    // TODO: implement onOffsetChange
    if (!floating) {
      _BezierController.value = (offset / widget.height) * 0.5;
      _valueAni.value = offset / widget.triggerDistance;
      _positionController.value =
          offset / widget.height * 0.3 / (widget.distance / widget.height);
    }
    update();
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus mode) {
    // TODO: implement buildContent
    return Stack(
      children: <Widget>[
        CustomPaint(
          painter: _BezierPainter(
              value: _BezierController.value, color: widget.backgroundColor),
          child: Container(),
        ),
        CustomPaint(
          child: super.buildContent(context, mode),
          painter: _showWater
              ? _WaterPainter(
                  ratio: widget.distance / widget.height,
                  color: widget.backgroundColor,
                  offset: _positionFactor.value.dy)
              : null,
        )
      ],
    );
  }
}

class _WaterPainter extends CustomPainter {
  final Color color;
  final double offset;
  final double ratio;

  _WaterPainter({this.color, this.offset, this.ratio});

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final Paint paint = Paint();
    paint.color = color;
    final Path path = Path();
    path.moveTo(size.width / 2 - 20.0, offset * 100.0 + 20.0);
    path.conicTo(size.width / 2, offset * 100.0 - 70.0 * (ratio - offset),
        size.width / 2 + 20.0, offset * 100.0 + 20.0, 10.0 * (ratio - offset));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return this != oldDelegate;
  }
}

class _BezierPainter extends CustomPainter {
  final double value;
  final Color color;

  _BezierPainter({this.value, this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final double middleX = size.width / 2;
    final Paint paint = Paint();

    paint.color = color;
    if (value < 1.0) {
      final Path path = Path();
      final double offsetY = 70.0 * value + 20.0;
      path.moveTo(0.0, 0.0);
      path.quadraticBezierTo(
          middleX + 70.0 * value, 20.0 - 40.0 * value, middleX - 20.0, offsetY);
      path.lineTo(middleX + 20.0, offsetY);
      path.quadraticBezierTo(
          middleX - 70.0 * value, 20.0 - 40.0 * value, size.width, 0.0);
      path.moveTo(size.width, 0.0);
      path.lineTo(0.0, 0.0);
      canvas.drawPath(path, paint);
    } else {
      final Path path = Path();
      path.moveTo(0.0, 0.0);
      path.conicTo(middleX, 60.0 * (1.5 - value), size.width, 0.0, 5.0);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return this != oldDelegate;
  }
}
