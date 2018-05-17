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
      _headControll.value = offset / 2 + 1.0;
    } else
      _footControll.value = offset / 2 + 1.0;
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
  }

  Widget _headerCreate(BuildContext context,int mode,ValueNotifier<double> offset){
    return new ClassicIndicator(mode: mode);

  }



//  Widget _footerCreate(BuildContext context,int mode,ValueNotifier<double> offset){
//    return new ClassicLoadIndicator(mode: mode);
//  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            controller: _refreshController,
            header: _headerCreate
                ,
            footer: _headerCreate
                ,
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
                  _refreshController.sendBack(false, RefreshStatus.idle);
                });
              }
            },
            onOffsetChange: _onOffsetCallback,
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
