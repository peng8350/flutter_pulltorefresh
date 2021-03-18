/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime: 2019-07-21 12:22
 */

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'dataSource.dart';
import 'test_indicator.dart';

void main() {
  group("trigger refresh function test", () {
    testWidgets("not enough to tigger refresh ", (tester) async {
      final RefreshController _refreshController =
          RefreshController(initialRefresh: false);
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 20,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
      ));

      await tester.drag(find.byType(Scrollable), Offset(0, 50.0),
          touchSlopY: 0.0);
      await tester.pump();
      expect(_refreshController.headerStatus, RefreshStatus.idle);
      await tester.pumpAndSettle(Duration(milliseconds: 600));
    });

    testWidgets("strick to check triggerDistance,even if 0.00001",
        (tester) async {
      final RefreshController _refreshController =
          RefreshController(initialRefresh: false);
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 20,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
      ));

      _refreshController.position!.jumpTo(0.0);
      await tester.pump(Duration(milliseconds: 100));
      await tester.drag(find.byType(Scrollable), Offset(0, 79.999999999),
          touchSlopY: 0.0);
      await tester.pump();
      expect(_refreshController.headerStatus, RefreshStatus.idle);
      await tester.pumpAndSettle(Duration(milliseconds: 600));
    });
    testWidgets("from 0.0 pull down,reach triggerDistance", (tester) async {
      final RefreshController _refreshController =
          RefreshController(initialRefresh: false);
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 20,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
      ));
      await tester.drag(find.byType(Scrollable), Offset(0, 80.0),
          touchSlopY: 0.0);
      await tester.pump();
      expect(_refreshController.headerStatus, RefreshStatus.canRefresh);
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      expect(_refreshController.headerStatus, RefreshStatus.refreshing);
      _refreshController.refreshCompleted();
      await tester.pumpAndSettle(Duration(milliseconds: 600));
    });
    testWidgets("from 100.0 pull down,reach triggerdistance", (tester) async {
      final RefreshController _refreshController =
          RefreshController(initialRefresh: false);
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 20,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
      ));

      _refreshController.position!.jumpTo(100.0);
      await tester.pump(Duration(milliseconds: 100));
      await tester.drag(find.byType(Scrollable), Offset(0, 180.0),
          touchSlopY: 0.0);
      expect(_refreshController.headerStatus, RefreshStatus.canRefresh);
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      expect(_refreshController.headerStatus, RefreshStatus.refreshing);
      _refreshController.refreshCompleted();
      await tester.pumpAndSettle(Duration(milliseconds: 600));
    });
    testWidgets(
        "when user flip with ballistic,it should not be tigger rrerfresh ",
        (tester) async {
      final RefreshController _refreshController =
          RefreshController(initialRefresh: false);
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 20,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
      ));

      _refreshController.position!.jumpTo(400.0);
      await tester.fling(find.byType(Viewport), Offset(0, 100.0), 2000.0);
      while (tester.binding.transientCallbackCount > 0) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(_refreshController.headerStatus, RefreshStatus.idle);
      await tester.pumpAndSettle(Duration(milliseconds: 600));
    });
    testWidgets(
        " when user flip with ballistic from 0.0,it should not be tigger rrerfresh also",
        (tester) async {
      final RefreshController _refreshController =
          RefreshController(initialRefresh: false);
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 20,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
      ));

      _refreshController.position!.jumpTo(0.0);
      await tester.fling(find.byType(Viewport), Offset(0, 100.0), 2000.0);
      while (tester.binding.transientCallbackCount > 0) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(_refreshController.headerStatus, RefreshStatus.idle);
      await tester.pumpAndSettle(Duration(milliseconds: 600));
    });
    testWidgets(
        "consider about another situation,if user trriiger refresh, and then drag down(cannot see the header)",
        (tester) async {
      final RefreshController _refreshController =
          RefreshController(initialRefresh: false);
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 20,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
      ));

      _refreshController.position!.jumpTo(0.0);
      await tester.drag(find.byType(Viewport), Offset(0, 100.0),
          touchSlopY: 0.0);
      await tester.pump(); // refresh to canRefresh
      expect(_refreshController.headerStatus, RefreshStatus.canRefresh);
      await tester.pump(Duration(milliseconds: 100));
      expect(_refreshController.headerStatus, RefreshStatus.refreshing);
      await tester.drag(find.byType(Viewport), Offset(0, -90.0));
      await tester.pumpAndSettle();
      final double positionRecord = _refreshController.position!.pixels;
      _refreshController.refreshCompleted();
      await tester.pumpAndSettle(Duration(milliseconds: 600));
      expect(_refreshController.position!.pixels == positionRecord - 60.0,
          true); //60.0 is indicator  visual extent
      await tester.pump(Duration(milliseconds: 600));
      expect(_refreshController.headerStatus, RefreshStatus.idle);
    });
  });

  testWidgets("verity headerTriggerDistance", (tester) async {
    final RefreshController _refreshController = RefreshController();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: RefreshConfiguration(
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 20,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
        maxOverScrollExtent: 100.0,
        headerTriggerDistance: 100.0,
      ),
    ));

    _refreshController.position!.jumpTo(0.0);
    await tester.pump(Duration(milliseconds: 100));
    await tester.drag(find.byType(Scrollable), Offset(0, 99.999999999),
        touchSlopY: 0.0);
    await tester.pump();
    expect(_refreshController.headerStatus, RefreshStatus.idle);
    await tester.pumpAndSettle(Duration(milliseconds: 600));
    expect(_refreshController.headerStatus, RefreshStatus.idle);

    _refreshController.position!.jumpTo(0.0);
    await tester.pump(Duration(milliseconds: 100));
    await tester.drag(find.byType(Scrollable), Offset(0, 100.999999999),
        touchSlopY: 0.0);
    await tester.pump();
    expect(_refreshController.headerStatus, RefreshStatus.canRefresh);
    await tester.pumpAndSettle(Duration(milliseconds: 200));
    expect(_refreshController.headerStatus, RefreshStatus.refreshing);
  });

  testWidgets("without refresh function ,only twoLevel", (tester) async {
    final RefreshController _refreshController = RefreshController();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: RefreshConfiguration(
        child: SmartRefresher(
          header: ClassicHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: false,
          enableTwoLevel: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 20,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
        maxOverScrollExtent: 100.0,
      ),
    ));

    await tester.drag(find.byType(Scrollable), Offset(0, 155.999999999),
        touchSlopY: 0.0);
    await tester.pump();
    expect(_refreshController.position!.pixels, -155.999999999);
    expect(_refreshController.headerStatus, RefreshStatus.canTwoLevel);
    await tester.pumpAndSettle();
    expect(_refreshController.headerStatus, RefreshStatus.twoLeveling);
    _refreshController.twoLevelComplete();
    await tester.pumpAndSettle();
    expect(_refreshController.headerStatus, RefreshStatus.idle);
    await tester.drag(find.byType(Scrollable), Offset(0, 100.999999999),
        touchSlopY: 0.0);
    await tester.pumpAndSettle();
    expect(_refreshController.headerStatus, RefreshStatus.idle);
    expect(_refreshController.position!.pixels, 0.0);
  });
}
