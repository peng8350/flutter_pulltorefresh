/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/7 下午12:19
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class AppBarHeader extends StatefulWidget {
  @override
  _AppBarHeaderState createState() => new _AppBarHeaderState();
}

class _AppBarHeaderState extends State<AppBarHeader> {
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

  List<Widget> buildList() {
    List<Widget> items = [];

    for (int i = 0; i < 10; i++) {
      items.add(Text('样例数据'));
    }
    return items;
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
    return Container(
      color: Colors.white,
      child: SmartRefresher(
        headerInsertIndex: 1,
        enablePullDown: true,
        enablePullUp: true,
        child: CustomScrollView(
          slivers: [
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
            SliverList(delegate: SliverChildListDelegate(buildList()))
          ],
        ),
        controller: _refreshController,
        onRefresh: () {
          _refreshController.refreshCompleted();
        },
        header: WaterDropMaterialHeader(),
      ),
    );
  }
}
