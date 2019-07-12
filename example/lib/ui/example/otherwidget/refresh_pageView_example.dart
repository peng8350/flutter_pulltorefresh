/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-24 17:14
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/*
  this example will show you how to use PageView as child in SmartRefresher
  notice:You should give PageView BoxConstraints height
 */
class PageViewExample extends StatefulWidget {
  PageViewExample({Key key}) : super(key: key);

  @override
  PageViewExampleState createState() => PageViewExampleState();
}

class PageViewExampleState extends State<PageViewExample>
    with TickerProviderStateMixin {
  RefreshController _refreshController;

  List<Widget> data = [];

//  final PageController _pageController = PageController();

  //test #68
  bool _enablePullUp = true, _enablePullDown = true;

  void _getDatas() {
    data.add(Row(
      children: <Widget>[
        FlatButton(
            onPressed: () {
              _refreshController.requestRefresh();
            },
            child: Text("请求刷新")),
        FlatButton(
            onPressed: () {
              _refreshController.requestLoading();
            },
            child: Text("请求加载数据"))
      ],
    ));
    for (int i = 0; i < 13; i++) {
      data.add(GestureDetector(
        child: Container(
          color: Color.fromARGB(255, 250, 250, 250),
          child: Card(
            margin:
                EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
            child: Center(
              child: Text('Data $i'),
            ),
          ),
        ),
        onTap: () {
          _refreshController.requestRefresh();
        },
      ));
    }
  }

  void enterRefresh() {
    _refreshController.requestLoading();
  }

  @override
  void initState() {
    // TODO: implement initState
    _getDatas();
    _refreshController = RefreshController(initialRefresh: true);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (i, c) {
        double height = c.biggest.height;
        return SmartRefresher(
          enablePullUp: _enablePullDown,
          enablePullDown: _enablePullUp,
          controller: _refreshController,
          header: MaterialClassicHeader(),
          onRefresh: () async {
            print("onRefresh");
            await Future.delayed(const Duration(milliseconds: 4000));
            data.add(Container(
              child: Card(),
              height: 100.0,
            ));
            if (mounted) setState(() {});
            _refreshController.refreshFailed();
          },
          child: Container(
            // notice this ,height is necessary ,else it will throw error
            height: height,
            child: PageView(
              physics: ClampingScrollPhysics(),
              children: <Widget>[
                Text("页面一"),
                Text("页面二"),
                Text("页面三"),
                Text("页面四"),
              ],
            ),
          ),
          onLoading: () {
            print("onload");
            Future.delayed(const Duration(milliseconds: 2000)).then((val) {
              data.add(Card());
              if (mounted) setState(() {});
              _refreshController.loadComplete();
            });
          },
        );
      },
    );
  }
}
