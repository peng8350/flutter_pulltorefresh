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
        color: Colors.redAccent,
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
    return Container(color: Colors.white,child: CustomScrollView(
      slivers: [
        SliverList(
            delegate: SliverChildListDelegate(data,
                addRepaintBoundaries: true)),
        SliverToBoxAdapter(child: Text("Wewew"),)
      ],
    ),);
  }
}
