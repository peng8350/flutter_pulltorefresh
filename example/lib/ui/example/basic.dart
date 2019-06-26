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
  RefreshController _refreshController1 =
      RefreshController(initialRefresh: true);
  RefreshController _refreshController2 =
  RefreshController(initialRefresh: true);
  RefreshController _refreshController3 =
  RefreshController(initialRefresh: true);
//  int pageIndex = 0;
  List<String> data1 = [],data2 = [],data3 = [];
  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener((){

    });
    super.initState();
  }


  void _onRefresh(RefreshController controller,List<String> data) async {
    //monitor fetch data from network
    await Future.delayed(Duration(milliseconds: 5000));

    if (data.length == 0) {
      for (int i = 0; i < 10; i++) {
        data.add("Item $i");
      }
//      pageIndex++;
    }
    setState(() {});
    controller.refreshCompleted();

    /*
        if(failed){
         _refreshController.refreshFailed();
        }
      */
  }

  void _onLoading(RefreshController controller,List<String> data) async {
    //monitor fetch data from network
    await Future.delayed(Duration(milliseconds: 2000));
    for (int i = 0; i < 10; i++) {
      data.add("Item $i");
    }
//    pageIndex++;
    setState(() {});
    controller.loadComplete();
  }

  Widget buildList() {
    return ListView.separated(
      itemBuilder: (c, i) => Item(
        title: data1[i],
      ),
      separatorBuilder: (context, index) {
        return Container(
          height: 0.5,
          color: Colors.greenAccent,
        );
      },
      itemCount: data1.length,
    );
  }

  Widget buildGrid() {
    return GridView.builder(
      itemBuilder: (c, i) => Item(
        title: data2[i],
      ),
      itemCount: data2.length,
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
            (c, i) => Item(title: data3[i]),
            childCount: data3.length,
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
              controller: _refreshController1,
              enablePullUp: true,
              onRefresh: (){
                _onRefresh(_refreshController1,data1);
              },
              onLoading: (){
                _onLoading(_refreshController1, data1);
              },
            ),
            SmartRefresher(
              child: buildGrid(),
              controller: _refreshController2,
              enablePullUp: true,
              onRefresh: (){
                _onRefresh(_refreshController2,data2);
              },
              onLoading: (){
                _onLoading(_refreshController2, data2);
              },
            ),
            SmartRefresher(
              child: buildCustom(),
              enablePullUp: true,
              controller: _refreshController3,
              onRefresh: (){
                _onRefresh(_refreshController3,data3);
              },
              onLoading: (){
                _onLoading(_refreshController3, data3);
              },
            )
          ],
        ),
      ),
      headerBuilder: () => WaterDropMaterialHeader(backgroundColor: Theme.of(context).primaryColor,),
      footerTriggerDistance: 80.0,

    );
  }
}
