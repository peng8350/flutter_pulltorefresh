
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/**
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 17:39
 */

class ClassicIndicator extends RefreshWrapper {

  AnimationController rorateController;

  ClassicIndicator(
      {@required TickerProvider vsync,
        int completeTime: 800,
        double visibleRange:50.0,
        double triggerDistance: 80.0})
      : super(
      vsync: vsync,
      completeTime: completeTime,
      visibleRange: visibleRange,
      triggerDistance: triggerDistance) {
    rorateController = new AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 100));
  }

  @override
  void onDragMove(ScrollUpdateNotification notification) {
    // TODO: implement onDragMove
    double offset = measure(notification);
    rorateController.value = offset;
    super.onDragMove(notification);
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
                turns: rorateController,
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
      ),
    );
  }
}
