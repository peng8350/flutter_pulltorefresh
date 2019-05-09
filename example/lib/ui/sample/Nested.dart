/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/7 下午12:18
 */

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../Item.dart';

class Nested extends StatefulWidget {
  @override
  _NestedState createState() => new _NestedState();
}

class _NestedState extends State<Nested> {
  List<Widget> items = [];
  RefreshController _refreshController;

  void _init() {
    for (int i = 0; i < 14; i++) {
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
  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
        headerSliverBuilder: (c, s) => [
          SliverAppBar(
            backgroundColor: Colors.greenAccent,
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background: Image.network(
                  "https://images.unsplash.com/photo-1541701494587-cb58502866ab?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=0c21b1ac3066ae4d354a3b2e0064c8be&auto=format&fit=crop&w=500&q=60",
                  fit: BoxFit.cover,
                )),
          ),
        ],
        body: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            isNestWrapped: true,
            header: ClassicHeader(
              idleIcon: Container(),
              idleText: "Load more...",
            ),
            enablePullUp: true,
            onRefresh: () {
              Future.delayed(const Duration(milliseconds: 2009))
                  .then((val) {
                items.add(Item(title:"item"));
                if(mounted)
                setState(() {
                  _refreshController.refreshCompleted();
                });
              });
            },
            onLoading: (){
              Future.delayed(const Duration(milliseconds: 2009))
                  .then((val) {
                if(mounted)
                setState(() {
                  items.add(Item(title:"item"));
                  _refreshController.loadComplete();
                });
              });
            },
            child: ListView.builder(
              itemExtent: 100.0,
              itemCount: items.length,
              itemBuilder: (context, index) => items[index],
            )));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _refreshController.dispose();
    super.dispose();
  }
}
