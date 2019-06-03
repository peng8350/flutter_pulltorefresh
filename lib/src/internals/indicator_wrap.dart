/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 15:39
 */

import 'package:flutter/widgets.dart';
import 'default_constants.dart';
import 'dart:math' as math;
import '../smart_refresher.dart';
import 'slivers.dart';

typedef OnRefresh = Future<bool> Function();
typedef OnLoading = Future<bool> Function();

abstract class Indicator extends StatefulWidget {
  final double triggerDistance;

  const Indicator({Key key, this.triggerDistance}) : super(key: key);
}

/*
 header generate template
    const xxxx({
    Key key,
    double offset:0.0,
    RefreshStyle refreshStyle: default_refreshStyle,
    double height: default_height,
    double triggerDistance: default_refresh_triggerDistance,
    Duration completeDuration:const Duration(milliseconds: 600),
    bool skipCanRefresh:false,
    }) : super(
    key: key,
    offset:offset
    refreshStyle: refreshStyle,
    completeDuration:completeDuration,
    height: height,
    skipCanRefresh:skipCanRefresh,
    triggerDistance: triggerDistance);

*/

abstract class RefreshIndicator extends Indicator {
  final RefreshStyle refreshStyle;

  final bool skipCanRefresh;

  final double height;

  final double offset;

  final OnRefresh onRefresh;

  final bool reverse;

  final Duration completeDuration;

  const RefreshIndicator(
      {this.height: default_height,
      Key key,
      this.offset: 0.0,
      this.skipCanRefresh: false,
      this.completeDuration: const Duration(milliseconds: 600),
      this.onRefresh,
      this.reverse: false,
      double triggerDistance: default_refresh_triggerDistance,
      this.refreshStyle: RefreshStyle.Follow})
      : super(key: key, triggerDistance: triggerDistance);
}

/*
 footer generate template
 const xxxx({
    Key key,
    bool autoLoad: true,
    bool hideWhenNotFull: true,
    Function onClick,
    double triggerDistance: default_load_triggerDistance,
  }) : super(
            key: key,
            autoLoad: autoLoad,
            hideWhenNotFull: hideWhenNotFull,
            triggerDistance: triggerDistance,
            onClick: onClick)

*/

abstract class LoadIndicator extends Indicator {
  final bool autoLoad;

  final Function onClick;

  final bool hideWhenNotFull;

  final OnLoading onLoading;

  const LoadIndicator(
      {Key key,
      double triggerDistance: 15.0,
      this.onLoading,
      this.autoLoad: true,
      this.hideWhenNotFull: true,
      this.onClick})
      : super(key: key, triggerDistance: triggerDistance);
}

abstract class RefreshIndicatorState<T extends RefreshIndicator>
    extends State<T> with IndicatorProcessor {
  bool floating = false;

  void _handleOffsetChange() {
    if (!mounted) {
      return;
    }
    final overscrollPast = calculateScrollOffset();
    if (overscrollPast < 0.0) {
      return;
    }
    if (refresher?.onOffsetChange != null) {
      refresher.onOffsetChange(true, overscrollPast);
    }
    handleDragMove(overscrollPast);

    onOffsetChange(overscrollPast);
  }

  bool inVisual() {
    if (widget.refreshStyle == RefreshStyle.Front) {
      return _position.extentBefore < widget.height;
    } else {
      return _position.extentBefore - widget.height <= 0.0;
    }
  }

  double calculateScrollOffset() {
    if (widget.refreshStyle == RefreshStyle.Front) {
      return widget.height - _position.extentBefore;
    }
    return (floating ? widget.height : 0.0) - _position?.pixels;
  }

  void update() {
    if (mounted) setState(() {});
  }

  // handle the  state change between canRefresh and idle canRefresh  before refreshing
  void handleDragMove(double offset) {
    if (floating) return;
    // Sometimes different devices return velocity differently, so it's impossible to judge from velocity whether the user
    // has invoked animateTo (0.0) or the user is dragging the view.Sometimes animateTo (0.0) does not return velocity = 0.0
    if (_position.activity.velocity == 0.0 ||
        _position.activity is DragScrollActivity ||
        _position.activity is DrivenScrollActivity) {
      if (offset >= widget.triggerDistance) {
        if (!widget.skipCanRefresh) {
          mode = RefreshStatus.canRefresh;
        } else {
          floating = true;
          update();
          readyToRefresh().then((_) {
            if (!mounted) return;
            mode = RefreshStatus.refreshing;
          });
        }
      } else {
        mode = RefreshStatus.idle;
      }
    } else if (RefreshStatus.canRefresh == mode) {
      floating = true;
      update();
      readyToRefresh().then((_) {
        if (!mounted) return;
        mode = RefreshStatus.refreshing;
      });
    }
  }

  void handleModeChange() {
    if (!mounted) {
      return;
    }
    update();
    if (mode == RefreshStatus.completed || mode == RefreshStatus.failed) {
      endRefresh().then((_) {
        if (!mounted) return;
        floating = false;
        update();

        /*
          handle two Situation:
          1.when user dragging to refreshing, then user scroll down not to see the indicator,then it will not spring back,
          the _onOffsetChange didn't callback,it will keep failed or success state.
          2. As FrontStyle,when user dragging in 0~100 in refreshing state,it should be reset after the state change
          */
        if (widget.refreshStyle == RefreshStyle.Front) {
          if (inVisual()) {
            _position.jumpTo(widget.height);
          }
          mode = RefreshStatus.idle;
          _position.activity.delegate.goBallistic(0.0);
        } else {
          if (!inVisual()) {
            mode = RefreshStatus.idle;
          }
          _position.activity.delegate.goBallistic(0.0);
        }
      });
    } else if (mode == RefreshStatus.refreshing) {
      if (refresher == null) {
        widget.onRefresh().then((bool result) {
          if (result) {
            mode = RefreshStatus.completed;
          } else {
            mode = RefreshStatus.failed;
          }
        });
      } else {
        if (refresher.onRefresh != null) refresher.onRefresh();
      }
    }
  }

  // the method can provide a callback to implements some animation
  Future<void> readyToRefresh() {
    return Future.value();
  }

  // it mean the state will enter success or fail
  Future<void> endRefresh() {
    return Future.delayed(widget.completeDuration);
  }

  bool needReverseAll(){
    return true;
  }

  void onOffsetChange(double offset) {
    update();
  }

  // indicator render layout
  Widget buildContent(BuildContext context, RefreshStatus mode);

  @override
  Widget build(BuildContext context) {
    return SliverRefresh(
        paintOffsetY: widget.offset,
        child: RotatedBox(
          child: buildContent(context, mode),
          quarterTurns: needReverseAll()&&widget.reverse ? 10 : 0,
        ),
        floating: floating,
        reverse: widget.reverse,
        refreshIndicatorLayoutExtent: widget.height,
        refreshStyle: widget.refreshStyle);
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    // careful this code ,I am not sure if it is right to do so
    // for fix the offset after the header remove from slivers
    if (widget.refreshStyle == RefreshStyle.Front &&
        (context as Element).dirty) {
      if (_position.pixels < widget.height) {
        _position.correctPixels(0.0);
      } else {
        _position.correctBy(-widget.height);
      }
    }
    super.deactivate();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    //1.3.7: here need to careful after add asSliver builder
//    _removeListener(_handleOffsetChange);
    disposeListener();
    super.dispose();
  }

  void _update() {
    refresher = SmartRefresher.of(context);
    final ScrollPosition newPosition = Scrollable.of(context).position;
    if (refresher == null) {
      _updateListener(_mode ?? ValueNotifier<RefreshStatus>(RefreshStatus.idle),
          newPosition);
    } else {
      _updateListener(refresher.controller.headerMode, newPosition);
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    _update();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    // TODO: implement didUpdateWidget
    // needn't to update _headerMode,because it's state will never change
    // 1.3.7: here need to careful after add asSliver builder
    _update();
    super.didUpdateWidget(oldWidget);
  }
}

abstract class LoadIndicatorState<T extends LoadIndicator> extends State<T>
    with IndicatorProcessor {
  // use to update between one page and above one page
  bool _isHide = false;

  bool _enablbeLoadingAgain = true;

  double calculateScrollOffset() {
    final double overscrollPastEnd =
        math.max(_position.pixels - _position.maxScrollExtent, 0.0);
    return overscrollPastEnd;
  }

  void update() {
    if (mounted) {
      setState(() {});
    }
  }

  void handleModeChange() {
    if (!mounted || _isHide) {
      return;
    }
    update();
    if (mode == LoadStatus.loading) {
      if (refresher?.onLoading != null) {
        refresher.onLoading();
      } else if (widget.onLoading != null) {
        widget.onLoading().then((result) {
          if (result) {
            mode = LoadStatus.idle;
          } else {
            mode = LoadStatus.noMore;
          }
        });
      }
    }
  }

  void handleDragMove() {
    // avoid trigger more time when user dragging in the same direction
    if (_position.userScrollDirection.index == 1 &&
        _position.activity is DragScrollActivity) {
      _enablbeLoadingAgain = true;
    }
    if (_position.userScrollDirection.index == 2 &&
        _position.extentAfter <= widget.triggerDistance &&
        widget.autoLoad &&
        _enablbeLoadingAgain &&
        mode == LoadStatus.idle) {
      mode = LoadStatus.loading;
      _enablbeLoadingAgain = false;
    }
  }

  void _handleOffsetChange() {
    if (!mounted || _isHide) {
      return;
    }
    final double overscrollPast = calculateScrollOffset();

    if (refresher?.onOffsetChange != null && _position.extentAfter == 0.0) {
      refresher?.onOffsetChange(false, overscrollPast);
    }
    handleDragMove();
    onOffsetChange(overscrollPast);
  }

  // updateListener
  void _update() {
    refresher = SmartRefresher.of(context);
    final ScrollPosition newPosition = Scrollable.of(context).position;
    if (refresher == null) {
      _updateListener(
          _mode ?? ValueNotifier<LoadStatus>(LoadStatus.idle), newPosition,
          onPositionChange: () {
        newPosition.isScrollingNotifier.removeListener(_listenScrollEnd);
        _position.isScrollingNotifier.addListener(_listenScrollEnd);
      });
    } else {
      _updateListener(refresher.controller.footerMode, newPosition,
          onPositionChange: () {
        newPosition.isScrollingNotifier.removeListener(_listenScrollEnd);
        _position.isScrollingNotifier.addListener(_listenScrollEnd);
      });
    }
  }

  //ScrollEnd E
  void _listenScrollEnd() {
    if (!_position.isScrollingNotifier.value) {
      _enablbeLoadingAgain = true;
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    _update();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    // TODO: implement didUpdateWidget
    _update();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _position.isScrollingNotifier.removeListener(_listenScrollEnd);
    disposeListener();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SliverLoading(
        hideWhenNotFull: widget.hideWhenNotFull,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints cons) {
            _isHide = cons.biggest.height == 0.0;
            return GestureDetector(
              onTap: () {
                if (widget.onClick != null) {
                  widget.onClick();
                }
              },
              child: buildContent(context, mode),
            );
          },
        ));
  }

  Widget buildContent(BuildContext context, LoadStatus mode);
}

abstract class IndicatorProcessor {
  SmartRefresher refresher;

  set mode(mode) => _mode?.value = mode;

  get mode => _mode?.value;

  ValueNotifier<dynamic> _mode;

  /*
    it doesn't support get the ScrollController as the listener, because it will cause "multiple scrollview use one ScollController"
    error,only replace the ScrollPosition to listen the offset
   */
  ScrollPosition _position;

  void onOffsetChange(double offset) {}

  void _handleOffsetChange();

  void disposeListener() {
    _mode?.removeListener(handleModeChange);
    _position?.removeListener(_handleOffsetChange);
    _position = null;
    _mode = null;
  }

  void handleModeChange();

  void _updateListener(ValueNotifier<dynamic> mode, ScrollPosition position,
      {Function onModeChange, Function onPositionChange}) {
    final ValueNotifier<dynamic> newMode = mode;
    final ScrollPosition newPostion = position;
    if (newMode != _mode) {
      _mode?.removeListener(handleModeChange);
      _mode = newMode;
      _mode?.addListener(handleModeChange);
      if (onModeChange != null) onModeChange();
    }
    if (newPostion != _position) {
      _position?.removeListener(_handleOffsetChange);
      _position = newPostion;
      _position?.addListener(_handleOffsetChange);
      if (onPositionChange != null) onPositionChange();
    }
  }
}
