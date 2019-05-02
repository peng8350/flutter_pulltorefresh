import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/cupertino.dart';

class Example4 extends StatefulWidget {
  @override
  _Example4State createState() => _Example4State();
}

class _Example4State extends State<Example4> with TickerProviderStateMixin {
  List<Widget> data = [];
  RefreshController _refreshController;
  void _getDatas() {
    for (int i = 0; i < 18; i++) {
      data.add(Container(
        child: Text('Data $i'),
        height: 50.0,
      ));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _getDatas();
    _refreshController = RefreshController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    new ListView.builder(
//      itemExtent: 100.0,
//      itemCount: data.length,
//
//      itemBuilder: (context, index) {
//        return data[index];
//      },
//    )
    return CustomScrollView(
      slivers: [
        CupertinoSliverRefreshControl(builder: (a,b,c,d,e) => Icon(CupertinoIcons.add_circled_solid)),
        SliverList(
            delegate: SliverChildListDelegate(data,
                addRepaintBoundaries: true))
      ],
    );
  }
}
