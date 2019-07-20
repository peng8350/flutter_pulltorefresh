/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime: 2019-07-20 21:03
 */

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'dataSource.dart';

Widget buildRefresher(RefreshController controller){
  return Directionality(
    textDirection: TextDirection.ltr,
    child: SmartRefresher(
      enablePullUp: true,
      child: ListView.builder(
        itemBuilder: (c,i) => Text(data[i]),
        itemCount: 20,
        itemExtent: 100,
      ),
      controller: controller,
    ),

  );
}

void main(){
  
  
  test("check RefreshController inital param ", () async{

    final RefreshController _refreshController = RefreshController(initialRefreshStatus: RefreshStatus.idle,initialLoadStatus: LoadStatus.noMore);

    expect(_refreshController.headerMode.value, RefreshStatus.idle);

    expect(_refreshController.footerMode.value,LoadStatus.noMore);
  });

  testWidgets("check RefreshController function if valid", (tester) async{

    final RefreshController _refreshController = RefreshController();

    await tester.pumpWidget(buildRefresher(_refreshController));

    _refreshController.headerMode.value = RefreshStatus.refreshing;
    _refreshController.refreshCompleted();
    expect(_refreshController.headerMode.value, RefreshStatus.completed);

    _refreshController.headerMode.value = RefreshStatus.refreshing;
    _refreshController.refreshFailed();
    expect(_refreshController.headerMode.value, RefreshStatus.failed);

    _refreshController.headerMode.value = RefreshStatus.refreshing;
    _refreshController.refreshToIdle();
    expect(_refreshController.headerMode.value, RefreshStatus.idle);

    _refreshController.headerMode.value = RefreshStatus.refreshing;
    _refreshController.refreshToIdle();
    expect(_refreshController.headerMode.value, RefreshStatus.idle);


    _refreshController.footerMode.value = LoadStatus.loading;
    _refreshController.loadComplete();
    await tester.pump();
    expect(_refreshController.footerMode.value, LoadStatus.idle);


    _refreshController.footerMode.value = LoadStatus.loading;
    _refreshController.loadFailed();
    await tester.pump();
    expect(_refreshController.footerMode.value, LoadStatus.failed);



    await tester.pump();
    _refreshController.footerMode.value = LoadStatus.loading;
    _refreshController.loadNoData();
    await tester.pump();
    await tester.pump(Duration(milliseconds: 200));
    expect(_refreshController.footerMode.value, LoadStatus.noMore);
  });
}