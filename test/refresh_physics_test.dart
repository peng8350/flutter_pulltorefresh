/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime: 2019-07-21 13:20
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'dataSource.dart';
import 'test_indicator.dart';


void main(){



  group("in Android ClampingScrollPhysics", (){
    testWidgets("clamping physics,when user flip gesture up ,it shouldn't move out of viewport area", (tester) async{
      final RefreshController _refreshController = RefreshController();
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(
            platform: TargetPlatform.android
        ),
        home: SmartRefresher(
          header: TestHeader(),
          footer: TestFooter(),
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            itemBuilder: (c, i) =>
                Center(
                  child: Text(data[i]),
                ),
            itemCount: 23,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
      ));

      await tester.fling(find.byType(Viewport), const Offset(0,100), 5200);
      while (tester.binding.transientCallbackCount > 0) {
        print(_refreshController.position.pixels);
        expect(_refreshController.position.pixels, greaterThanOrEqualTo(-150.0));
        await tester.pump(const Duration(milliseconds: 20));
      }

      // from bottom flip up
      _refreshController.position.jumpTo(_refreshController.position.maxScrollExtent);
      await tester.fling(find.byType(Viewport), const Offset(0,1000), 5200);
      while (tester.binding.transientCallbackCount > 0) {
        expect(_refreshController.position.pixels, greaterThanOrEqualTo(-150.0));
        await tester.pump(const Duration(milliseconds: 20));
      }
    });

  });

  group("in IOS BoucingScrollPhysics", (){

  });
}