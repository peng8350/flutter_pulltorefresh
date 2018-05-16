/**
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 15:39
 */

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef Widget Builder(int status);

abstract class Wrapper extends StatefulWidget {
  final ValueNotifier<int> modeListener;

  final Widget child;

  final bool up;

  final Function onModeChange;

  bool get isRefreshing => this.mode == RefreshStatus.refreshing;

  bool get isComplete =>
      this.mode == RefreshStatus.completed || this.mode == RefreshStatus.failed;

  int get mode => this.modeListener.value;

  set mode(int mode) => this.modeListener.value = mode;

  Wrapper({Key key, this.modeListener, this.up, this.onModeChange, this.child})
      : super(key: key);

  bool isScrollToOutSide(ScrollNotification notification) {
    if (up) {
      if (notification.metrics.minScrollExtent - notification.metrics.pixels >
          0) {
        return true;
      }
    } else {
      if (notification.metrics.pixels - notification.metrics.maxScrollExtent >
          0) {
        return true;
      }
    }
    return false;
  }
}

abstract class GestureDelegate {
  void onDragStart(ScrollStartNotification notification);

  void onDragMove(ScrollUpdateNotification notification);

  void onDragEnd(ScrollNotification notification);
}

class RefreshWrapper extends Wrapper {
  final int completeTime;

  final double visibleRange;

  final double triggerDistance;

  final Function onOffsetChange;

  RefreshWrapper(
      {this.completeTime: 800,
      this.visibleRange: 50.0,
      ValueNotifier<int> modeLis,
      Widget child,
      this.onOffsetChange,
      bool up: true,
      Key key,
      this.triggerDistance: 80.0})
      : assert(up != null),
        super(up: up, key: key, modeListener: modeLis, child: child);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new RefreshWrapperState();
  }
}

class RefreshWrapperState extends State<RefreshWrapper>
    with TickerProviderStateMixin
    implements GestureDelegate {
  static final double minSpace = 0.00001;

  AnimationController _sizeController;
  /**
      up indicate drag from top (pull down)
   */
  void _dismiss() {
    /**
        why the value is 0.00001?
        If this value is 0, no controls will
        cause Flutter to automatically retrieve widget.
     */
    _sizeController.animateTo(minSpace).then((Null val) {
      widget.mode = RefreshStatus.idle;
    });
  }

  int get mode => widget.modeListener.value;

  @override
  void onDragEnd(ScrollNotification notification) {
    // TODO: implement onDragEnd
    if (!widget.isScrollToOutSide(notification)) {
      return;
    }
    if (widget.isComplete || widget.isRefreshing) return;
    bool reachMax = measure(notification) >= 1.0;
    if (!reachMax) {
      _sizeController.animateTo(0.0);
      return;
    } else {
      widget.mode = RefreshStatus.refreshing;
    }
  }

  @override
  void onDragMove(ScrollUpdateNotification notification) {
    // TODO: implement onDragMove
    if (!widget.isScrollToOutSide(notification)) {
      return;
    }
    if (widget.isComplete || widget.isRefreshing) return;
    double offset = measure(notification);
    if (offset >= 1.0) {
      widget.mode = RefreshStatus.canRefresh;
    } else {
      widget.mode = RefreshStatus.idle;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this._sizeController = new AnimationController(
        vsync: this,
        lowerBound: minSpace,
        duration: const Duration(milliseconds: 300));
    widget.modeListener.addListener(() {
      switch (mode) {
        case RefreshStatus.refreshing:
          if (widget.up) {
//          _scrollController.jumpTo(-visibleRange);
          }
          _sizeController.value = 1.0;
          break;
        case RefreshStatus.completed:
          new Future.delayed(new Duration(milliseconds: widget.completeTime),
              () {
            _dismiss();
          });
          break;
        case RefreshStatus.failed:
          new Future.delayed(new Duration(milliseconds: widget.completeTime),
              () {
            _dismiss();
          }).then((val) {
            widget.mode = RefreshStatus.idle;
          });
          break;
      }
    });
  }

  double measure(ScrollNotification notification) {
    if (widget.up) {
      return (notification.metrics.minScrollExtent -
              notification.metrics.pixels) /
          widget.triggerDistance;
    } else {
      return (notification.metrics.pixels -
              notification.metrics.maxScrollExtent) /
          widget.triggerDistance;
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (widget.up) {
      return new Column(
        children: <Widget>[
          new SizeTransition(
            sizeFactor: _sizeController,
            child: new Container(height: widget.visibleRange),
          ),
          widget.child
        ],
      );
    }
    return new Column(
      children: <Widget>[
        widget.child,
        new SizeTransition(
          sizeFactor: _sizeController,
          child: new Container(height: widget.visibleRange),
        )
      ],
    );
  }

  @override
  void onDragStart(ScrollStartNotification notification) {
    // TODO: implement onDragStart
  }
}

abstract class Indicator extends StatefulWidget {
  final ValueNotifier<double> offsetListener;

  final int mode;

  const Indicator({this.mode, this.offsetListener});
}

////status: failed,nomore,completed,idle,refreshing
class LoadWrapper extends Wrapper {
  final bool autoLoad;

  final bool up;

  LoadWrapper(
      {Key key,
      @required this.up,
      Builder builder,
      this.autoLoad: true,
      ValueNotifier<int> modeLis,
      Widget child})
      : assert(up != null),
        super(key: key, up: up, child: child, modeListener: modeLis);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new LoadWrapperState();
  }
}

class LoadWrapperState extends State<LoadWrapper> implements GestureDelegate {
  @override
  void onDragMove(ScrollUpdateNotification notification) {
    // TODO: implement onDragMove
    if (!widget.isScrollToOutSide(notification)) {
      return;
    }
    if (widget.isRefreshing || widget.isComplete) return;

    if (notification.metrics.outOfRange && widget.autoLoad) {
      widget.mode = RefreshStatus.refreshing;
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return widget.child;
  }

  @override
  void onDragEnd(ScrollNotification notification) {
    // TODO: implement onDragEnd
  }

  @override
  void onDragStart(ScrollStartNotification notification) {
    // TODO: implement onDragStart
  }
}
