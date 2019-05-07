/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/7 下午12:17
 */

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../Item.dart';

class DataSmall extends StatefulWidget {
  @override
  _DataSmallState createState() => new _DataSmallState();
}

class _DataSmallState extends State<DataSmall> {

  List<Widget> items = [];
  RefreshController _refreshController;

  void _init() {
    for (int i = 0; i < 5; i++) {
      items.add(Item(title: "Data$i",));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _init();
    _refreshController  = RefreshController();
    super.initState();
  }

  _onLoading(){
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, b) {
      final double totalHeight = items.length * 100.0;
      final double lIstHeight = b.biggest.height;
      return SmartRefresher(
          child: ListView.builder(
            itemBuilder: (c, i) => items[i],
            itemExtent: 100.0,
            itemCount: items.length,
          ),
          onLoading: _onLoading,
          enablePullDown: true,
          enablePullUp: totalHeight > lIstHeight,
          controller: _refreshController);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _refreshController.dispose();
    super.dispose();
  }
}
