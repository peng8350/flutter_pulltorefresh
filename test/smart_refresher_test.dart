/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime: 2019-07-20 22:15
 */


import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart' as prefix0;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/widgets.dart';

import 'dataSource.dart';
import 'test_indicator.dart';



void main(){

  testWidgets("trigger refresh  function ", (tester) async{
    final RefreshController _refreshController = RefreshController(initialRefresh: true);
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SmartRefresher(
        header: TestHeader(),
        footer: TestFooter(),
        enablePullUp: true,
        enablePullDown: true,
        child: ListView.builder(
          itemBuilder: (c,i) => Center(
            child: Text(data[i]),
          ),
          itemCount: 20,
          itemExtent: 100,
        ),
        controller: _refreshController,
      ),
    ));

    // from 0.0 drop down, not enough tigger
    await tester.drag(find.byType(Scrollable), Offset(0,50.0),touchSlopY:0.0 );
    await tester.pump();
    expect(_refreshController.headerStatus, RefreshStatus.idle);
    await tester.pumpAndSettle(Duration(milliseconds: 600));

    // stick to check
    _refreshController.position.jumpTo(0.0);
    await tester.pump(Duration(milliseconds: 100));
    await tester.drag(find.byType(Scrollable), Offset(0,79.999999999),touchSlopY:0.0 );
    expect(_refreshController.headerStatus, RefreshStatus.idle);
    await tester.pumpAndSettle(Duration(milliseconds: 600));

    // from 0.0 drop down
    await tester.drag(find.byType(Scrollable), Offset(0,80.0),touchSlopY:0.0 );
    await tester.pump();
    expect(_refreshController.headerStatus, RefreshStatus.canRefresh);
    await tester.pumpAndSettle(Duration(milliseconds: 100));
    expect(_refreshController.headerStatus, RefreshStatus.refreshing);
    _refreshController.refreshCompleted();
    await tester.pumpAndSettle(Duration(milliseconds: 600));

    // from 100.0 drop down
    _refreshController.position.jumpTo(100.0);
    await tester.pump(Duration(milliseconds: 100));
    await tester.drag(find.byType(Scrollable), Offset(0,180.0),touchSlopY:0.0 );
    expect(_refreshController.headerStatus, RefreshStatus.canRefresh);
    await tester.pumpAndSettle(Duration(milliseconds: 100));
    expect(_refreshController.headerStatus, RefreshStatus.refreshing);
    _refreshController.refreshCompleted();
    await tester.pumpAndSettle(Duration(milliseconds: 600));

    // when user flip with ballistic,it should not be tigger rrerfresh
    _refreshController.position.jumpTo(400.0);
    await tester.fling(find.byType(Viewport), Offset(0,100.0),2000.0);
    while (tester.binding.transientCallbackCount > 0) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(_refreshController.headerStatus, RefreshStatus.idle);
    await tester.pumpAndSettle(Duration(milliseconds: 600));

    // when user flip with ballistic from 0.0,it should not be tigger rrerfresh also
    _refreshController.position.jumpTo(0.0);
    await tester.fling(find.byType(Viewport), Offset(0,100.0),2000.0);
    while (tester.binding.transientCallbackCount > 0) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(_refreshController.headerStatus, RefreshStatus.idle);
    await tester.pumpAndSettle(Duration(milliseconds: 600));

    // consider about another situation,if user trriiger refresh, and then drag down(cannot see the header)
    _refreshController.position.jumpTo(0.0);
    await tester.drag(find.byType(Viewport), Offset(0,100.0),touchSlopY:0.0);
    await tester.pump(); // refresh to canRefresh
    expect(_refreshController.headerStatus, RefreshStatus.canRefresh);
    await tester.pump(Duration(milliseconds: 100));
    expect(_refreshController.headerStatus, RefreshStatus.refreshing);
    await tester.drag(find.byType(Viewport), Offset(0,-90.0));
    await tester.pumpAndSettle();
    final double positionRecord = _refreshController.position.pixels;
    _refreshController.refreshCompleted();
    await tester.pumpAndSettle(Duration(milliseconds: 600));
    expect(_refreshController.position.pixels==positionRecord-60.0, true);//60.0 is indicator  visual extent
    expect(_refreshController.headerStatus, RefreshStatus.idle);
  });
}