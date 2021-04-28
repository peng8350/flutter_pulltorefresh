/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime: 2019-07-21 13:20
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'dataSource.dart';
import 'test_indicator.dart';

void main() {
  group("in Android ClampingScrollPhysics", () {
    testWidgets(
        "clamping physics,when user flip gesture up ,it shouldn't move out of viewport area",
        (tester) async {
      final RefreshController _refreshController = RefreshController();
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 23,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
      ));
      await tester.fling(find.byType(Viewport), const Offset(0, 100), 5200);
      while (tester.binding.transientCallbackCount > 0) {
        expect(
            _refreshController.position!.pixels, greaterThanOrEqualTo(-250.0));
        await tester.pump(const Duration(milliseconds: 20));
      }

      // from bottom flip up
      _refreshController.position!
          .jumpTo(_refreshController.position!.maxScrollExtent);
      await tester.fling(find.byType(Viewport), const Offset(0, 1000), 5200);
      while (tester.binding.transientCallbackCount > 0) {
        expect(
            _refreshController.position!.pixels, greaterThanOrEqualTo(-250.0));
        await tester.pump(const Duration(milliseconds: 20));
      }

      await tester.fling(find.byType(Viewport), const Offset(0, -100), 5200);
      while (tester.binding.transientCallbackCount > 0) {
        expect(
            _refreshController.position!.pixels -
                _refreshController.position!.maxScrollExtent,
            lessThanOrEqualTo(250.0));
        await tester.pump(const Duration(milliseconds: 20));
      }

      // from bottom flip up
      _refreshController.position!
          .jumpTo(_refreshController.position!.maxScrollExtent);
      await tester.fling(find.byType(Viewport), const Offset(0, -43000), 5200);
      while (tester.binding.transientCallbackCount > 0) {
        expect(
            _refreshController.position!.pixels -
                _refreshController.position!.maxScrollExtent,
            lessThanOrEqualTo(250.0));
        await tester.pump(const Duration(milliseconds: 20));
      }
    });

    testWidgets("verity if it will spring back when jumpto", (tester) async {
      final RefreshController _refreshController = RefreshController();
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 23,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
      ));

      _refreshController.position!.jumpTo(-100.0);
      expect(_refreshController.position!.pixels, -100.0);
      while (tester.binding.transientCallbackCount > 0) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(_refreshController.position!.pixels, 0.0);
    });

    testWidgets("When clamping,enablePullDown = false,it shouldn't overscroll",
        (tester) async {
      final RefreshController _refreshController = RefreshController();
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: false,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 23,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
      ));

      await tester.fling(find.byType(Viewport), Offset(0, 100.0), 1000);
      while (tester.binding.transientCallbackCount > 0) {
        expect(_refreshController.position!.pixels, 0.0);
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(_refreshController.position!.pixels, 0.0);

      // just little middle
      _refreshController.position!.jumpTo(200.0);
      await tester.fling(find.byType(Viewport), Offset(0, 100.0), 1000);
      while (tester.binding.transientCallbackCount > 0) {
        expect(_refreshController.position!.pixels, greaterThanOrEqualTo(0.0));
        await tester.pump(const Duration(milliseconds: 20));
      }

      // the most doubt stiuation,from bottomest fliping to top
      _refreshController.position!
          .jumpTo(_refreshController.position!.maxScrollExtent);
      await tester.fling(find.byType(Viewport), Offset(0, 1000.0), 5000);
      while (tester.binding.transientCallbackCount > 0) {
        expect(_refreshController.position!.pixels, greaterThanOrEqualTo(0.0));
        await tester.pump(const Duration(milliseconds: 20));
      }
    });
  });

  testWidgets("maxOverScrollExtent or maxUnderScrollExtent verity ",
      (tester) async {
    final RefreshController _refreshController = RefreshController();
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(platform: TargetPlatform.android),
      home: RefreshConfiguration(
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 23,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
        maxOverScrollExtent: 240.0,
        maxUnderScrollExtent: 240.0,
      ),
    ));

    await tester.drag(find.byType(Viewport), Offset(0, 300.0));
    while (tester.binding.transientCallbackCount > 0) {
      expect(_refreshController.position!.pixels, greaterThanOrEqualTo(-300));
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(_refreshController.position!.pixels, 0.0);

    _refreshController.position!
        .jumpTo(_refreshController.position!.maxScrollExtent);
    await tester.fling(find.byType(Viewport), Offset(0, -1000.0), 5000);
    while (tester.binding.transientCallbackCount > 0) {
      expect(
          _refreshController.position!.pixels -
              _refreshController.position!.maxScrollExtent,
          lessThanOrEqualTo(300.0));
      await tester.pump(const Duration(milliseconds: 20));
    }
  });

  testWidgets("verity if refresh physics updated ", (tester) async {
    final RefreshController refreshController = RefreshController();
    await tester.pumpWidget(MaterialApp(
      home: RefreshConfiguration(
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 23,
            itemExtent: 100,
          ),
          controller: refreshController,
        ),
        maxOverScrollExtent: 200.0,
        maxUnderScrollExtent: 300.0,
      ),
    ));
    expect(
        (refreshController.position!.physics as RefreshPhysics).updateFlag, 1);
    await tester.pumpWidget(MaterialApp(
      home: RefreshConfiguration(
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 23,
            itemExtent: 100,
          ),
          controller: refreshController,
        ),
        maxOverScrollExtent: 150.0,
        maxUnderScrollExtent: 300.0,
      ),
    ));
    expect(
        (refreshController.position!.physics as RefreshPhysics).updateFlag, 0);
    expect(
        (refreshController.position!.physics as RefreshPhysics)
            .maxOverScrollExtent,
        150);

    await tester.pumpWidget(MaterialApp(
      home: RefreshConfiguration(
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 23,
            itemExtent: 100,
          ),
          controller: refreshController,
        ),
        maxOverScrollExtent: 200.0,
        maxUnderScrollExtent: 300.0,
      ),
    ));
    expect(
        (refreshController.position!.physics as RefreshPhysics).updateFlag, 1);
    await tester.pumpWidget(MaterialApp(
      home: RefreshConfiguration(
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 23,
            itemExtent: 100,
          ),
          controller: refreshController,
        ),
        maxOverScrollExtent: 200.0,
        maxUnderScrollExtent: 300.0,
      ),
    ));
    expect(
        (refreshController.position!.physics as RefreshPhysics).updateFlag, 1);
  });

  testWidgets("when viewport not full, pull up can trigger loading",
      (tester) async {
    final RefreshController _refreshController = RefreshController();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: RefreshConfiguration(
        child: SmartRefresher(
          header: TestHeader(),
          footer: CustomFooter(
            loadStyle: LoadStyle.ShowAlways,
            builder: (c, m) => Container(),
          ),
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 1,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
        footerTriggerDistance: -30.0,
      ),
    ));

    await tester.drag(find.byType(Scrollable), const Offset(0, -70.0));
    await tester.pumpAndSettle(Duration(milliseconds: 2));
    expect(_refreshController.footerStatus, LoadStatus.loading);
    expect(_refreshController.position!.pixels, greaterThanOrEqualTo(0.0));

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: RefreshConfiguration(
        child: SmartRefresher(
          header: TestHeader(),
          footer: CustomFooter(
            loadStyle: LoadStyle.HideAlways,
            builder: (c, m) => Container(),
          ),
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 1,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
        footerTriggerDistance: -30.0,
      ),
    ));

    await tester.drag(find.byType(Scrollable), const Offset(0, -70.0));
    await tester.pumpAndSettle(Duration(milliseconds: 2));
    expect(_refreshController.footerStatus, LoadStatus.loading);
    expect(_refreshController.position!.pixels, greaterThanOrEqualTo(0.0));
  });
}
