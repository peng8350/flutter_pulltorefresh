import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/src/smart_refresher.dart';

/**
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-03 00:39
 */

/**
  use it to build some widget
 */
class BuildFactory {
  // if your renderHeader null, it will be replaced by it
  Widget buildDefaultHeader(BuildContext context, RefreshMode mode) {
    return new Container(
      height: 50.0,
      alignment: Alignment.center,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CupertinoActivityIndicator(),
          new Container(
            child: new Text(mode == RefreshMode.canRefresh
                ? 'Refresh when release'
                : mode == RefreshMode.completed
                ? 'Refresh Completed'
                : mode == RefreshMode.refreshing
                ? 'Refreshing....'
                : 'pull down refresh'),
            margin: const EdgeInsets.only(left: 10.0),
          )
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
          new Container(
            margin: new EdgeInsets.only(left: 10.0),
            child: new Text(mode == RefreshMode.startDrag
                ? 'pull up load'
                : mode == RefreshMode.canRefresh
                    ? 'Loadmore when release'
                    : mode == RefreshMode.completed
                        ? 'Load Completed'
                        : 'LoadMore....'),
          )
        ],
      ),
    );
  }

  Widget buildEmptySpace(controller, spacing) => new SizeTransition(
      sizeFactor: controller,
      child: new Container(
        height: spacing,
      ));
}
