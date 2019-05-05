/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/5 下午6:10
 */

import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/scheduler.dart';

class IndicatorActivity extends StatefulWidget {
  final String title;

  final RefreshIndicator header;

  final LoadIndicator footer;

  final bool isNest;

  final bool enableOverScroll;

  IndicatorActivity(
      {this.title,
      this.header,
      this.footer,
      this.isNest: false,
      this.enableOverScroll: true});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _IndicatorActivityState();
  }
}

class _IndicatorActivityState extends State<IndicatorActivity> {
  List<Widget> items = [];
  RefreshController _refreshController;

  void _init() {
    for (int i = 0; i < 15; i++) {
      items.add(Item(title: "Data$i",));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _refreshController = RefreshController();
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: LayoutBuilder(builder: (BuildContext context, b) {
        final double totalHeight = items.length * 100.0;
        final double lIstHeight = b.biggest.height;
        return SmartRefresher(
            child: ListView.builder(
              itemBuilder: (c, i) => items[i],
              itemExtent: 100.0,
              itemCount: items.length,
            ),
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            header: widget.header,
            footer: widget.footer,
            enablePullDown: true,
            enableOverScroll: widget.enableOverScroll,
            isNestWrapped: widget.isNest,
            enablePullUp: totalHeight > lIstHeight,
            controller: _refreshController);
      }),
    );
  }

  _onRefresh() {
    Future.delayed(Duration(milliseconds: 1000)).then((_) {
      _refreshController.refreshCompleted();
    });
  }

  _onLoading() {

    Future.delayed(Duration(milliseconds: 1000)).then((_) {
      int index = items.length;
      setState(() {});
      items.add(Item(title: "Data$index",));
      ;
      _refreshController.loadComplete();

    });
  }
}

class Item extends StatefulWidget {

  final String title;

  Item({this.title});
  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red,
      margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
      child: Center(
        child: Text(widget.title),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
