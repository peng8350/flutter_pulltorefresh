import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class NestedRefreshState extends State<NestedRefresh>
    with SingleTickerProviderStateMixin {
//  RefreshMode  refreshing = RefreshMode.idle;
//  LoadMode loading = LoadMode.idle;
  RefreshController _refreshController;
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

  void enterRefresh() {
    _refreshController.requestRefresh();
  }

  @override
  void initState() {
    // TODO: implement initState
    _getDatas();
    _refreshController = RefreshController(initialRefresh: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 4,
        child: NestedScrollView(
            headerSliverBuilder: (c, s) => [
                  SliverAppBar(
                    expandedHeight: 206.0,
                    pinned: true,
                    floating: true,
                    flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        background: Image.network(
                          "https://images.unsplash.com/photo-1541701494587-cb58502866ab?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=0c21b1ac3066ae4d354a3b2e0064c8be&auto=format&fit=crop&w=500&q=60",
                          fit: BoxFit.cover,
                        )),
                    bottom: TabBar(
                      tabs: <Widget>[
                        Tab(
                          child: Text("tab1"),
                        ),
                        Tab(
                          child: Text("tab2"),
                        ),
                        Tab(
                          child: Text("tab3"),
                        ),
                        Tab(
                          child: Text("tab4"),
                        )
                      ],
                    ),
                  ),
                ],
            body: TabBarView(
              children: <Widget>[
                RefreshListView(),
                RefreshListView(),
                RefreshListView(),
                RefreshListView()
              ],
            )),
      ),
    );
  }
}

class RefreshListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RefreshListViewState();
  }
}

class _RefreshListViewState extends State<RefreshListView> {
  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 250));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    items.add((items.length + 1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text("pull up load");
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text("Load Failed!Click retry!");
          } else if (mode == LoadStatus.canLoading) {
            body = Text("Release to Load more");
          } else {
            body = Text("No more Data");
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        physics: ClampingScrollPhysics(),
        itemBuilder: (c, i) => Card(child: Center(child: Text(items[i]))),
        itemExtent: 100.0,
        itemCount: items.length,
      ),
    );
  }

  // don't forget to dispose refreshController
  @override
  void dispose() {
    // TODO: implement dispose
    _refreshController.dispose();
    super.dispose();
  }
}
