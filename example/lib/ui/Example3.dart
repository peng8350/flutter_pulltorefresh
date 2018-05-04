import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Example3 extends StatefulWidget {
  @override
  _Example3State createState() => new _Example3State();
}

class _Example3State extends State<Example3> with TickerProviderStateMixin {
  RefreshMode loading = RefreshMode.idel, refreshing = RefreshMode.idel;
  AnimationController _animateControll;
  List<Widget> data = [];
  void _getDatas() {
    for (int i = 0; i < 14; i++) {
      data.add(new Card(
        margin: new EdgeInsets.only(left: 10.0,right: 10.0,top: 5.0,bottom: 5.0),
        child: new Center(
          child: new Text('Data $i'),
        ),
      ));
    }
  }

  Widget _header(context, mode) {
    return new IntrinsicHeight(
      child:
      new ScaleTransition(
        scale: _animateControll,
        child: new Image.asset('images/animate.gif',
            width: double.infinity,
            height: 150.0, fit: BoxFit.cover),
      ),
    );
  }

  void _onModeChange(isUp, mode) {
    if (isUp) {
      //must be do it
      setState(() {
        refreshing = mode;
      });
      // this is equals onRefresh()
      if (mode == RefreshMode.refreshing) {
        _animateControll.animateTo(0.0);
        new Future.delayed(const Duration(milliseconds: 2000), () {
          setState(() {
            refreshing = RefreshMode.failed;
          });
          print("Refreshed!!!");
        });
      }
    } else {
      //must be do it
      setState(() {
        loading = mode;
      });
      // this is equals onLoaadmore()
      if (mode == RefreshMode.refreshing) {
        new Future<Null>.delayed(const Duration(milliseconds: 2000), () {
          setState(() {
            data.add(new Text('Data '));

            loading = RefreshMode.completed;
          });
          print("LoadComplete!!!");
        });
      }
    }
  }

  void _onOffsetCallback(double offset) {
    // if you want change some widgets state ,you should rewrite the callback
    _animateControll.value = offset/2+1.0;
  }

  @override
  void initState() {
    // TODO: implement initState
    _getDatas();
    _animateControll = new AnimationController(
      vsync: this,duration: const  Duration(milliseconds: 200),
      lowerBound: 1.0,upperBound: 1.5,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new SmartRefresher(
            enablePullDownRefresh: true,
            headerHeight: 150.0,
            topVisibleRange: 100.0,
            headerBuilder: _header,
            refreshMode: this.refreshing,
            onOffsetChange: _onOffsetCallback,
            loadMode: this.loading,
            onModeChange: _onModeChange,
            child: new Container(
              margin: new EdgeInsets.only(top: 20.0),
              color: Colors.white,
              child: new ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemExtent: 100.0,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return data[index];
                },
              ),
            )));
  }
}
