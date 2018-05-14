/**
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-03 00:39
 */


import 'package:pull_to_refresh/src/smart_refresher.dart';
import 'package:flutter/material.dart';


/**
    use it to build some widget
 */
class BuildFactory {
  // if your renderHeader null, it will be replaced by it
  Widget buildDefaultHeader(
      BuildContext context, int mode, AnimationController controller) {
    return new Container(
      height: 50.0,
      alignment: Alignment.center,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          mode == RefreshStatus.refreshing
              ? new SizedBox(
                  width: 25.0,
                  height: 25.0,
                  child: const CircularProgressIndicator(strokeWidth: 2.0),
                )
              : mode == RefreshStatus.completed
                  ? const Icon(Icons.done, color: Colors.grey)
                  : mode == RefreshStatus.failed
                      ? const Icon(Icons.clear, color: Colors.grey)
                      : new RotationTransition(
                          turns: controller,
                          child: const Icon(Icons.arrow_downward,
                              color: Colors.grey)),
          new Container(
            child: new Text(
              mode == RefreshStatus.canRefresh
                  ? 'Refresh when release'
                  : mode == RefreshStatus.completed
                      ? 'Refresh Completed'
                      : mode == RefreshStatus.failed
                          ? 'Refresh Failed'
                          : mode == RefreshStatus.refreshing
                              ? 'Refreshing....'
                              : 'pull down refresh',
              style: new TextStyle(color: const Color(0xff555555)),
            ),
            margin: const EdgeInsets.only(left: 10.0),
          )
        ],
      ),
    );
  }

  // if your renderFooter null, it will be replaced by it
  Widget buildDefaultFooter(BuildContext context, int mode) {
    final child = mode == RefreshStatus.refreshing
        ? new SizedBox(
            width: 25.0,
            height: 25.0,
            child: const CircularProgressIndicator(strokeWidth: 2.0),
          )
        : new Text(
            mode == RefreshStatus.idle
                ? 'Load More...'
                : mode == RefreshStatus.noMore
                    ? 'No more data'
                    : 'Network exception!',
            style: new TextStyle(color: const Color(0xff555555)),
          );
    return new Container(
      height: 50.0,
      child: new Center(
        child: child,
      ),
    );
  }

  Widget buildEmptySpace(controller, spacing) {
    return new SizeTransition(
        sizeFactor: controller,
        child: new Container(
          height: spacing,
        ));
  }
}
