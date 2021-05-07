/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime: 2019-07-20 21:03
 */

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'dataSource.dart';
import 'test_indicator.dart';

Widget buildRefresher(RefreshController controller, {int count: 20}) {
  return RefreshConfiguration(
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: 375.0,
        height: 690.0,
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enableTwoLevel: true,
          enablePullUp: true,
          child: ListView.builder(
            itemBuilder: (c, i) => Text(data[i]),
            itemCount: count,
            itemExtent: 100,
          ),
          controller: controller,
        ),
      ),
    ),
    maxOverScrollExtent: 180,
  );
}

// consider two situation, the one is Viewport full,second is Viewport not full
void testRequestFun(bool full) {
  testWidgets("requestRefresh(init),requestLoading function,requestTwoLevel",
      (tester) async {
    final RefreshController _refreshController =
        RefreshController(initialRefresh: true);

    await tester
        .pumpWidget(buildRefresher(_refreshController, count: full ? 20 : 1));
    //init Refresh
    await tester.pumpAndSettle();
    expect(_refreshController.headerStatus, RefreshStatus.refreshing);
    _refreshController.refreshCompleted();
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(_refreshController.headerStatus, RefreshStatus.idle);

    _refreshController.position!.jumpTo(200.0);
    _refreshController.requestRefresh(
        duration: Duration(milliseconds: 500), curve: Curves.linear);
    await tester.pumpAndSettle();
    _refreshController.refreshCompleted();
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(_refreshController.headerStatus, RefreshStatus.idle);

    _refreshController.requestLoading();
    await tester.pumpAndSettle();
    expect(_refreshController.footerStatus, LoadStatus.loading);
    _refreshController.loadComplete();
    await tester.pump(Duration(milliseconds: 200));
    await tester.pumpAndSettle(Duration(milliseconds: 2000));
    _refreshController.position!.jumpTo(0);
    _refreshController.requestTwoLevel();
    await tester.pumpAndSettle(Duration(milliseconds: 200));
    expect(_refreshController.headerStatus, RefreshStatus.twoLeveling);
    _refreshController.twoLevelComplete();
    await tester.pumpAndSettle();
    expect(_refreshController.headerStatus, RefreshStatus.idle);
  });

  testWidgets("requestRefresh needCallBack test", (tester) async {
    final RefreshController _refreshController =
        RefreshController(initialRefresh: false);
    int timerr = 0;
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: 375.0,
        height: 690.0,
        child: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: () {
            timerr++;
          },
          onLoading: () {
            timerr++;
          },
          child: ListView.builder(
            itemBuilder: (c, i) => Text(data[i]),
            itemCount: 20,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
      ),
    ));
    _refreshController.requestRefresh(needCallback: false);
    await tester.pumpAndSettle();
    expect(timerr, 0);

    _refreshController.requestLoading(needCallback: false);
    await tester.pumpAndSettle();
    expect(timerr, 0);
  });
}

void main() {
  test("check RefreshController inital param ", () async {
    final RefreshController _refreshController = RefreshController(
        initialRefreshStatus: RefreshStatus.idle,
        initialLoadStatus: LoadStatus.noMore);

    expect(_refreshController.headerMode!.value, RefreshStatus.idle);

    expect(_refreshController.footerMode!.value, LoadStatus.noMore);
  });

  testWidgets(
      "resetNoMoreData only can reset when footer mode is Nomore,if state is loading,may disable change state",
      (tester) async {
    final RefreshController _refreshController = RefreshController(
        initialLoadStatus: LoadStatus.loading,
        initialRefreshStatus: RefreshStatus.refreshing);
    _refreshController.refreshCompleted(resetFooterState: true);
    expect(_refreshController.footerMode!.value, LoadStatus.loading);

    _refreshController.headerMode!.value = RefreshStatus.refreshing;
    _refreshController.footerMode!.value = LoadStatus.noMore;
    _refreshController.refreshCompleted(resetFooterState: true);
    expect(_refreshController.footerMode!.value, LoadStatus.idle);

    _refreshController.headerMode!.value = RefreshStatus.refreshing;
    _refreshController.footerMode!.value = LoadStatus.noMore;
    _refreshController.resetNoData();
    expect(_refreshController.footerMode!.value, LoadStatus.idle);
  });

  testRequestFun(true);

  testRequestFun(false);
}
