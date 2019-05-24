/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-05-24 12:53
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CupertinoScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    List<Widget> widgets = [];
    for (int i = 0; i < 24; i++) {
      widgets.add(Container(
        height: 100.0,
        child: Card(),
      ));
    }
    return CupertinoApp(
        home: CupertinoPageScaffold(
      child: SafeArea(
        child: CustomScrollView(
          physics: RefreshClampPhysics(springBackDistance: 100.0),
          slivers: <Widget>[
            MaterialClassicHeader.asSliver(
              onRefresh: () async {
                await Future.delayed(Duration(milliseconds: 400));
                return true;
              },
            ),
            CupertinoSliverNavigationBar(
              largeTitle: Text("iOS"),
            ),

            SliverList(
              delegate: SliverChildListDelegate(widgets),
            ),
            ClassicFooter()
          ],
        ),
      ),
    ));
  }
}
