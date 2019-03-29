/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/3/29 下午4:27
 */

import 'package:flutter/material.dart';

class SecondActivity extends StatefulWidget {
  SecondActivity({Key key, this.title}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _SecondActivityState createState() => new _SecondActivityState();
}

class _SecondActivityState extends State<SecondActivity> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
        leading: new GestureDetector(
          child: new Container(
            child: new Row(
              children: <Widget>[
                new Icon(Icons.keyboard_arrow_left),
                new Text("返回")
              ],
            ),
          ),
          onTap:(){
            Navigator.of(context).pop();
          }
        ),
      ),
      body: new Text("测试跳转返回"),
    );
  }
}
