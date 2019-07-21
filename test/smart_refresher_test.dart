/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime: 2019-07-20 22:15
 */


import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/widgets.dart';
import 'dataSource.dart';
import 'test_indicator.dart';



void main() {
  testWidgets("param check ", (tester) async {
    final RefreshController _refreshController = RefreshController();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SmartRefresher(
        header: TestHeader(),
        footer: TestFooter(),
        enablePullUp: true,
        enablePullDown: true,
        child: ListView.builder(
          itemBuilder: (c, i) =>
              Center(
                child: Text(data[i]),
              ),
          itemCount: 20,
          itemExtent: 100,
        ),
        controller: _refreshController,
      ),
    ));
    RenderViewport viewport = tester.renderObject(find.byType(Viewport));
    expect(viewport.childCount,3);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SmartRefresher(
        header: TestHeader(),
        footer: TestFooter(),
        enablePullUp: true,
        enablePullDown: false,
        child: ListView.builder(
          itemBuilder: (c, i) =>
              Center(
                child: Text(data[i]),
              ),
          itemCount: 20,
          itemExtent: 100,
        ),
        controller: _refreshController,
      ),
    ));
    viewport = tester.renderObject(find.byType(Viewport));
    expect(viewport.childCount,2);
    expect(viewport.firstChild.runtimeType,RenderSliverFixedExtentList);
    final List<dynamic> logs = [];
    // check enablePullDown,enablePullUp
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SmartRefresher(
        header: TestHeader(),
        footer: TestFooter(),
        enablePullDown: true,
        enablePullUp: true,
        child: ListView.builder(
          itemBuilder: (c, i) =>
              Center(
                child: Text(data[i]),
              ),
          itemCount: 20,
          itemExtent: 100,
        ),
        onRefresh: (){

          logs.add("refresh");
        },
        onLoading: (){

          logs.add("loading");
        },
        controller: _refreshController,
      ),
    ));

    // check onRefresh,onLoading
    await tester.drag(find.byType(Scrollable), Offset(0,100.0),touchSlopY:0.0 );
    await tester.pump(Duration(milliseconds: 20));
    await tester.pump(Duration(milliseconds: 20));
    expect(logs.length, 1);
    expect(logs[0], "refresh");
    logs.clear();
    _refreshController.refreshCompleted();
    await tester.pumpAndSettle(Duration(milliseconds: 600));

    await tester.drag(find.byType(Scrollable), Offset(0,-4000.0),touchSlopY:0.0 );
    await tester.pump(Duration(milliseconds: 20)); //canRefresh
    await tester.pump(Duration(milliseconds: 20)); //refreshing
    expect(logs.length, 1);
    expect(logs[0], "loading");
    logs.clear();
    _refreshController.loadComplete();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SmartRefresher(
        header: TestHeader(),
        footer: TestFooter(),
        enablePullDown: true,
        enablePullUp: true,
        child: ListView.builder(
          itemBuilder: (c, i) =>
              Center(
                child: Text(data[i]),
              ),
          itemCount: 20,
          itemExtent: 100,
        ),
        onOffsetChange: (up,offset){
          logs.add(offset);
        },
        controller: _refreshController,
      ),
    ));

    // check onOffsetChange(top)
    _refreshController.position.jumpTo(0.0);
    double count = 1;
    while(count<11){
      await tester.drag(find.byType(Scrollable), Offset(0,20),touchSlopY:0.0 );
      count++;
      await tester.pump(Duration(milliseconds: 20));
    }
    for(double i in logs){
      expect(i, greaterThanOrEqualTo(0));
    }
    logs.clear();
    // check onOffsetChange
    _refreshController.position.jumpTo(_refreshController.position.maxScrollExtent);
    count = 1;
    while(count<11){
      await tester.drag(find.byType(Scrollable), Offset(0,-20),touchSlopY:0.0 );
      count++;
      await tester.pump(Duration(milliseconds: 20));
    }
    expect(logs.length , greaterThan(0));
    for(double i in logs){
      expect(i, greaterThanOrEqualTo(0));
    }
    logs.clear();
    await tester.pump(Duration(milliseconds: 20));
  });


}