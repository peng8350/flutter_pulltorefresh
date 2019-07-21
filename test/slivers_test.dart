/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime: 2019-07-21 16:59
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/src/internals/slivers.dart';
import 'dataSource.dart';
import 'test_indicator.dart';



Future<void> buildNotFullList(tester,bool reverse,Axis direction,LoadIndicator footer){
  final RefreshController _refreshController = RefreshController();
    return tester.pumpWidget(MaterialApp(
      home: Container(
        height: 600,
        width: 800,
        child: SmartRefresher(
          header: TestHeader(),
          footer: footer,
          enablePullUp: true,
          enablePullDown: true,
          child: ListView.builder(
            reverse: reverse,
            scrollDirection: direction,
            itemBuilder: (c, i) =>
                Center(
                  child: Text(data[i]),
                ),
            itemCount: 1,
            itemExtent: 100,
          ),
          controller: _refreshController,
        ),
      ),
    ));
}

void main(){
  /// this need to be fixed later
  // #126 may still exist render error with footer not full
  testWidgets("footer rendering in four direction with different styles(unfollow content)", (tester) async{

    final List<CustomFooter> footer_data = [
    CustomFooter(builder: (_,c) => Container(),loadStyle: LoadStyle.ShowAlways,),
      CustomFooter(builder: (_,c) => Container(),loadStyle: LoadStyle.ShowWhenLoading,),
      CustomFooter(builder: (_,c) => Container(),loadStyle: LoadStyle.HideAlways,),
    ];
    for(CustomFooter footer in footer_data){
    // down
    await buildNotFullList(tester,false,Axis.vertical,footer);

    RenderSliverSingleBoxAdapter sliver = tester.renderObject(find.byType(SliverLoading));
    // behind the bottom ,if else ,it is render error
    expect(sliver.child.localToGlobal(Offset(0.0,0.0)),const Offset(0,600));

    // up
    await buildNotFullList(tester,true,Axis.vertical,footer);

    sliver = tester.renderObject(find.byType(SliverLoading));
    /// build failed in this ,may be I do some errors in this direction ,why -48.0?
    expect(sliver.child.localToGlobal(Offset(0.0,0.0)),const Offset(0,-60.0));

    // left
    await buildNotFullList(tester,true,Axis.horizontal,footer);

    sliver = tester.renderObject(find.byType(SliverLoading));
    // behind the bottom ,if else ,it is render error
    expect(sliver.child.localToGlobal(Offset(0.0,0.0)),const Offset(-60.0,0));

    // right
    await buildNotFullList(tester,false,Axis.horizontal,footer);

    sliver = tester.renderObject(find.byType(SliverLoading));
    // behind the bottom ,if else ,it is render error
    expect(sliver.child.localToGlobal(Offset(0.0,0.0)),const Offset(800.0,0));
  }
  });

}