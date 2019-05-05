import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Example3 extends StatefulWidget {
  Example3({Key key}) : super(key: key);

  @override
  Example3State createState() => Example3State();
}

class Example3State extends State<Example3> with TickerProviderStateMixin {
//  RefreshMode  refreshing = RefreshMode.idle;
//  LoadMode loading = LoadMode.idle;
  ValueNotifier<double> topOffsetLis = ValueNotifier(0.0);
  ValueNotifier<double> bottomOffsetLis = ValueNotifier(0.0);
  RefreshController _refreshController;
  List<Widget> data = [];
  void _getDatas() {
    for (int i = 0; i < 14; i++) {
      data.add(GestureDetector(
        child: Container(
          color: Color.fromARGB(255, 250, 250, 250),
          child: Card(
            margin:
            EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
            child: Center(
              child: Text('Data $i'),
            ),
          ),
        ),
        onTap: (){
          _refreshController.requestRefresh();
        },
      ));
    }
  }

  void enterRefresh() {
    _refreshController.requestLoading();
  }

  void _onOffsetCallback(bool isUp, double offset) {
    // if you want change some widgets state ,you should rewrite the callback
    if (isUp) {
      bottomOffsetLis.value = offset;
    } else {
      topOffsetLis.value = offset;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _getDatas();
    _refreshController = RefreshController();
    super.initState();
    topOffsetLis.addListener(() {
      setState(() {});
    });
    bottomOffsetLis.addListener(() {
      setState(() {});
    });
  }

  Widget _headerCreate(BuildContext context, RefreshStatus mode) {
    return Image.asset(
      "images/animate.gif",
      fit: BoxFit.fitWidth,
      alignment: Alignment.topCenter,
    );
  }

//  Widget _footerCreate(BuildContext context,int mode,ValueNotifier<double> offset){
//    return new ClassicLoadIndicator(mode: mode);
//  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
      children: <Widget>[
        SmartRefresher(
          controller: _refreshController,
          enablePullUp: true,
          header: WaterDropHeader(),
          onRefresh: () {
            Future.delayed(const Duration(milliseconds: 2009)).then((val) {
              _refreshController.refreshFailed();
            });
          },
          onLoading: () {
            Future.delayed(const Duration(milliseconds: 2009)).then((val) {
              data.add(Container(
                color: Color.fromARGB(255, 250, 250, 250),
                child: Card(
                  margin: EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                  child: Center(
                    child: Text('Data '),
                  ),
                ),
              ));
              setState(() {});
              _refreshController.loadComplete();
            });
          },
          onOffsetChange: _onOffsetCallback,
          child: ListView.builder(
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
  final bool up;

  CirclePainter({this.offset, this.up});

  @override
  Path getClip(Size size) {
    // TODO: implement getClip
    final path = Path();
    if (!up) path.moveTo(0.0, size.height);
    path.cubicTo(
        0.0,
        up ? 0.0 : size.height,
        size.width / 2,
        up ? offset * 2.3 : size.height - offset * 2.3,
        size.width,
        up ? 0.0 : size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    // TODO: implement shouldReclip
    return oldClipper != this;
  }
}
