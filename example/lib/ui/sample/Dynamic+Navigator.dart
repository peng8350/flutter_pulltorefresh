/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-03 12:54
 */

import 'package:flutter/material.dart' hide RefreshIndicator,RefreshIndicatorState;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../Item.dart';

/*
  test for some stiuation :
  1. enablePullDown or enablePullUp dynamic change may be throw error when update
  2. the widget lifecycle  of Navigator.push is different,it will be noticed too
 */

class Dynamic extends StatefulWidget {
  @override
  _DynamicState createState() => new _DynamicState();
}

class _DynamicState extends State<Dynamic> {
  List<Widget> items = [];
  bool _enablePullDown = true;
  bool _enablePullUp = true;
  RefreshController _refreshController;
  ScrollPhysics _physics = BouncingScrollPhysics();
  RefreshIndicator _header = ClassicHeader();

  void _init() {
    items = [];
    items.add(Row(
      children: <Widget>[
        Text("滑动引擎(iOS/Android)"),
        Radio(
          value: true,
          groupValue: _physics is BouncingScrollPhysics,
          onChanged: (i) {
            _physics = BouncingScrollPhysics();
            setState(() {});
          },
        ),
        Radio(
          value: false,
          groupValue: _physics is BouncingScrollPhysics,
          onChanged: (i) {
            _physics = ClampingScrollPhysics();
            setState(() {});
          },
        )
      ],
    ));
    items.add(Row(
      children: <Widget>[
        Text("是否启用FrontStyle"),
        Radio(
          value: true,
          groupValue: _header is MaterialClassicHeader,
          onChanged: (i) {
            _header = MaterialClassicHeader();
            setState(() {});
          },
        ),
        Radio(
          value: false,
          groupValue: _header is MaterialClassicHeader,
          onChanged: (i) {
            _header = ClassicHeader();
            setState(() {});
          },
        )
      ],
    ));
    items.add(Row(
      children: <Widget>[
        Text("打开下拉刷新"),
        Radio(
          value: true,
          groupValue: _enablePullDown,
          onChanged: (i) {
            _enablePullDown = i;
            setState(() {});
          },
        ),
        Radio(
          value: false,
          groupValue: _enablePullDown,
          onChanged: (i) {
            _enablePullDown = i;
            setState(() {});
          },
        )
      ],
    ));
    items.add(Row(
      children: <Widget>[
        Text("打开上拉加载"),
        Radio(
          value: true,
          groupValue: _enablePullUp,
          onChanged: (i) {
            _enablePullUp = i;
            setState(() {});
          },
        ),
        Radio(
          value: false,
          groupValue: _enablePullUp,
          onChanged: (i) {
            _enablePullUp = i;
            setState(() {});
          },
        )
      ],
    ));

    items.add(Row(
      children: <Widget>[
        MaterialButton(
          child: Text("延时打开/关闭下拉刷新"),
          onPressed: () {
            Future.delayed(Duration(milliseconds: 2000)).whenComplete(() {
              _enablePullDown = !_enablePullDown;
              setState(() {});
            });
          },
        ),
        MaterialButton(
          child: Text("延时打开/关闭上拉加载"),
          onPressed: () {
            Future.delayed(Duration(milliseconds: 2000)).whenComplete(() {
              _enablePullUp = !_enablePullUp;
              setState(() {});
            });
          },
        ),
      ],
    ));
    items.add(MaterialButton(
      child: Text("跳转第二个页面"),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (c) => Scaffold(
                  appBar: AppBar(),
                  body: Container(),
                )));
      },
    ));

    for (int i = 0; i < 24; i++) {
      items.add(Item(
        title: "Data$i",
      ));
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    _refreshController = RefreshController();
    super.initState();
  }

  _onLoading() {

    Future.delayed(Duration(milliseconds: 1000)).whenComplete((){
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
    _init();
    return SmartRefresher(
        child: ListView.builder(
          itemBuilder: (c, i) => items[i],
          itemExtent: 100.0,
          itemCount: items.length,
          physics: _physics,
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
