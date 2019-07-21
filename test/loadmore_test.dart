/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime: 2019-07-21 12:29
 */


import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'dataSource.dart';
import 'test_indicator.dart';



void main(){

  testWidgets("from bottom pull up release gesture to load more", (tester) async{
    final RefreshController _refreshController = RefreshController(
        initialRefresh: true);
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
    _refreshController.position.jumpTo(_refreshController.position.maxScrollExtent-30);
    await tester.drag(find.byType(Scrollable), const Offset(0,-100.0));
    await tester.pump();
    expect(_refreshController.footerStatus, LoadStatus.idle);
    await tester.pump(Duration(milliseconds: 100));
    expect(_refreshController.footerStatus, LoadStatus.loading);
  });

  testWidgets("strick to check tigger judge", (tester) async{
    final RefreshController _refreshController = RefreshController(
        initialRefresh: true);
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
    _refreshController.position.jumpTo(_refreshController.position.maxScrollExtent-216);
    await tester.drag(find.byType(Scrollable), const Offset(0,-200.0));
    await tester.pump();
    expect(_refreshController.footerStatus, LoadStatus.idle);
    await tester.pump(Duration(milliseconds: 100));
    expect(_refreshController.footerStatus, LoadStatus.idle);
  });

  testWidgets("far from bottom,flip to bottom by ballstic also can trigger loading", (tester) async{
    final RefreshController _refreshController = RefreshController(
        initialRefresh: true);
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
    _refreshController.position.jumpTo(_refreshController.position.maxScrollExtent-500);
    await tester.fling(find.byType(Scrollable), const Offset(0,-300.0),2200);
    await tester.pump();
    expect(_refreshController.footerStatus, LoadStatus.idle);
    while (tester.binding.transientCallbackCount > 0) {
      //15.0 is default
      if(_refreshController.position.extentAfter<15){
        expect(_refreshController.footerStatus, LoadStatus.loading);
      }
      else{
        expect(_refreshController.footerStatus, LoadStatus.idle);
      }
      await tester.pump(const Duration(milliseconds: 20));
    }

  });

  testWidgets("if the status is noMore,it shouldn't enable footer to loading", (tester) async{
    final RefreshController _refreshController = RefreshController(
        initialLoadStatus: LoadStatus.noMore);
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
    _refreshController.position.jumpTo(_refreshController.position.maxScrollExtent-216);
    await tester.drag(find.byType(Scrollable), const Offset(0,-400.0));
    await tester.pump();
    expect(_refreshController.footerStatus, LoadStatus.noMore);
    await tester.pump(Duration(milliseconds: 100));
    expect(_refreshController.footerStatus, LoadStatus.noMore);

    _refreshController.position.jumpTo(_refreshController.position.maxScrollExtent-500);
    await tester.fling(find.byType(Scrollable), const Offset(0,-300.0),2200);
    await tester.pump();
    expect(_refreshController.footerStatus, LoadStatus.noMore);
    while (tester.binding.transientCallbackCount > 0) {
        expect(_refreshController.footerStatus, LoadStatus.noMore);
      await tester.pump(const Duration(milliseconds: 20));
    }
  });

  group("when footer in Viewport is not full with one page", (){
    testWidgets("pull down shouldn't trigger load more", (tester) async{
      final RefreshController _refreshController = RefreshController(
          initialRefresh: true);
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
            itemCount: 3,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
      ));

      await tester.drag(find.byType(Scrollable), const Offset(0,10.0));
      await tester.pump();
      await tester.pump(Duration(milliseconds: 20));
      expect(_refreshController.footerStatus, LoadStatus.idle);
      await tester.pumpAndSettle();
      // quickly fling with ballstic
      expect(_refreshController.position.pixels, 0.0);
      await tester.fling(find.byType(Scrollable), const Offset(0,100.0),1000);
      await tester.pump(Duration(milliseconds: 400));
      expect(_refreshController.footerStatus, LoadStatus.idle);
      await tester.pumpAndSettle();
      expect(_refreshController.position.pixels, 0.0);
      expect(_refreshController.footerStatus, LoadStatus.idle);


    });

    testWidgets("pull up can trigger load more", (tester) async{
      final RefreshController _refreshController = RefreshController(
          initialRefresh: true);
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
            itemCount: 3,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
      ));

      await tester.drag(find.byType(Scrollable), const Offset(0,-10.0));
      expect(_refreshController.footerStatus, LoadStatus.idle);
      await tester.pump();
      await tester.pump(Duration(milliseconds: 20));
      expect(_refreshController.footerStatus, LoadStatus.loading);
      await tester.pumpAndSettle();
      // quickly fling with ballstic
      expect(_refreshController.position.pixels, 0.0);
      await tester.fling(find.byType(Scrollable), const Offset(0,-100.0),1000);
      await tester.pump(Duration(milliseconds: 400));
      expect(_refreshController.footerStatus, LoadStatus.loading);
      await tester.pumpAndSettle();
      expect(_refreshController.position.pixels, 0.0);
      expect(_refreshController.footerStatus, LoadStatus.loading);

    });

  });

  // may be happen #91
  group("check if the loading more times stiuation exists", (){

    testWidgets("loading->idle", (tester) async{
      final RefreshController _refreshController = RefreshController(
          initialRefresh: true);
      int time = 0;
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          onLoading: () {
            _refreshController.loadComplete();
            time++;
          },
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

      _refreshController.position.jumpTo(_refreshController.position.maxScrollExtent-100);
      await tester.drag(find.byType(Scrollable), const Offset(0,-150.0));
      expect(_refreshController.footerStatus,LoadStatus.idle);
      while (tester.binding.transientCallbackCount > 0) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(time, 1);

      _refreshController.position.jumpTo(_refreshController.position.maxScrollExtent-100);
      // quickly fling with ballstic,now test failed,may be this exist twice loading,return 2
      await tester.fling(find.byType(Scrollable), const Offset(0,-80.0),1000);
      await tester.pump();
      expect(_refreshController.footerStatus,LoadStatus.idle);
      while (tester.binding.transientCallbackCount > 0) {
        await tester.pump(const Duration(milliseconds: 1));
      }
      expect(time, 1);

    });


    testWidgets("loading->failed", (tester) async{
      final RefreshController _refreshController = RefreshController(
          initialRefresh: true);
      int time = 0;
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          onLoading: () {
            _refreshController.loadFailed();
            time++;
          },
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

      _refreshController.position.jumpTo(_refreshController.position.maxScrollExtent-100);
      await tester.drag(find.byType(Scrollable), const Offset(0,-150.0));
      expect(_refreshController.footerStatus,LoadStatus.idle);
      while (tester.binding.transientCallbackCount > 0) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(time, 1);

      _refreshController.position.jumpTo(_refreshController.position.maxScrollExtent-100);
      await tester.fling(find.byType(Scrollable), const Offset(0,-80.0),1000);
      while (tester.binding.transientCallbackCount > 0) {
        await tester.pump(const Duration(milliseconds: 1));
      }
      expect(time, 1);

    });

    testWidgets("loading->noData", (tester) async{
      final RefreshController _refreshController = RefreshController(
          initialRefresh: true);
      int time = 0;
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          onLoading: () {
            _refreshController.loadNoData();
            time++;
          },
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

      _refreshController.position.jumpTo(_refreshController.position.maxScrollExtent-100);
      await tester.drag(find.byType(Scrollable), const Offset(0,-150.0));
      expect(_refreshController.footerStatus,LoadStatus.idle);
      while (tester.binding.transientCallbackCount > 0) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(time, 1);

      _refreshController.position.jumpTo(_refreshController.position.maxScrollExtent-100);
      await tester.fling(find.byType(Scrollable), const Offset(0,-80.0),1000);
      while (tester.binding.transientCallbackCount > 0) {
        await tester.pump(const Duration(milliseconds: 1));
      }
      expect(time, 1);

    });

  });
}