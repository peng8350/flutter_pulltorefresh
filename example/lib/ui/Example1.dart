import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Example1 extends StatefulWidget {
  @override
  _Example1State createState() => new _Example1State();
}

class _Example1State extends State<Example1> {
//  RefreshMode  refreshing = RefreshMode.idle;
//  LoadMode loading = LoadMode.idle;
  RefreshController _refreshController;
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
  }

  @override
  void initState() {
    // TODO: implement initState
    _getDatas();
    _refreshController = new RefreshController();
    super.initState();
  }

  Widget _headerCreate(BuildContext context,int mode){
    return new ClassicIndicator(mode: mode,refreshingText: "",idleIcon: new Container(),idleText: "Load more...",);

  }



//  Widget _footerCreate(BuildContext context,int mode){
//    return new ClassicIndicator(mode: mode);
//  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new SmartRefresher(
            enablePullDown: true,
            enablePullUp: false,
            controller: _refreshController,

            footerConfig: new LoadConfig(enableOverScroll: false),
            headerConfig: new LoadConfig(enableOverScroll: false),

            onRefresh: (up) {
              if (up)
                new Future.delayed(const Duration(milliseconds: 2009))
                    .then((val) {
                    data.add(new Card(
                      margin: new EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                      child: new Center(
                        child: new Text('Data '),
                      ),
                    ));
                  setState(() {

                  });
                  _refreshController.scrollTo(50.0);
                  _refreshController.sendBack(true, RefreshStatus.idle);
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
                  _refreshController.sendBack(false, RefreshStatus.idle);
                });
              }
            },

            onOffsetChange: _onOffsetCallback,
            child: new ListView.builder(
              reverse: true,
              itemExtent: 100.0,
              itemCount: data.length,
              itemBuilder: (context,index) => new Item(),
            )));
  }
}


class Item extends StatefulWidget {
  @override
  _ItemState createState() => new _ItemState();
}

class _ItemState extends State<Item> {
  @override
  Widget build(BuildContext context) {
    return new Card(
      margin:
      new EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
      child: new Center(
        child: new Text('Data'),
      ),
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    print("销毁");
    super.dispose();
  }
}
