import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Example4 extends StatefulWidget {
  @override
  _Example4State createState() => new _Example4State();
}

class _Example4State extends State<Example4> {
  RefreshMode  refreshing = RefreshMode.idle;
  LoadMode loading = LoadMode.idle;
  List<Widget> data = [];
  void _getDatas() {
    for (int i = 0; i < 25; i++) {
      data.add(new Text('Data $i'));
    }
  }

  void _onRefreshChange(mode) {
      //must be do it
      setState(() {
        refreshing = mode;
      });
      // this is equals onRefresh()
      if (mode == RefreshMode.refreshing) {
        new Future.delayed(const Duration(milliseconds: 2000), () {
          setState(() {
            refreshing = RefreshMode.failed;
          });
          print("Refreshed!!!");
        });
      }

  }

  Widget buildDefaultFooter(BuildContext context, LoadMode mode) {

    final child =mode ==LoadMode.loading?new SizedBox(
      width: 25.0,
      height: 25.0,
      child: const CircularProgressIndicator(strokeWidth: 2.0),
    ):new Text(
      mode == LoadMode.idle
          ? 'Load More...'
          : mode == LoadMode.emptyData
          ? 'No more data'
          : 'Network exception!',
      style: new TextStyle(color: const Color(0xff555555)),
    );
    return  new GestureDetector(
      child: new Container(
        height: 50.0,
        child: new Center(
          child: child,
        ),
      ),
      onTap: (){
        setState(() {
          refreshing = RefreshMode.refreshing;
        });
      },
    )
    ;
  }


  void _onLoadChange(mode){
    //must be do it
    setState(() {
      loading = mode;
    });
    // this is equals onLoadmore()
    if (mode == LoadMode.loading) {
      new Future<Null>.delayed(const Duration(milliseconds: 2000), () {
        setState(() {
          data.add(new Text('Data '));

          loading = LoadMode.idle;
        });
        print("LoadComplete!!!");
      });
    }
  }

  void _onOffsetCallback(bool isUp, double offset) {
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
        child: new SmartRefresher(
            enablePullDownRefresh: true,
            enablePullUpLoad: true,
            footerBuilder: buildDefaultFooter,
            refreshMode: this.refreshing,
            loadMode: this.loading,
            onRefreshChange: _onRefreshChange,
            onLoadChange: _onLoadChange,
            onOffsetChange: _onOffsetCallback,
            child: new ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemExtent: 40.0,
              itemCount: data.length,
              itemBuilder: (context, index) {
                return data[index];
              },
            )));
  }
}
