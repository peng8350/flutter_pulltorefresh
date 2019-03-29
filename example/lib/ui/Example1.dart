import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Example1 extends StatefulWidget {
  Example1({Key key}) : super(key: key);

  @override
  Example1State createState() => new Example1State();
}

class Example1State extends State<Example1> {
//  RefreshMode  refreshing = RefreshMode.idle;
//  LoadMode loading = LoadMode.idle;
  RefreshController _refreshController;
  ScrollController _scrollController;
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

  void scrollTop() {
    _scrollController.animateTo(0.0,
        duration: new Duration(microseconds: 1000), curve: ElasticInCurve());
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
    _scrollController = new ScrollController();
    _refreshController = new RefreshController();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refreshController.requestRefresh(true);
    });
    super.initState();
  }

  Widget _headerCreate(BuildContext context, RefreshStatus mode) {
    return new ClassicIndicator(
      mode: mode,
      refreshingText: "",
      idleIcon: new Container(),
      idleText: "Load more...",
    );
  }

//  Widget _footerCreate(BuildContext context,int mode){
//    return new ClassicIndicator(mode: mode);
//  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
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
                    _refreshController.sendBack(true, RefreshStatus.completed);
                  });
                });
              else {
                new Future.delayed(const Duration(milliseconds: 2009))
                    .then((val) {
                  setState(() {
                    data.add(new Card(
                      margin: new EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                      child: new Center(
                        child: new Text('Data '),
                      ),
                    ));
                      _refreshController.sendBack(false, RefreshStatus.idle);

                  });

                });
              }
            },
            onOffsetChange: _onOffsetCallback,
            child: new ListView.builder(
              reverse: true,
              controller: _scrollController,
              itemExtent: 100.0,
              itemCount: data.length,
              itemBuilder: (context, index) => new Item(),
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
    super.dispose();
  }
}
