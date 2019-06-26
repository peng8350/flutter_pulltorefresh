/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-26 11:36
 */

/*
  the basic usage
*/

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../Item.dart';

class BasicExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BasicExampleState();
  }
}

class _BasicExampleState extends State<BasicExample>
    with SingleTickerProviderStateMixin {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  int pageIndex = 0;
  List<String> data = [];
  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  void _onRefresh() async {
    //monitor fetch data from network
    await Future.delayed(Duration(milliseconds: 2000));

    if (data.length == 0) {
      for (int i = 0; i < 10; i++) {
        data.add("Item $i");
      }
      pageIndex++;
    }
    setState(() {});
    _refreshController.refreshCompleted();

    /*
        if(failed){
         _refreshController.refreshFailed();
        }
      */
  }

  void _onLoading() async {
    //monitor fetch data from network
    await Future.delayed(Duration(milliseconds: 2000));
    for (int i = 0; i < 10; i++) {
      data.add("Item $i");
    }
    pageIndex++;
    setState(() {});
    _refreshController.loadComplete();
  }

  Widget buildList() {
    return ListView.separated(
      itemBuilder: (c, i) => Item(
        title: data[i],
      ),
      separatorBuilder: (context, index) {
        return Container(
          height: 0.5,
          color: Colors.greenAccent,
        );
      },
      itemCount: data.length,
    );
  }

  Widget buildGrid() {
    return GridView.builder(
      itemBuilder: (c, i) => Item(
        title: data[i],
      ),
      itemCount: data.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
    );
  }

  Widget buildCustom() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text("SliverAppBar"),
          expandedHeight: 100.0,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (c, i) => Item(title: data[i]),
            childCount: data.length,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RefreshConfiguration(
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            tabs: <Widget>[
              Tab(
                text: "ListView",
              ),
              Tab(
                text: "GridView",
              ),
              Tab(
                text: "CustomScrollView",
              )
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,

          children: <Widget>[
            SmartRefresher(
              child: buildList(),
              controller: _refreshController,
              enablePullUp: true,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
            ),
            SmartRefresher(
              child: buildGrid(),
              controller: _refreshController,
              enablePullUp: true,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
            ),
            SmartRefresher(
              child: buildCustom(),
              enablePullUp: true,
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
            )
          ],
        ),
      ),
      headerBuilder: () => WaterDropMaterialHeader(backgroundColor: Theme.of(context).primaryColor,),
      footerTriggerDistance: 80.0,

    );
  }
}
