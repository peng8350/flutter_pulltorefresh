/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/21 下午12:35
 */

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BiliBiliScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BiliBiliScreenState();
  }
}

class _BiliBiliScreenState extends State<BiliBiliScreen> with SingleTickerProviderStateMixin{
  RefreshController _refreshController;
  List<Widget> items = [];

  void initData() {

    for (int i = 0; i < 55; i++) items.add(Container(child: Card(),height: 100.0,));
  }
TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState
    _refreshController = RefreshController();
    _tabController = TabController(length: 4, vsync: this);
    initData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home:Scaffold(
        body: SmartRefresher(
          header: WaterDropMaterialHeader(backgroundColor: Colors.pink,),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                forceElevated: true,
                leading: Icon(Icons.add),
                backgroundColor: Colors.pink,
                title: Text("哔哩哔哩"),
                actions: <Widget>[Icon(Icons.verified_user)],
              ),
              SliverAppBar(
                flexibleSpace: FlexibleSpaceBar(
                  title: TabBar(tabs: [Tab(text: 'Tab1',),Tab(text: 'Tab2',),Tab(text: 'Tab3',),Tab(text: 'Tab1',)],controller: _tabController,),

                ),
                pinned: true,
                leading: Container(),

              ),
              SliverList(delegate: SliverChildListDelegate(items))
            ],
          ),
          controller: _refreshController,
          onRefresh: () {
            Future.delayed(Duration(milliseconds: 1500)).whenComplete(() {
              _refreshController.refreshCompleted();
            });
          },
        ),
      ),
      theme: ThemeData( brightness: Brightness.light,
        primaryColor: Colors.white, //Changing this will change the color of the TabBar
        ),
    );
  }
}
