/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/21 下午12:43
 */

import 'package:example/ui/screen/cupertinoScreen.dart';
import 'package:example/ui/screen/qqzone.dart';
import 'package:flutter/material.dart';
import 'bilibili.dart';

class ScreenPage extends StatelessWidget {
  List<Widget> items = [
    _Item(
      title: "哔哩哔哩首页",
      onClick: (BuildContext context) {
        Navigator.of(context).push( MaterialPageRoute(builder: (BuildContext context) => BiliBiliScreen()));
      },
    ),
    _Item(
      title: "QQ空间",
      onClick: (BuildContext context) {
        Navigator.of(context).push( MaterialPageRoute(builder: (BuildContext context) => qqZone()));
      },
    ),
    _Item(
      title: "iOS界面(主要测试SafeArea)",
      onClick: (BuildContext context) {
        Navigator.of(context).push( MaterialPageRoute(builder: (BuildContext context) => CupertinoScreen()));
      },
    )
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView(
      children: items,
      itemExtent: 100.0,
    );
  }
}

class _Item extends StatelessWidget {
  final Function onClick;
  final String title;

  _Item({this.title, this.onClick});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      child: Card(
        child: Center(child: Text(title)),
      ),
      onTap: (){
        onClick(context);
      },
    );
  }
}
