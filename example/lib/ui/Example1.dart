import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Example1 extends StatefulWidget {
  Example1({Key key}) : super(key: key);

  @override
  Example1State createState() => new Example1State();
}

class Example1State extends State<Example1> {
//  RefreshMode  refreshing = RefreshMode.idle;
//  LoadMode loading = LoadMode.idle;
  RefreshController _refreshController;
  ScrollController _scrollController;
  List<Widget> data = [];
  void _getDatas() {
    for (int i = 0; i < 4; i++) {
      data.add(new Card(
        margin:
            new EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
        child: new Center(
          child: new Text('Data $i'),
        ),
      ));
    }
  }

  void scrollTop() {
    _scrollController.animateTo(0.0,
        duration: new Duration(microseconds: 1000), curve: ElasticInCurve());
  }

  void enterRefresh() {
    _refreshController.requestRefresh(true);
  }

  void _onOffsetCallback(bool isUp, double offset) {
    // if you want change some widgets state ,you should rewrite the callback
  }

  @override
  void initState() {
    // TODO: implement initState
    _getDatas();
    _scrollController = new ScrollController();
    _refreshController = new RefreshController();
    SchedulerBinding.instance.addPostFrameCallback((_) {
//      _refreshController.requestRefresh(true);
    });
    super.initState();
  }

  Widget _headerCreate(BuildContext context, RefreshStatus mode) {
    return new ClassicIndicator(
      mode: mode,
      refreshingText: "",
      idleIcon: new Container(),
      idleText: "Load more...",
    );
  }

//  Widget _footerCreate(BuildContext context,int mode){
//    return new ClassicIndicator(mode: mode);
//  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(builder: (BuildContext c, BoxConstraints bc) {
      double innerListHeight = data.length * 100.0;
      double listHeight = bc.biggest.height;
      return new Container(
          child: NestedScrollView(
              headerSliverBuilder: (c, s) => [
                    SliverPersistentHeader(
                        delegate: _SliverDelegate(
                            child: Container(
                      height: 100.0,
                      color: Colors.red,
                    ))),
                    SliverAppBar(
                      backgroundColor: Colors.brown,
                      expandedHeight: 300.0,
                      floating: false,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(

                          centerTitle: true,
                          background: Image.network("https://images.unsplash.com/photo-1541701494587-cb58502866ab?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=0c21b1ac3066ae4d354a3b2e0064c8be&auto=format&fit=crop&w=500&q=60",fit: BoxFit.cover,)
                      ),
                    ),
                  ],
              body: new SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  isNestWrapped: true,
                  enablePullUp: innerListHeight > listHeight,
                  onRefresh: (up) {
                    if (up)
                      new Future.delayed(const Duration(milliseconds: 2009))
                          .then((val) {
                        data.add(new Card(
                          margin: new EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                          child: new Center(
                            child: new Text('Data '),
                          ),
                        ));

                        setState(() {
                          _refreshController.sendBack(
                              true, RefreshStatus.completed);
                        });
                      });
                    else {
                      new Future.delayed(const Duration(milliseconds: 2009))
                          .then((val) {
                        setState(() {
                          data.add(new Card(
                            margin: new EdgeInsets.only(
                                left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                            child: new Center(
                              child: new Text('Data '),
                            ),
                          ));
                          _refreshController.sendBack(
                              false, RefreshStatus.idle);
                        });
                      });
                    }
                  },
                  onOffsetChange: _onOffsetCallback,
                  child: new ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    itemExtent: 100.0,
                    itemCount: data.length,
                    itemBuilder: (context, index) => new Item(),
                  ))));
    });
//    return new ListView(
//      children: [
//        Container(
//          height: 100.0,
//          color: Colors.green,
//        ),
//        new Container(
//          child: PrimaryScrollController(controller: _scrollController, child: new SmartRefresher(
//              controller: _refreshController,
//              enablePullDown: true,
//              isScrollWrapped: true,
//              onRefresh: (up) {
//                if (up)
//                  new Future.delayed(const Duration(milliseconds: 2009))
//                      .then((val) {
//                    data.add(new Card(
//                      margin: new EdgeInsets.only(
//                          left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
//                      child: new Center(
//                        child: new Text('Data '),
//                      ),
//                    ));
//
//                    setState(() {
//                      _refreshController.sendBack(
//                          true, RefreshStatus.completed);
//                    });
//                  });
//                else {
//                  new Future.delayed(const Duration(milliseconds: 2009))
//                      .then((val) {
//                    setState(() {
//                      data.add(new Card(
//                        margin: new EdgeInsets.only(
//                            left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
//                        child: new Center(
//                          child: new Text('Data '),
//                        ),
//                      ));
//                      _refreshController.sendBack(false, RefreshStatus.idle);
//                    });
//                  });
//                }
//              },
//              onOffsetChange: _onOffsetCallback,
//              child: new ListView.builder(
//                reverse: true,
//                controller: _scrollController,
//                itemExtent: 100.0,
//                itemCount: data.length,
//                itemBuilder: (context, index) => new Item(),
//              ))),
//          height: 500.0,
//        )
//      ],
//    );
  }
}

class Item extends StatefulWidget {
  @override
  _ItemState createState() => new _ItemState();
}

class _ItemState extends State<Item> {
  @override
  Widget build(BuildContext context) {
    return new Card(
      margin:
          new EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
      child: new Center(
        child: new Text('Data'),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
