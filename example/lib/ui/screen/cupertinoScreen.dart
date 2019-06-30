/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-05-24 12:53
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CupertinoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CupertinoScreenState();
  }
}

class CupertinoScreenState extends State<CupertinoScreen> {
  int _segIndex = 0;

  RefreshController _refreshController;

  @override
  void initState() {
    // TODO: implement initState
    _refreshController = RefreshController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    List<Widget> widgets = [];
    for (int i = 0; i < 24; i++) {
      widgets.add(Container(
        height: 100.0,
        child: Card(),
      ));
    }
    return CupertinoApp(
        home: CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: GestureDetector(
          child: Icon(Icons.arrow_back_ios),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        middle: CupertinoSegmentedControl(
          children: {0: Text("sliver"), 1: Text("refresher")},
          onValueChanged: (index) {
            setState(() {});
            _segIndex = index;
          },
          groupValue: _segIndex,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            Offstage(
              offstage: _segIndex != 1,
              child: SmartRefresher(
                child: ListView(children: widgets),
                controller: _refreshController,
                header: ClassicHeader(),
                onRefresh: () {
                  Future.delayed(Duration(milliseconds: 1000)).whenComplete(() {
                    _refreshController.refreshCompleted();
                  });
                },
              ),
            )
          ],
        ),
      ),
    ));
  }
}
