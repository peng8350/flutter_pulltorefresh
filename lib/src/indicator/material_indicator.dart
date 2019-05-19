/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/19 下午9:23
 */

import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import '../../pull_to_refresh.dart';

class MaterialRefreshHeader extends RefreshIndicator {
  final String semanticsLabel;
  final String semanticsValue;
  final double strokeWidth;
  final Animation<Color> valueColor;
  final Color backgroundColor;
  final double value;
  MaterialRefreshHeader({
    Key key,
    double height: 100.0,
    double triggerDistance: 70.0,
    this.semanticsLabel,
    this.semanticsValue,
    this.strokeWidth: 4.0,
    this.valueColor,
    this.value,
    this.backgroundColor,
  }) : super(
            key: key,
            refreshStyle: RefreshStyle.Front,
            height: height,
            triggerDistance: triggerDistance);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MaterialRefreshHeaderState();
  }
}

class _MaterialRefreshHeaderState
    extends RefreshIndicatorState<MaterialRefreshHeader>
    with TickerProviderStateMixin {
  Animation<Offset> _positionFactor;
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
        upperBound: 0.75,
        duration: Duration(milliseconds: 500));
    _positionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300)
    );
    _scaleFactor = AnimationController(
        vsync: this,
        value: 1.0,
        lowerBound: 0.0,
        upperBound: 1.0,
        duration: Duration(milliseconds: 300));
    _positionFactor = _positionController
        .drive(Tween<Offset>(begin: Offset(0.0, -40.0/widget.height), end: Offset(0.0, 1.0)));
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
            value: floating?null:_valueAni.value,
            valueColor: widget.valueColor,
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
  Future<void> readyToRefresh() {
    // TODO: implement readyToRefresh
    return _positionController.animateTo(0.7);
  }

  @override
  Future<void> endRefresh() {
    // TODO: implement endRefresh
    _valueAni.stop();
    return _scaleFactor.animateTo(0.0).whenComplete((){
      _scaleFactor.value=1.0;
    });
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
