/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/7 下午12:07
 */
import 'package:flutter/material.dart';
import 'DataSmall.dart';
import 'Nested.dart';
import 'Appbar_header.dart';
import 'InnerWrapList.dart';

class SamplePage extends StatefulWidget {

  final TabController tabController;

  SamplePage({this.tabController});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SamplePage();
  }
}

class _SamplePage extends State<SamplePage>
   {

  List<Widget> views;

  @override
  void initState() {
    // TODO: implement initState
    views = [DataSmall(),Nested(),AppBarHeader(),InnerList()];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TabBarView(children: views,controller: widget.tabController,);
  }
}
