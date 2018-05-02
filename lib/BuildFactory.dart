import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pulltorefresh/pulltorefresh.dart';

/**
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-03 00:39
 */


class BuildFactory{

  // if your renderHeader null, it will be replaced by it
  Widget buildDefaultHeader(BuildContext context, RefreshMode mode) {
    return new Container(
      height: 50.0,
      alignment: Alignment.center,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CupertinoActivityIndicator(),
          new Text(mode == RefreshMode.canRefresh
              ? 'Refresh when release'
              : mode == RefreshMode.completed
              ? 'Refresh Completed'
              : mode == RefreshMode.refreshing
              ? 'Refreshing....'
              : 'pull down refresh')
        ],
      ),
    );
  }


  // if your renderFooter null, it will be replaced by it
  Widget buildDefaultFooter(BuildContext context, RefreshMode mode) {
    return new Container(
      height: 50.0,
      alignment: Alignment.center,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CupertinoActivityIndicator(),
          new Text(mode == RefreshMode.startDrag
              ? 'pull up load'
              : mode == RefreshMode.canRefresh
              ? 'Loadmore when release'
              : mode == RefreshMode.completed
              ? 'Load Completed'
              : 'LoadMore....')
        ],
      ),
    );
  }

  Widget buildEmptySpace(controller) {
    return new SizeTransition(
        sizeFactor: controller,
        child: new Container(
          color: Colors.red,
          height: 50.0,
        ));
  }

}