import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide RefreshIndicator;
import 'package:flutter/cupertino.dart';

class Example4 extends StatefulWidget {
  @override
  _Example4State createState() => _Example4State();
}

class _Example4State extends State<Example4> with TickerProviderStateMixin {
  List<Widget> data = [];
  RefreshController _refreshController;
  ScrollController _scrollController;
  ValueNotifier<RefreshStatus> headeMode = ValueNotifier(RefreshStatus.idle);
  ValueNotifier<LoadStatus> footerMode = ValueNotifier(LoadStatus.idle);

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
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
            delegate: _SliverDelegate(
                child: Container(
          height: 300.0,
          color: Colors.red,
        ))),
        ClassicHeader.asSliver(
            mode: headeMode
            ,onRefresh: () {
          return Future.value(true);
        }),
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
        SliverList(delegate: SliverChildListDelegate(data)),
        ClassicFooter.asSliver(onLoading: () async {
          await Future.delayed(Duration(milliseconds: 1000));
          return true;
        },mode: footerMode,)
      ],
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
