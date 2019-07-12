/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 15:39
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;
import '../smart_refresher.dart';
import 'slivers.dart';

const int default_completeDuration = 500;

const RefreshStyle default_refreshStyle = RefreshStyle.Follow;

abstract class RefreshIndicator extends StatefulWidget {
  final RefreshStyle refreshStyle;

  final double height;

  final bool reverse;

  final Duration completeDuration;

  const RefreshIndicator(
      {Key key,
      this.reverse: false,
      this.height: 60.0,
      this.completeDuration:
          const Duration(milliseconds: default_completeDuration),
      this.refreshStyle: default_refreshStyle})
      : super(key: key);
}

abstract class LoadIndicator extends StatefulWidget {
  final LoadStyle loadStyle;
  final double height;
  final VoidCallback onClick;

  const LoadIndicator(
      {Key key,
      this.onClick,
      this.loadStyle: LoadStyle.ShowAlways,
      this.height: 60.0})
      : super(key: key);
}

abstract class RefreshIndicatorState<T extends RefreshIndicator>
    extends State<T>
    with IndicatorStateMixin<T, RefreshStatus>, RefreshProcessor {
  bool _inVisual() {
    return _position.extentBefore - widget.height <= 0.0;
  }

  double _calculateScrollOffset() {
    return (floating
            ? (mode == RefreshStatus.twoLeveling ||
                    mode == RefreshStatus.twoLevelOpening ||
                    mode == RefreshStatus.twoLevelClosing
                ? _position.viewportDimension
                : widget.height)
            : 0.0) -
        _position?.pixels;
  }

  @override
  void _handleOffsetChange() {
    // TODO: implement _handleOffsetChange
    super._handleOffsetChange();
    final double overscrollPast = _calculateScrollOffset();
    onOffsetChange(overscrollPast);
  }

  // handle the  state change between canRefresh and idle canRefresh  before refreshing
  void _dispatchModeByOffset(double offset) {
    if (mode == RefreshStatus.twoLeveling) {
      if (_position.pixels > configuration.closeTwoLevelDistance &&
          activity is BallisticScrollActivity) {
        refresher.controller.twoLevelComplete();
        return;
      }
    }
    if (RefreshStatus.twoLevelOpening == mode ||
        mode == RefreshStatus.twoLevelClosing) {
      return;
    }
    if (floating) return;
    // no matter what activity is done, when offset ==0.0 and !floating,it should be set to idle for setting ifCanDrag
    if (offset == 0.0) {
      mode = RefreshStatus.idle;
    }

    // If FrontStyle overScroll,it shouldn't disable gesture in scrollable
    if (_position.extentBefore == 0.0 &&
        widget.refreshStyle == RefreshStyle.Front) {
      _position.context.setIgnorePointer(false);
    }
    // Sometimes different devices return velocity differently, so it's impossible to judge from velocity whether the user
    // has invoked animateTo (0.0) or the user is dragging the view.Sometimes animateTo (0.0) does not return velocity = 0.0
    // velocity < 0.0 may be spring up,>0.0 spring down
    if ((configuration.enableBallisticRefresh && activity.velocity < 0.0) ||
        activity is DragScrollActivity ||
        activity is DrivenScrollActivity) {
      if (refresher.enableTwoLevel &&
          offset >= configuration.twiceTriggerDistance) {
        mode = RefreshStatus.canTwoLevel;
      } else if (offset >= configuration.headerTriggerDistance) {
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
      // refreshing
      floating = true;
      update();
      readyToRefresh().then((_) {
        if (!mounted) return;
        mode = RefreshStatus.refreshing;
      });
    } else if (mode == RefreshStatus.canTwoLevel) {
      // enter twoLevel
      floating = true;
      update();
      if (!mounted) return;

      mode = RefreshStatus.twoLevelOpening;
    }
  }

  void _handleModeChange() {
    if (!mounted) {
      return;
    }
    update();
    if (mode == RefreshStatus.idle || mode == RefreshStatus.canRefresh) {
      floating = false;
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
            _position.jumpTo(0.0);
          }
          mode = RefreshStatus.idle;
        } else {
          if (!_inVisual()) {
            mode = RefreshStatus.idle;
          } else {
            activity.delegate.goBallistic(0.0);
          }
        }
      });
    } else if (mode == RefreshStatus.refreshing) {
      if (refresher.onRefresh != null) refresher.onRefresh();
    } else if (mode == RefreshStatus.twoLevelOpening) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        activity.resetActivity();
        _position
            .animateTo(0.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.linear)
            .whenComplete(() {
          mode = RefreshStatus.twoLeveling;
        });
        if (refresher.onTwoLevel != null) refresher.onTwoLevel();
      });
    } else if (mode == RefreshStatus.twoLevelClosing) {
      floating = false;
      update();
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
        refreshIndicatorLayoutExtent: mode == RefreshStatus.twoLeveling ||
                mode == RefreshStatus.twoLevelOpening ||
                mode == RefreshStatus.twoLevelClosing
            ? _position.viewportDimension - 0.01
            : widget.height,
        refreshStyle: widget.refreshStyle);
  }
}

abstract class LoadIndicatorState<T extends LoadIndicator> extends State<T>
    with IndicatorStateMixin<T, LoadStatus>, LoadingProcessor {
  // use to update between one page and above one page
  bool _isHide = false;
  bool _enableLoading = false;

  double _calculateScrollOffset() {
    final double overScrollPastEnd =
        math.max(_position.pixels - _position.maxScrollExtent, 0.0);
    return overScrollPastEnd;
  }

  bool _checkIfCanLoading() {
    return _position.maxScrollExtent - _position.pixels <=
            configuration.footerTriggerDistance &&
        configuration.autoLoad &&
        _enableLoading &&
        activity is! DragScrollActivity &&
        _position.extentBefore > 0.0 &&
        ((configuration.enableLoadingWhenFailed && mode == LoadStatus.failed) ||
            mode == LoadStatus.idle);
  }

  void _handleModeChange() {
    if (!mounted || _isHide) {
      return;
    }
    update();
    if (mode == LoadStatus.loading) {
      if (refresher.onLoading != null) {
        refresher.onLoading();
      }
      if (widget.loadStyle == LoadStyle.ShowWhenLoading) {
        floating = true;
      }
    } else {
      if (activity is! DragScrollActivity) _enableLoading = false;
      if (widget.loadStyle == LoadStyle.ShowWhenLoading) {
        floating = false;
      }
    }
    onModeChange(mode);
  }

  void _dispatchModeByOffset(double offset) {
    if (!mounted || _isHide) {
      return;
    }
    // avoid trigger more time when user dragging in the same direction
    if (_checkIfCanLoading()) {
      mode = LoadStatus.loading;
    }
  }

  void _handleOffsetChange() {
    if (_isHide) {
      return;
    }
    super._handleOffsetChange();
    final double overscrollPast = _calculateScrollOffset();
    onOffsetChange(overscrollPast);
  }

  void _listenScrollEnd() {
    if (!_position.isScrollingNotifier.value) {
      // when user release gesture from screen
      if (!_isHide && _checkIfCanLoading()) {
        if (activity is IdleScrollActivity) {
          mode = LoadStatus.loading;
        }
      }
    } else {
      if (activity is DragScrollActivity || activity is DrivenScrollActivity) {
        _enableLoading = true;
      }
    }
  }

  void _onPositionUpdated(ScrollPosition newPosition) {
    _position?.isScrollingNotifier?.removeListener(_listenScrollEnd);
    newPosition?.isScrollingNotifier?.addListener(_listenScrollEnd);
    super._onPositionUpdated(newPosition);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    floating = widget.loadStyle == LoadStyle.ShowAlways;
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    // TODO: implement didUpdateWidget
    floating = widget.loadStyle == LoadStyle.ShowAlways;
    super.didUpdateWidget(oldWidget);
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
        shouldFollowContent: configuration.shouldFooterFollowWhenNotFull != null
            ? configuration.shouldFooterFollowWhenNotFull(mode)
            : false,
        layoutExtent: floating ? widget.height : 0.0,
        mode: mode,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints cons) {
            _isHide = cons.biggest.height == 0.0;
            return GestureDetector(
              onTap: () {
                if ((mode == LoadStatus.idle && !configuration.autoLoad) ||
                    (!configuration.enableLoadingWhenFailed &&
                        _mode.value == LoadStatus.failed)) {
                  mode = LoadStatus.loading;
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

  bool _floating = false;

  set floating(floating) => _floating = floating;

  get floating => _floating;

  set mode(mode) => _mode?.value = mode;

  get mode => _mode?.value;

  ValueNotifier<V> _mode;

  ScrollActivity get activity => _position.activity;

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
    if (refresher.onOffsetChange != null) {
      refresher.onOffsetChange(V == RefreshStatus, overscrollPast);
    }
    _dispatchModeByOffset(overscrollPast);
  }

  void disposeListener() {
    _mode?.removeListener(_handleModeChange);
    _position?.removeListener(_handleOffsetChange);
    _position = null;
    _mode = null;
  }

  void _updateListener() {
    configuration = RefreshConfiguration.of(context);
    refresher = SmartRefresher.of(context);
    ValueNotifier<V> newMode = V == RefreshStatus
        ? refresher.controller.headerMode
        : refresher.controller.footerMode;
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
  void initState() {
    // TODO: implement initState
    if (V == RefreshStatus) {
      SmartRefresher.of(context)?.controller?.headerMode?.value =
          RefreshStatus.idle;
    }
    super.initState();
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

  void _onPositionUpdated(ScrollPosition newPosition) {
    refresher.controller.onPositionUpdated(newPosition);
  }

  void _handleModeChange();

  double _calculateScrollOffset();

  void _dispatchModeByOffset(double offset);

  Widget buildContent(BuildContext context, V mode);
}

abstract class RefreshProcessor {
  void onOffsetChange(double offset) {}

  void onModeChange(RefreshStatus mode) {}

  Future readyToRefresh() {
    return Future.value();
  }

  Future endRefresh() {
    return Future.value();
  }

  void resetValue() {}
}

abstract class LoadingProcessor {
  void onOffsetChange(double offset) {}

  void onModeChange(LoadStatus mode) {}
}
