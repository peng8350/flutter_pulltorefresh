import 'dart:async';

import 'package:example/other/RunningHeader.dart';
import 'package:flutter/material.dart' hide RefreshIndicator,RefreshIndicatorState;
import 'package:pull_to_refresh/pull_to_refresh.dart'  ;
import 'package:flutter/cupertino.dart';

class Example4 extends StatefulWidget {
  @override
  _Example4State createState() => _Example4State();
}

class _Example4State extends State<Example4> with TickerProviderStateMixin {
  List<Widget> data = [];
  ScrollController _scrollController;
  bool _enablePullDown = true;
  bool _enablePullUp = true;

  void _getDatas() {
    for (int i = 0; i < 24; i++) {
      data.add(GestureDetector(
        child: Container(
          child: Card(
            color: Colors.redAccent,
            child: Text('Data $i'),
          ),
          height: 100.0,
        ),
        onTap: () {
          /*
            request refresh:
              If your header is FrontStyle,animateTo(0.0),
              else animateTo(-header.triggerDistance)
           */
          _scrollController.animateTo(-80.0);
        },
      ));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _getDatas();
    _scrollController = ScrollController(keepScrollOffset: true);
    Future.delayed(Duration(milliseconds: 3000), () {
      _enablePullDown = false;
      _enablePullUp = false;
      if (mounted) setState(() {});
    });
    Future.delayed(Duration(milliseconds: 6000), () {
      _enablePullDown = true;
      _enablePullUp = true;
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics:RefreshBouncePhysics()
  ,
      slivers: [
        _enablePullDown
            ? RunningHeader.asSliver(onRefresh: () async {
                await Future.delayed(Duration(milliseconds: 3000));
                // return true,it mean refreshCompleted,return false it mean refreshFailed
                return true;
              })
            : null,
        SliverList(delegate: SliverChildListDelegate(data)),
        _enablePullUp
            ? ClassicFooter.asSliver(onLoading: () async {
                await Future.delayed(Duration(milliseconds: 1000));
                //return true it mean set the footerStatus to idle,else set to NoData state
                return true;
              })
            : null
      ].where((child) => child != null).toList(),
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
