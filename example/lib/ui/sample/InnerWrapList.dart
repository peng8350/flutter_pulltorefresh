/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/7 下午4:54
 */

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../Item.dart';

// test Compatibility with inner ListView
class InnerList extends StatefulWidget {
  @override
  _InnerListState createState() => new _InnerListState();
}

class _InnerListState extends State<InnerList> {
  List<Widget> items = [];
  RefreshController _refreshController;

  void _init() {
    // 垂直滚动视图
    List<Widget> temp = [];
    for (int j = 0; j < 16; j++) {
      temp.add(Item(
        title: "垂直滚动List",
      ));
    }
    items.add(Container(
      height: 100.0,
      child: ListView(
        children: temp,
      ),
    ));

    // 垂直滚动视图
    List<Widget> temp1 = [];
    for (int j = 0; j < 16; j++) {
      temp1.add(Item(
        title: "水平滚动List",
      ));
    }
    items.add(Container(
      height: 100.0,
      child: ListView(
        children: temp1,
        scrollDirection: Axis.horizontal,
      ),
    ));
    for (int i = 0; i < 50; i++) {
      items.add(Item(title: "数据"));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _init();
    _refreshController = RefreshController();
    super.initState();
  }

  _onLoading() {
    Future.delayed(Duration(milliseconds: 300)).whenComplete((){
      _refreshController.loadComplete();
    });

  }

  _onRefresh() {
    items.add(Item(
      title: "Data",
    ));
    if (mounted) setState(() {});

    _refreshController.refreshCompleted();
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
          onRefresh: _onRefresh,
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
