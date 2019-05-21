import 'dart:async';

import 'package:flutter/material.dart' ;
import 'package:pull_to_refresh/pull_to_refresh.dart' hide RefreshIndicator;
import 'package:flutter/cupertino.dart';

class Example4 extends StatefulWidget {
  @override
  _Example4State createState() => _Example4State();
}

class _Example4State extends State<Example4> with TickerProviderStateMixin {
  List<Widget> data = [];
  RefreshController _refreshController;
  ScrollController _scrollController ;

  void _getDatas() {
    for (int i = 0; i < 24; i++) {
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
    _scrollController = ScrollController(keepScrollOffset: true);
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
    return Container(
      color: Colors.white,
      child: SmartRefresher(
          enablePullUp: true ,
          footer: ClassicFooter(hideWhenNotFull: false,),
          child: CustomScrollView(
            key: PageStorageKey("r"),
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(),
              SliverPersistentHeader(
                  delegate: _SliverDelegate(
                      child: Container(
                        height: 300.0,
                        color: Colors.red,
                      ))),
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
              SliverList(
                  delegate: SliverChildListDelegate(data))
            ],
          ),
          controller: _refreshController),
    );
  }
}


class _SliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverDelegate({this.child});

  @override
  // TODO: implement minExtent
  double get minExtent => 50.0;

  @override
  // TODO: implement maxExtent
  double get maxExtent => 100.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    return child;
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    // TODO: implement shouldRebuild
    return false;
  }


}
