import 'dart:async';

import 'package:flutter/material.dart';
import '../../Item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide RefreshIndicator;

/*
   NestedScrollView+SmartRefresher,implements such effect ,refreshing under the SliverAppbar,
   see the issue #98.
   But NestedScrollView cannot compatible with overScroll,so it may have a bug when Dragging down then dragging up quickly.
   this bug I have no idea how to fix this,only waiting for flutter fix this bug.
 */
class NestedRefresh extends StatefulWidget {
  NestedRefresh({Key key}) : super(key: key);

  @override
  NestedRefreshState createState() => NestedRefreshState();
}

class NestedRefreshState extends State<NestedRefresh> {
//  RefreshMode  refreshing = RefreshMode.idle;
//  LoadMode loading = LoadMode.idle;
  RefreshController _refreshController;
  ScrollController _scrollController;
  List<Widget> data = [];

  void _getDatas() {
    for (int i = 0; i < 4; i++) {
      data.add(Container(
        color: Colors.greenAccent,
        margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
        child: Center(
          child: Text('Data $i'),
        ),
      ));
    }
  }

  void scrollTop() {
    _scrollController.animateTo(0.0,
        duration: const Duration(milliseconds: 200), curve: Curves.linear);
  }

  void enterRefresh() {
    _refreshController.requestRefresh();
  }

  @override
  void initState() {
    // TODO: implement initState
    _getDatas();
    _scrollController = ScrollController(keepScrollOffset: true);
    _refreshController = RefreshController();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
        headerSliverBuilder: (c, s) => [
          SliverAppBar(
            backgroundColor: Colors.greenAccent,
            expandedHeight: 200.0,

            leading: Container(),
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background: Image.network(
                  "https://images.unsplash.com/photo-1541701494587-cb58502866ab?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=0c21b1ac3066ae4d354a3b2e0064c8be&auto=format&fit=crop&w=500&q=60",
                  fit: BoxFit.cover,
                )),
          ),
        ],
        body: Container(
          child: SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              header: WaterDropHeader(),
              enablePullUp: true,
              onRefresh: () {
                Future.delayed(const Duration(milliseconds: 2009)).then((val) {
                  data.add(Card(
                    margin: EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                    child: Center(
                      child: Text('Data '),
                    ),
                  ));
                  if (mounted)
                    setState(() {
                      _refreshController.refreshCompleted();
                    });
                });
              },
              onLoading: () {
                Future.delayed(const Duration(milliseconds: 2009)).then((val) {
                  if (mounted)
                    setState(() {
                      data.add(Card(
                        margin: EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                        child: Center(
                          child: Text('Data '),
                        ),
                      ));
                      _refreshController.loadComplete();
                    });
                });
              },
              child: ListView.builder(
                itemExtent: 100.0,
                itemCount: data.length,
                itemBuilder: (context, index) => Item(title: "data",),
              )),
        ));
  }
}

