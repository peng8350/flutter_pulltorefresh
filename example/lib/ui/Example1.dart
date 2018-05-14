import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Example1 extends StatefulWidget {
  @override
  _Example1State createState() => new _Example1State();
}

class _Example1State extends State<Example1> {
//  LoadMode loading = LoadMode.idle;
//  RefreshMode  refreshing=RefreshMode.idle;
  List<Widget> data = [];
  void _getDatas() {

    for (int i = 0; i < 5; i++) {
      data.add(new Text('Data $i'));
    }
  }


//  void _onRefreshChange(mode){
//
//      //must be do it
//      setState(() {
//        refreshing = mode;
//      });
//      // this is equals onRefresh()
//      if(mode==RefreshMode.refreshing) {
//        new Future.delayed(const Duration(milliseconds: 2000), () {
//          setState(() {
//            refreshing = RefreshMode.failed;
//          });
//          print("Refreshed!!!");
//        });
//      }
//
//  }
//
//  void _onLoadChange(LoadMode mode){
//    //must be do it
//    setState(() {
//      loading= mode;
//    });
//    // this is equals onLoaadmore()
//    if(mode==LoadMode.loading) {
//      new Future<Null>.delayed(const Duration(milliseconds: 2000), () {
//
//        setState(() {
//          data.add(new Text('Data '));
//
//          loading = LoadMode.idle;
//        });
//        print("LoadComplete!!!");
//      });
//    }
//  }

  void _onOffsetCallback(bool isUp,double offset) {
    // if you want change some widgets state ,you should rewrite the callback
//    print(offset);
  }

  @override
  void initState() {
    // TODO: implement initState
    _getDatas();

    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white30,
      child: new RefreshIndicator(child: new SmartRefresher(
          enablePullDownRefresh: false,
          enablePullUpLoad: true,
          onOffsetChange: _onOffsetCallback,
          child: new Container(
            color: Colors.white,
            child: new ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemExtent: 40.0,
              itemCount: data.length,
              itemBuilder: (context,index){
                return data[index];
              },

            ),
          )
      ), onRefresh: (){
        return new Future.delayed(const Duration(milliseconds: 2000));
      })
    );
  }
}
