/**
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 17:39
 */

import 'package:flutter/material.dart' hide RefreshIndicator;
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ClassicRefreshIndicator extends RefreshIndicator {
  AnimationController rorateController;

  ClassicRefreshIndicator(
      {@required TickerProvider vsync,
      @required bool up,
      int completeTime: 800,
      double visibleRange: 50.0,
      double triggerDistance: 80.0})
      : assert(vsync != null, up != null),
        super(
            up: up,
            vsync: vsync,
            completeTime: completeTime,
            visibleRange: visibleRange,
            triggerDistance: triggerDistance) {
    rorateController = new AnimationController(
        vsync: vsync,
        upperBound: 0.5,
        duration: const Duration(milliseconds: 100));
  }

  @override
  void onDragMove(ScrollUpdateNotification notification) {
    // TODO: implement onDragMove
    super.onDragMove(notification);
  }

  @override
  set mode(int mode) {
    // TODO: implement mode
    if (this.mode == mode) return;
    super.mode = mode;
    if (this.mode == RefreshStatus.canRefresh) {
      rorateController.animateTo(1.0);
    }
    if (this.mode == RefreshStatus.idle) {
      rorateController.animateTo(0.0);
    }
  }

  @override
  Widget buildContent() {
    // TODO: implement buildContent
    return new Container(
      height: 50.0,
      alignment: Alignment.center,
      child: new Center(
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
                            turns: rorateController,
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
      ),
    );
  }
}

class ClassicLoadIndicator extends LoadIndicator {
  ClassicLoadIndicator({@required bool up, bool autoLoad: true})
      :assert(up!=null), super(up: up, autoLoad: autoLoad);

  @override
  Widget buildContent() {
    // TODO: implement buildContent
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
}
