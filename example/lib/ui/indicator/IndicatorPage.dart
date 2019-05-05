/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/5 下午6:07
 */

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'base/IndicatorActivity.dart';

class IndicatorPage extends StatefulWidget {
  IndicatorPage({Key key, this.title}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _IndicatorPageState createState() => new _IndicatorPageState();
}

class _IndicatorPageState extends State<IndicatorPage> {

  List<Widget> items ;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) => items[index],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    items = [

      IndicatorItem(title: "经典指示器(跟随)",onClick: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) =>
            IndicatorActivity(title:"经典指示器(跟随)" ,header: ClassicHeader(refreshStyle: RefreshStyle.Follow),)
        ));
      },imgRes: "images/empty.png"),
      IndicatorItem(title: "经典指示器(不跟随)",onClick: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) =>
            IndicatorActivity(title:"经典指示器(不跟随)" ,header: ClassicHeader(refreshStyle: RefreshStyle.UnFollow),)
        ));
      },imgRes: "images/empty.png"),
      IndicatorItem(title: "QQ头部指示器",onClick: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) =>
            IndicatorActivity(title:"QQ头部指示器" ,header: WaterDropHeader())
        ));
      },imgRes: "images/empty.png")
    ];
    super.didChangeDependencies();
  }
}

class IndicatorItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _IndicatorItemState();
  }

  final Function onClick;

  final String imgRes;

  final String title;

  IndicatorItem({this.title, this.imgRes, this.onClick});
}

class _IndicatorItemState extends State<IndicatorItem> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: widget.onClick,
      child: Card(
        child: Column(
          children: <Widget>[
            Center(
              child: Image.asset(widget.imgRes),
            ),
            Center(
              child: Text(widget.title),
            )
          ],
        ),
      ),
    );
  }
}
