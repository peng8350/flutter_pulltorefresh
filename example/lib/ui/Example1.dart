import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Example1 extends StatefulWidget {
  @override
  _Example1State createState() => new _Example1State();
}

class _Example1State extends State<Example1> {

  RefreshMode loading=RefreshMode.idel, refreshing=RefreshMode.idel;

  List<Widget> _getDatas() {
    List<Widget> data = [];
    for (int i = 0; i < 4; i++) {
      data.add(new Text('Data $i'));
    }
    return data;
  }

  Widget _buildHeader(context, mode) {
    return new Image.asset(
      "images/animate.gif",
      height: 100.0,
      fit: BoxFit.cover,
    );
  }




  void _onModeChange(isUp,mode){
    if(isUp){
      //must be do it
      setState(() {
        refreshing = mode;
      });
      // this is equals onRefresh()
      if(mode==RefreshMode.refreshing) {
        new Future.delayed(const Duration(milliseconds: 2000), () {
          setState(() {
            refreshing = RefreshMode.failed;
          });
          print("Refreshed!!!");
        });
      }
    }
    else{
      //must be do it
      setState(() {
        loading= mode;
      });
      // this is equals onLoaadmore()
      if(mode==RefreshMode.refreshing) {
        new Future<Null>.delayed(const Duration(milliseconds: 2000), () {
          setState(() {
            loading = RefreshMode.failed;
          });
          print("LoadComplete!!!");
        });
      }
    }
  }

  void _onOffsetCallback(double offset) {
    // if you want change some widgets state ,you should rewrite the callback
//    print(offset);
  }


  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new SmartRefresher(
        enablePulldownRefresh: true,
        enablePullUpLoad: true,
        headerBuilder: _buildHeader,
        refreshMode: this.refreshing,
        loadMode: this.loading,
        child: new ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemExtent: 40.0,
            children: _getDatas()),
        onModeChange: _onModeChange,
        onOffsetChange: _onOffsetCallback,
      ),
    );
  }
}
