/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-26 13:28
 */

/*
   use to place indicator to other places,such as WeChat friend circle refresh effect
   int 1.4.7 version will add it
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../Item.dart';

class LinkHeaderExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LinkHeaderExampleState();
  }
}

class _LinkHeaderExampleState extends State<LinkHeaderExample> {
  RefreshController _refreshController = RefreshController();
  final Key linkKey = GlobalKey();
  List<String> data = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];
  final ScrollController _scrollController = ScrollController();
  bool dismissAppbar = false;

  @override
  void initState() {
    // TODO: implement initState
    _scrollController.addListener(() {
      final bool ifdismissAppbar = _scrollController.offset >= 136.0;
      if (dismissAppbar != ifdismissAppbar) {
        if (mounted) setState(() {});
      }
      dismissAppbar = ifdismissAppbar;
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RefreshConfiguration.copyAncestor(
      context: context,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Positioned(
                  top: -150.0,
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: SmartRefresher(
                    controller: _refreshController,
                    header: LinkHeader(linkKey: linkKey),
                    onRefresh: () async {
                      await Future.delayed(Duration(milliseconds: 3000));
                      _refreshController.refreshCompleted();
                    },
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: Image.asset(
                            "images/qqbg.jpg",
                            fit: BoxFit.fill,
                            height: 300.0,
                          ),
                        ),
                        SliverFixedExtentList(
                          delegate: SliverChildBuilderDelegate(
                              (c, i) => Item(
                                    title: data[i],
                                  ),
                              childCount: data.length),
                          itemExtent: 100.0,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            Container(
              height: 64.0,
              child: AppBar(
                backgroundColor:
                    dismissAppbar ? Colors.blueAccent : Colors.transparent,
                elevation: dismissAppbar ? 1.0 : 0.0,
                title: SimpleLinkBar(
                  key: linkKey,
                ),
              ),
            )
          ],
        ),
      ),
      maxOverScrollExtent: 100,
    );
  }
}

class SimpleLinkBar extends StatefulWidget {
  SimpleLinkBar({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SimpleLinkBarState();
  }
}

class _SimpleLinkBarState extends State<SimpleLinkBar>
    with RefreshProcessor, SingleTickerProviderStateMixin {
  RefreshStatus _status = RefreshStatus.idle;
  AnimationController _animationController;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    _animationController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  Future endRefresh() {
    // TODO: implement endRefresh
    _animationController.animateTo(0.0, duration: Duration(milliseconds: 300));
    return Future.value();
  }

  @override
  void onOffsetChange(double offset) {
    // TODO: implement onOffsetChange
    if (_status != RefreshStatus.refreshing)
      _animationController.value = offset / 80.0;
    super.onOffsetChange(offset);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScaleTransition(
      child: CupertinoActivityIndicator(),
      scale: _animationController,
    );
  }

  @override
  void onModeChange(RefreshStatus mode) {
    // TODO: implement onModeChange
    super.onModeChange(mode);
    _status = mode;
    setState(() {});
  }
}
