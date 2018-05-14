import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Example3 extends StatefulWidget {
  @override
  _Example3State createState() => new _Example3State();
}

class _Example3State extends State<Example3> with TickerProviderStateMixin {
  RefreshMode  refreshing = RefreshMode.idle;
  LoadMode loading = LoadMode.idle;
  AnimationController _headControll,_footControll;
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

  Widget _header(context, mode) {
    return
       new ClipRect(
         child: new Align(
           alignment: Alignment.center,
           heightFactor: 1.0,

           child: new ScaleTransition(
             scale: _headControll,
             child: new Image.asset('images/animate.gif',
                 width: double.infinity, height: 150.0, fit: BoxFit.cover),
           ),
         ),
       )
    ;
  }
  Widget _footer(context, mode) {
    return
      new ClipRect(
        child: new Align(
          alignment: Alignment.center,
          heightFactor: 1.0,
          child: new ScaleTransition(
            scale: _footControll,
            child: new Image.asset('images/animate.gif',
                width: double.infinity, height: 150.0, fit: BoxFit.cover),
          ),
        ),
      )
    ;
  }

  void _onRefreshChange(mode) {
      //must be do it
      setState(() {
        refreshing = mode;
      });
      // this is equals onRefresh()
      switch(mode){
        case RefreshMode.refreshing:
          _headControll.animateTo(0.0);
          new Future.delayed(const Duration(milliseconds: 2000), () {
            setState(() {
              refreshing = RefreshMode.failed;
            });
            print("Refreshed!!!");
          });
          break;
        case RefreshMode.idle:
          _headControll.animateTo(0.0);
          break;
      }
  }

  _onLoadChange(mode){
    //must be do it
    setState(() {
      loading = mode;
    });
    switch(mode){
      case RefreshMode.refreshing:
        _footControll.animateTo(0.0);
        break;
      case RefreshMode.idle:
        _footControll.animateTo(0.0);
        break;
    }
    // this is equals onLoaadmore()
    if (mode == LoadMode.loading) {
      new Future<Null>.delayed(const Duration(milliseconds: 2000), () {
        setState(() {
          data.add(new Card(
            margin:
            new EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
            child: new Center(
              child: new Text('Data '),
            ),
          ));

          loading = LoadMode.idle;
        });
        print("LoadComplete!!!");
      });
    }
  }

  void _onOffsetCallback(bool isUp,double offset) {
    // if you want change some widgets state ,you should rewrite the callback
    if(isUp){
      _headControll.value = offset / 2 + 1.0;
    }
    else
    _footControll.value = offset / 2 + 1.0;
  }

  @override
  void initState() {
    // TODO: implement initState
    _getDatas();
    _headControll= new AnimationController(
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
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new SmartRefresher(
            enablePullDownRefresh: true,
            enablePullUpLoad: true,
            header: new ClassicIndicator(vsync: this),

            topVisibleRange: 100.0,
            headerBuilder: _header,
            refreshMode: this.refreshing,
            onOffsetChange: _onOffsetCallback,
            loadMode: this.loading,
            onRefreshChange: _onRefreshChange,
            onLoadChange: _onLoadChange,
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
