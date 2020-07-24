/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-24 17:13
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/*
   when listView have no data,sometime we should return a view that indicate empty state
   there are two ways to do ,see follow
 */
class RefreshWithEmptyView extends StatefulWidget {
  RefreshWithEmptyView();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RefreshWithEmptyViewState();
  }
}

class _RefreshWithEmptyViewState extends State<RefreshWithEmptyView> {
  List<String> data = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Widget buildEmpty() {
    // there are two ways
    // this way is more converient,but it doesn't reference ListView some attribute
    // If you don't need some attribute like physics,cacheExtent,just default
    // you can return emptyWidget directly,else return ListView
    // from 1.5.2,you needn't  compute the height by LayoutBuilder,If your boxConstaints is double.infite,
    // SmartRefresher can convert the height to the viewport mainExtent
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          "images/empty1.png",
          fit: BoxFit.cover,
        ),
        Text("没数据,请下拉刷新")
      ],
    );
    /* second way
    return ListView(
      children: [
        Image.asset(
          "images/empty.png",
          fit: BoxFit.cover,
        )
      ],
      physics: BouncingScrollPhysics(),
      cacheExtent: 100.0,
    );

     */
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: data.length != 0,
      enablePullDown: true,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 2000));
        if (mounted)
          setState(() {
            data.add("new");
          });
        _refreshController.refreshCompleted();
      },
      child: data.length == 0
          ? buildEmpty()
          : ListView.builder(
              itemBuilder: (c, i) => Text(data[i]),
              itemCount: data.length,
              itemExtent: 100.0,
            ),
    );
  }
}
