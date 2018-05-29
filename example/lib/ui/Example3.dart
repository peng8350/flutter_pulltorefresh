import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Example3 extends StatefulWidget {
  Example3({Key key}) : super(key: key);

  @override
  Example3State createState() => new Example3State();
}

class Example3State extends State<Example3> with TickerProviderStateMixin {
//  RefreshMode  refreshing = RefreshMode.idle;
//  LoadMode loading = LoadMode.idle;
  ValueNotifier<double> topOffsetLis = new ValueNotifier(0.0);
  RefreshController _refreshController;
  AnimationController _headControll, _footControll;
  List<Widget> data = [];
  void _getDatas() {
    for (int i = 0; i < 14; i++) {
      data.add(new Card(
        margin:
            new EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
        child: new Center(
          child: new Text('Data $i'),
        ),
      ));
    }
  }

  void enterRefresh() {
    _refreshController.requestRefresh(true);
  }

  void _onOffsetCallback(bool isUp, double offset) {
    // if you want change some widgets state ,you should rewrite the callback
    if (isUp) {
      topOffsetLis.value = offset;
    }
//    if (isUp) {
//      _headControll.value = offset / 2 + 1.0;
//    } else
//      _footControll.value = offset / 2 + 1.0;
  }

  @override
  void initState() {
    // TODO: implement initState
    _getDatas();
    _refreshController = new RefreshController();
    _headControll = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 1.0,
      upperBound: 1.5,
    );
    _footControll = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 1.0,
      upperBound: 1.5,
    );
    super.initState();
    topOffsetLis.addListener(() {
      setState(() {});
    });
  }

  Widget _headerCreate(BuildContext context, int mode) {
    return new ClassicIndicator(mode: mode);
  }

//  Widget _footerCreate(BuildContext context,int mode,ValueNotifier<double> offset){
//    return new ClassicLoadIndicator(mode: mode);
//  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Stack(
      children: <Widget>[
        new ClipPath(
          clipper: new CirclePainter(offset: topOffsetLis.value),
          child: new Container(
            color: const Color(0xffff0000),
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        new SmartRefresher(
          enablePullUp: true,
          controller: _refreshController,
          headerBuilder: _headerCreate,
          footerBuilder: _headerCreate,
          footerConfig: new RefreshConfig(),
          onRefresh: (up) {
            if (up)
              new Future.delayed(const Duration(milliseconds: 2009))
                  .then((val) {
                _refreshController.sendBack(true, RefreshStatus.failed);
//                refresher.sendStatus(RefreshStatus.completed);
              });
            else {
              new Future.delayed(const Duration(milliseconds: 2009))
                  .then((val) {
                data.add(new Card(
                  margin: new EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                  child: new Center(
                    child: new Text('Data '),
                  ),
                ));
                setState(() {});
                _refreshController.sendBack(false, RefreshStatus.completed);
              });
            }
          },
          onOffsetChange: _onOffsetCallback,
          child: new ListView.builder(
            itemExtent: 100.0,
            itemCount: data.length,
            itemBuilder: (context, index) {
              return data[index];
            },
          ),
        )
      ],
    ));
  }
}

class CirclePainter extends CustomClipper<Path> {
  final double offset;

  CirclePainter({this.offset});

  @override
  Path getClip(Size size) {
    // TODO: implement getClip
    final path = new Path();
    path.addArc(new Rect.fromLTRB(0.0, 0.0, 0.0, 0.0), 45.0, 45.0);
    path.cubicTo(0.0, 0.0, size.width / 2, offset * 2, size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    // TODO: implement shouldReclip
    return oldClipper != this;
  }
}
