/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/21 下午2:00
 */
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class qqZone extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _qqZoneState();
  }
}

class _qqZoneState extends State<qqZone> {
  RefreshController _refreshController;
  List<Widget> items = [];

  void initData() {
    for (int i = 0; i < 55; i++)
      items.add(Container(
        child: Card(),
        height: 100.0,
      ));
  }

  @override
  void initState() {
    // TODO: implement initState
    _refreshController = RefreshController();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        body: SmartRefresher(
          header: MaterialClassicHeader(
            backgroundColor: Colors.blueAccent,
            distance: 80.0,
          ),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                expandedHeight: 200.0,
                leading: GestureDetector(
                  child: Icon(Icons.arrow_back),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                      height: 100.0,
                      child: Image.asset(
                        "images/qqbg.jpg",
                        fit: BoxFit.cover,
                      )),
                ),
                backgroundColor: Colors.white,
                title: Text("QQ空间"),
                actions: <Widget>[Icon(Icons.verified_user)],
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
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor:
            Colors.white, //Changing this will change the color of the TabBar
      ),
    );
  }
}
