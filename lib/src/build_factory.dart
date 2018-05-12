import 'package:pull_to_refresh/src/smart_refresher.dart';
import 'package:flutter/material.dart';

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
  Widget buildDefaultHeader(
      BuildContext context, RefreshMode mode, AnimationController controller) {
    return new Container(
      height: 50.0,
      alignment: Alignment.center,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          mode == RefreshMode.refreshing
              ? new SizedBox(
                  width: 25.0,
                  height: 25.0,
                  child: const CircularProgressIndicator(strokeWidth: 2.0),
                )
              : mode == RefreshMode.completed
                  ? const Icon(Icons.done, color: Colors.grey)
                  : mode == RefreshMode.failed
                      ? const Icon(Icons.clear, color: Colors.grey)
                      : new RotationTransition(
                          turns: controller,
                          child: const Icon(Icons.arrow_downward,
                              color: Colors.grey)),
          new Container(
            child: new Text(
              mode == RefreshMode.canRefresh
                  ? 'Refresh when release'
                  : mode == RefreshMode.completed
                      ? 'Refresh Completed'
                      : mode == RefreshMode.failed
                          ? 'Refresh Failed'
                          : mode == RefreshMode.refreshing
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
  Widget buildDefaultFooter(BuildContext context, LoadMode mode) {
    if (mode == LoadMode.loading) {
      return new Container(
        height: 50.0,
        child: new Center(
          child: new SizedBox(
            width: 25.0,
            height: 25.0,
            child: const CircularProgressIndicator(strokeWidth: 2.0),
          ),
        ),
      );
    } else {
      return new Container(
        height: 50.0,
        child: new Center(
          child: new Text(
            mode == LoadMode.idle
                ? 'Load More...'
                : mode == LoadMode.emptyData
                    ? 'No more data'
                    : 'Network exception!',
            style: new TextStyle(color: const Color(0xff555555)),
          ),
        ),
      );
    }
  }

  Widget buildEmptySpace(controller, spacing) {
    return new SizeTransition(
        sizeFactor: controller,
        child: new Container(
          height: spacing,
        ));
  }
}
