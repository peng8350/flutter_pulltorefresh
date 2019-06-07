/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 15:39
 */

import 'package:flutter/widgets.dart';
import 'dart:math' as math;
import '../smart_refresher.dart';
import 'slivers.dart';

typedef OnRefresh = Future<bool> Function();
typedef OnLoading = Future<bool> Function();

const int default_completeDuration = 500;

const double default_height = 60.0;

const RefreshStyle default_refreshStyle = RefreshStyle.Follow;

/*
 header generate template
    const xxxx({
    Key key,
    RefreshStyle refreshStyle: default_refreshStyle,
    double height: default_height,
    Duration completeDuration:const Duration(milliseconds: 600),
    }) : super(
    key: key,
    refreshStyle: refreshStyle,
    completeDuration:completeDuration,
    height: height,
   );
*/

abstract class RefreshIndicator extends StatefulWidget {
  final RefreshStyle refreshStyle;

  final double height;

  final OnRefresh onRefresh;

  final bool reverse;

  final Duration completeDuration;

  const RefreshIndicator(
      {Key key,
      this.onRefresh,
      this.reverse: false,
      this.height: default_height,
      this.completeDuration:
          const Duration(milliseconds: default_completeDuration),
      this.refreshStyle: default_refreshStyle})
      : super(key: key);
}

/*
 footer generate template
 const xxxx({
    Key key,
    Function onClick,
  }) : super(
            key: key,
            onClick: onClick)

*/

abstract class LoadIndicator extends StatefulWidget {
  final Function onClick;

  final OnLoading onLoading;

  const LoadIndicator({Key key, this.onLoading, this.onClick})
      : super(key: key);
}

abstract class RefreshIndicatorState<T extends RefreshIndicator>
    extends State<T> with IndicatorStateMixin<T, RefreshStatus> {
  bool floating = false;

  bool _inVisual() {
    if (widget.refreshStyle == RefreshStyle.Front) {
      return _position.extentBefore < widget.height;
    } else {
      return _position.extentBefore - widget.height <= 0.0;
    }
  }

  double _calculateScrollOffset() {
    if (widget.refreshStyle == RefreshStyle.Front) {
      return widget.height - _position.extentBefore;
    }
    return (floating ? widget.height : 0.0) - _position?.pixels;
  }

  // handle the  state change between canRefresh and idle canRefresh  before refreshing
  void _dispatchModeByOffset(double offset) {
    if (floating) return;
    // Sometimes different devices return velocity differently, so it's impossible to judge from velocity whether the user
    // has invoked animateTo (0.0) or the user is dragging the view.Sometimes animateTo (0.0) does not return velocity = 0.0
    if (_position.activity.velocity == 0.0 ||
        _position.activity is DragScrollActivity ||
        _position.activity is DrivenScrollActivity) {
      if (offset >= configuration.headerTriggerDistance) {
        if (!configuration.skipCanRefresh) {
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

  void _handleModeChange() {
    if (!mounted) {
      return;
    }
    update();
    if (mode == RefreshStatus.idle || mode == RefreshStatus.canRefresh) {
      resetValue();
    }
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
          if (_inVisual()) {
            _position.jumpTo(widget.height);
          }
          mode = RefreshStatus.idle;
          _position.activity.delegate.goBallistic(0.0);
        } else {
          if (!_inVisual()) {
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
    onModeChange(mode);
  }

  // the method can provide a callback to implements some animation
  Future<void> readyToRefresh() {
    return Future.value();
  }

  // it mean the state will enter success or fail
  Future<void> endRefresh() {
    return Future.delayed(widget.completeDuration);
  }

  bool needReverseAll() {
    return true;
  }

  void resetValue() {}

  @override
  Widget build(BuildContext context) {
    return SliverRefresh(
        paintOffsetY: configuration.headerOffset,
        child: RotatedBox(
          child: buildContent(context, mode),
          quarterTurns: needReverseAll() && widget.reverse ? 10 : 0,
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
}

abstract class LoadIndicatorState<T extends LoadIndicator> extends State<T>
    with IndicatorStateMixin<T, LoadStatus> {
  // use to update between one page and above one page
  bool _isHide = false;

  bool _enableLoadingAgain = true;

  double _calculateScrollOffset() {
    final double overscrollPastEnd =
        math.max(_position.pixels - _position.maxScrollExtent, 0.0);
    return overscrollPastEnd;
  }

  void _handleModeChange() {
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
    onModeChange(mode);
  }

  void _dispatchModeByOffset(double offset) {
    // avoid trigger more time when user dragging in the same direction
    if (_position.userScrollDirection.index == 1 &&
        _position.activity is DragScrollActivity) {
      _enableLoadingAgain = true;
    }

    if (_position.userScrollDirection.index == 2 &&
        _position.extentAfter <= configuration.footerTriggerDistance &&
        configuration.autoLoad &&
        _enableLoadingAgain &&
        mode == LoadStatus.idle) {
      mode = LoadStatus.loading;
      _enableLoadingAgain = false;
    }
  }

  void _handleOffsetChange() {
    if (_isHide) {
      return;
    }
    super._handleOffsetChange();
  }

  //ScrollEnd E
  void _listenScrollEnd() {
    if (!_position.isScrollingNotifier.value) {
      _enableLoadingAgain = true;
    }
  }

  void _onPositionUpdated(ScrollPosition newPosition) {
    newPosition?.isScrollingNotifier?.removeListener(_listenScrollEnd);
    _position?.isScrollingNotifier?.addListener(_listenScrollEnd);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _position?.isScrollingNotifier?.removeListener(_listenScrollEnd);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SliverLoading(
        hideWhenNotFull: configuration.hideFooterWhenNotFull,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints cons) {
            _isHide = cons.biggest.height == 0.0;
            return GestureDetector(
              onTap: () {
                if (configuration.clickLoadingWhenIdle) {
                  _mode.value = LoadStatus.loading;
                }
                if (widget.onClick != null) {
                  widget.onClick();
                }
              },
              child: buildContent(context, mode),
            );
          },
        ));
  }
}

mixin IndicatorStateMixin<T extends StatefulWidget, V> on State<T> {
  SmartRefresher refresher;

  RefreshConfiguration configuration;

  set mode(mode) => _mode?.value = mode;

  get mode => _mode?.value;

  ValueNotifier<V> _mode;

  /*
    it doesn't support get the ScrollController as the listener, because it will cause "multiple scrollview use one ScollController"
    error,only replace the ScrollPosition to listen the offset
   */
  ScrollPosition _position;

  // update ui
  void update() {
    if (mounted) setState(() {});
  }

  void _handleOffsetChange() {
    if (!mounted) {
      return;
    }
    final double overscrollPast = _calculateScrollOffset();
    if (overscrollPast < 0.0) {
      return;
    }
    if (refresher?.onOffsetChange != null) {
      refresher?.onOffsetChange(V == RefreshStatus, overscrollPast);
    }
    _dispatchModeByOffset(overscrollPast);
    onOffsetChange(overscrollPast);
  }

  void disposeListener() {
    _mode?.removeListener(_handleModeChange);
    _position?.removeListener(_handleOffsetChange);
    _position = null;
    _mode = null;
  }

  void _updateListener() {
    configuration = RefreshConfiguration.of(context);
    assert(configuration != null,
        "when use asSliver ,please wrap scrollView in RefreshConfiguration!");
    refresher = SmartRefresher.of(context);
    ValueNotifier<V> newMode;
    if (refresher == null) {
      newMode = _mode ??
          (V == RefreshStatus
              ? ValueNotifier<RefreshStatus>(RefreshStatus.idle)
              : ValueNotifier<LoadStatus>(LoadStatus.idle));
    } else {
      newMode = V == RefreshStatus
          ? refresher.controller.headerMode
          : refresher.controller.footerMode;
    }
    final ScrollPosition newPosition = Scrollable.of(context).position;
    if (newMode != _mode) {
      _mode?.removeListener(_handleModeChange);
      _mode = newMode;
      _mode?.addListener(_handleModeChange);
    }
    if (newPosition != _position) {
      _position?.removeListener(_handleOffsetChange);
      _onPositionUpdated(newPosition);
      _position = newPosition;
      _position?.addListener(_handleOffsetChange);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    //1.3.7: here need to careful after add asSliver builder
    disposeListener();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    _updateListener();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    // TODO: implement didUpdateWidget
    // needn't to update _headerMode,because it's state will never change
    // 1.3.7: here need to careful after add asSliver builder
    _updateListener();
    super.didUpdateWidget(oldWidget);
  }

  void _onPositionUpdated(ScrollPosition newPosition) {}

  void _handleModeChange();

  double _calculateScrollOffset();

  void _dispatchModeByOffset(double offset);

  void onOffsetChange(double offset) {
    update();
  }

  void onModeChange(V mode) {}

  Widget buildContent(BuildContext context, V mode);
}
