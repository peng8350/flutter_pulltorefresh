/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-06 15:05
 */
import 'package:flutter/material.dart' hide RefreshIndicator;
import 'package:pull_to_refresh/pull_to_refresh.dart';
/*

  test for requestRefresh

 */

class RequestRefresh extends StatefulWidget {
  @override
  _RequestRefreshState createState() => new _RequestRefreshState();
}

class _RequestRefreshState extends State<RequestRefresh> {
  List<Widget> items = [];
  bool _enablePullDown = true;
  bool _enablePullUp = true;
  RefreshController _refreshController;
  RefreshIndicator _header = MaterialClassicHeader();

  void _init() {
    items = [];
    items.add(Row(
      children: <Widget>[
        MaterialButton(
            child: Text("切换为Front"),
            onPressed: () {
              _header = MaterialClassicHeader();
              setState(() {});
            }),
        MaterialButton(
            child: Text("切换为非Front"),
            onPressed: () {
              _header = ClassicHeader();
              setState(() {});
            })
      ],
    ));
    for (int i = 0; i < 24; i++) {
      items.add(GestureDetector(
        child: Container(
          child: Card(
            child: Text(i % 2 != 0 ? "点我主动刷新!" : "点我主动加载更多!"),
          ),
          height: 100.0,
        ),
        onTap: () {
          if (i % 2 != 0) {
            _refreshController.requestRefresh();
          } else {
            _refreshController.requestLoading();
          }
        },
      ));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _refreshController = RefreshController(initialRefresh: true);
    super.initState();
  }

  _onLoading() {
    Future.delayed(Duration(milliseconds: 1000)).whenComplete((){
      _refreshController.loadComplete();
    });
  }

  _onRefresh() {
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    _init();
    return SmartRefresher(
        child: ListView.builder(
          itemBuilder: (c, i) => items[i],
          itemExtent: 100.0,
          itemCount: items.length,
        ),
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        header: _header,
        enablePullDown: _enablePullDown,
        enablePullUp: _enablePullUp,
        controller: _refreshController);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _refreshController.dispose();
    super.dispose();
  }
}
