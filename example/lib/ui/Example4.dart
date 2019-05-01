import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
    return RefreshIndicator(
        child: SmartRefresher(
            enablePullDown: false,
            enablePullUp: true,
            enableOverScroll: false,
            footerBuilder: (context, mode) {
              return ClassicIndicator(mode: mode);
            },
            footerConfig: LoadConfig(),
            controller: _refreshController,
            onRefresh: (up) {
              Future.delayed(const Duration(milliseconds: 1000)).then((val) {
                _refreshController.sendBack(false, RefreshStatus.idle);
              });
            },
            onOffsetChange: (bool up, double offset) {
              print("$up:$offset");
            },
            child: CustomScrollView(
              slivers: [
                SliverList(
                    delegate: SliverChildListDelegate(data,
                        addRepaintBoundaries: true))
              ],
            )),
        onRefresh: () {
          return Future.delayed(const Duration(milliseconds: 300));
        });
  }
}
