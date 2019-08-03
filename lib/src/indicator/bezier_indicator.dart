/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-08-02 19:20
 */


import 'package:flutter/animation.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' hide RefreshIndicator,RefreshIndicatorState;
import 'package:pull_to_refresh/src/internals/indicator_wrap.dart';
import 'dart:math' as math;
import 'package:flutter/physics.dart';

class BezierHeader extends RefreshIndicator{
  final OffsetCallBack onOffsetChange;
  final ModeChangeCallBack onModeChange;
  final VoidFutureCallBack readyRefresh,endRefresh;
  final VoidCallback onResetValue;
  final Color bezierColor;

  final Widget child;

  final double rectHeight;

  BezierHeader({this.child:const Text(""),this.onOffsetChange,this.onModeChange,this.readyRefresh,this.endRefresh,this.onResetValue,this.rectHeight:80,this.bezierColor:Colors.blueAccent}):super(refreshStyle:RefreshStyle.UnFollow,height:rectHeight);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BezierHeaderState();
  }

}

class _BezierHeaderState extends RefreshIndicatorState<BezierHeader> with TickerProviderStateMixin{

  AnimationController _beizerBounceCtl;



  @override
  void initState() {
    // TODO: implement initState
    _beizerBounceCtl = AnimationController(vsync: this,lowerBound: -10,upperBound: 50,value: 0);

    super.initState();
  }

  @override
  void onOffsetChange(double offset) {
    // TODO: implement onOffsetChange
    if(widget.onOffsetChange!=null){
      widget.onOffsetChange(offset);
    }
    if(!_beizerBounceCtl.isAnimating||(!floating))
        _beizerBounceCtl.value =math.max(0, offset-widget.rectHeight);

  }

  @override
  void onModeChange(RefreshStatus mode) {
    // TODO: implement onModeChange
    if(widget.onModeChange!=null){
      widget.onModeChange(mode);
    }
    super.onModeChange(mode);
  }


  @override
  void dispose() {
    // TODO: implement dispose
    _beizerBounceCtl.dispose();
    super.dispose();
  }

  @override
  Future<void> readyToRefresh() {
    // TODO: implement readyToRefresh
    final Simulation simulation = SpringSimulation(SpringDescription(
      mass: 4,
      stiffness: 10000.5,
      damping: 7,

    ), _beizerBounceCtl.value, 0, 1000);
    _beizerBounceCtl.animateWith(simulation);
    if(widget.readyRefresh!=null){
      return widget.readyRefresh();
    }
    return super.readyToRefresh();
  }

  @override
  Future<void> endRefresh() {
    // TODO: implement endRefresh
    if(widget.endRefresh!=null){
      return widget.endRefresh();
    }
    return super.endRefresh();
  }

  @override
  void resetValue() {
    // TODO: implement resetValue

    _beizerBounceCtl.value = 0;
    if(widget.onResetValue!=null){
      widget.onResetValue();
    }
    super.resetValue();
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus mode) {
    // TODO: implement buildContent
    print(math.max(0,_beizerBounceCtl.value)+widget.rectHeight);
    return  AnimatedBuilder(
      builder: (_,__){
        return Stack(
          children: <Widget>[
            ClipPath(
              child: Container(
                height: math.max(0,_beizerBounceCtl.value)+widget.rectHeight,
                color: widget.bezierColor,
              ),
              clipper: _BezierPainter(value: _beizerBounceCtl.value,startOffsetY: widget.rectHeight),
            ),
            ClipPath(
              child: Container(
                height: math.max(00, _beizerBounceCtl.value)+widget.rectHeight,
                child: widget.child,
              ),
              clipper:_BezierPainter(value: _beizerBounceCtl.value,startOffsetY: widget.rectHeight) ,
            ),
          ],
        );
      },
      animation: _beizerBounceCtl,
    );

  }

}

class _BezierPainter extends CustomClipper<Path>{

  final double startOffsetY;

  final double value;


  _BezierPainter({this.value,this.startOffsetY});


  @override
  getClip(Size size) {
    // TODO: implement getClip
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, startOffsetY);
    path.quadraticBezierTo( size.width/2, startOffsetY+value*2, size.width, startOffsetY);
    path.moveTo(size.width, startOffsetY);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    return path;
  }

  @override
  bool shouldReclip(_BezierPainter oldClipper) {
    // TODO: implement shouldReclip
    return value !=oldClipper.value;
  }
}

class BezierCircleHeader extends StatefulWidget{
  final Color bezierColor;


  final double rectHeight;

  final Color circleColor;

  final double circleRadius;

  BezierCircleHeader({this.bezierColor:Colors.blueAccent,this.rectHeight:80,this.circleColor:Colors.white,this.circleRadius:25});


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BezierCircleHeaderState();
  }

}

class _BezierCircleHeaderState extends State<BezierCircleHeader> with TickerProviderStateMixin{
  RefreshStatus mode = RefreshStatus.idle;
  AnimationController _childMoveCtl;
  Tween<AlignmentGeometry> _childMoveTween;
  AnimationController _dismissCtrl;
  Tween<Offset> _disMissTween;
  @override
  void initState() {
    // TODO: implement initState
    _dismissCtrl = AnimationController(vsync: this);
    _childMoveCtl = AnimationController(vsync: this);
    _childMoveTween = AlignmentGeometryTween(begin: Alignment.bottomCenter,end: Alignment.center);
    _disMissTween = Tween<Offset>(begin: Offset(0.0,0.0),end: Offset(0.0,1.5));
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _dismissCtrl.dispose();
    _childMoveCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BezierHeader(
      bezierColor: widget.bezierColor,
      rectHeight: widget.rectHeight,
      readyRefresh: () async{
        await _childMoveCtl.animateTo(1.0,duration: Duration(milliseconds: 300));
      },
      onResetValue: () {
        _dismissCtrl.value =0;
        _childMoveCtl.reset();
      },
      onModeChange: (m){
        mode = m;
        setState(() {

        });
      },
      endRefresh: () async {
        await _dismissCtrl.animateTo(1,duration: Duration(milliseconds: 550));
      },
      child:SlideTransition(
        position: _disMissTween.animate(_dismissCtrl),
        child: AlignTransition(
          child:Container(
            height: widget.circleRadius+5,
            child: Stack(
              children: <Widget>[
                Center(
                  child: Container(
                    height: widget.circleRadius,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    child: CircularProgressIndicator(
                      valueColor: mode==RefreshStatus.refreshing?AlwaysStoppedAnimation(Colors.white):AlwaysStoppedAnimation(Colors.transparent),
                      strokeWidth: 2,
                    ),
                    height: widget.circleRadius+5,
                    width: widget.circleRadius+5,
                  ),
                )
              ],
            ),
          )
          ,

          alignment: _childMoveCtl.drive(_childMoveTween),
        ),

      ),

    );
  }

}


