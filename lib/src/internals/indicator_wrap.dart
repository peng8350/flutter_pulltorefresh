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

abstract class RefreshIndicator extends Indicator {
  final RefreshStyle refreshStyle;

  final double height;

  final double offset;

  final OnRefresh onRefresh;

  const RefreshIndicator(
      {this.height: default_height,
      Key key,
      this.offset: 0.0,
      this.onRefresh,
      double triggerDistance: default_refresh_triggerDistance,
      this.refreshStyle: RefreshStyle.Follow})
      : super(key: key, triggerDistance: triggerDistance);
}

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
    final overscrollPast = calculateScrollOffset(_scrollController);
    if (overscrollPast < 0.0) {
      return;
    }
    if (refresher?.widget?.onOffsetChange != null) {
      refresher.widget.onOffsetChange(true, overscrollPast);
    }
    handleDragMove(overscrollPast);

    onOffsetChange(overscrollPast);
  }

  bool inVisual() {
    if (widget.refreshStyle == RefreshStyle.Front) {
      return _scrollController.position.extentBefore < widget.height;
    } else {
      return _scrollController.position.extentBefore - widget.height <= 0.0;
    }
  }

  double calculateScrollOffset(ScrollController controller) {
    if (widget.refreshStyle == RefreshStyle.Front) {
      return widget.height - controller.position.extentBefore;
    }
    return (floating ? widget.height : 0.0) - _scrollController?.offset;
  }

  void update() {
    if (mounted) setState(() {});
  }

  // handle the  state change between canRefresh and idle canRefresh  before refreshing
  void handleDragMove(double offset) {
    if (floating) return;
    // Sometimes different devices return velocity differently, so it's impossible to judge from velocity whether the user
    // has invoked animateTo (0.0) or the user is dragging the view.Sometimes animateTo (0.0) does not return velocity = 0.0
    if (_scrollController.position.activity.velocity == 0.0 ||
        _scrollController.position.activity is DragScrollActivity ||
        _scrollController.position.activity is DrivenScrollActivity) {
      if (offset >= widget.triggerDistance) {
        mode = RefreshStatus.canRefresh;
      } else {
        mode = RefreshStatus.idle;
      }
    } else if (RefreshStatus.canRefresh == mode) {
      floating = true;
      update();
      readyToRefresh().then((_) {
        if(!mounted)return;
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
        if(!mounted)return;
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
            _scrollController.jumpTo(widget.height);
          }
          mode = RefreshStatus.idle;
          _scrollController.position.activity.delegate.goBallistic(0.0);
        } else {
          if (!inVisual()) {
            mode = RefreshStatus.idle;
          }
          _scrollController.position.activity.delegate.goBallistic(0.0);
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
        if (refresher.widget.onRefresh != null) refresher.widget.onRefresh();
      }
    }
  }

  // the method can provide a callback to implements some animation
  Future<void> readyToRefresh() {
    return Future.value();
  }

  // it mean the state will enter success or fail
  Future<void> endRefresh() {
    return Future.delayed(Duration(milliseconds: 800));
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
        child: LayoutBuilder(
          builder: (BuildContext c, BoxConstraints box) {
            return Container(
              child: buildContent(context, mode),
            );
          },
        ),
        floating: floating,
        refreshIndicatorLayoutExtent: widget.height,
        refreshStyle: widget.refreshStyle);
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    // careful this code ,I am not sure if it is right to do so
    // for fix the offset after the header remove from slivers
    if(widget.refreshStyle==RefreshStyle.Front) {
      if(_scrollController.position.pixels<widget.height){
        _scrollController.position.correctPixels(0.0);
      }
      else{
        _scrollController.position.correctBy(-widget.height);
      }

    }
    super.deactivate();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    //1.3.7: here need to careful after add asSliver builder
//    _scrollController.removeListener(_handleOffsetChange);
    disposeListener();
    super.dispose();
  }

  void _update() {
    refresher = SmartRefresher.of(context);
    if (refresher == null) {
      _updateListener(
          _mode ?? ValueNotifier<RefreshStatus>(RefreshStatus.idle),
          Scrollable.of(context).widget.controller);
    } else {
      _updateListener(refresher.widget.controller.headerMode,
          refresher.widget.controller.scrollController);
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

  double calculateScrollOffset(ScrollController controller) {
    final double overscrollPastEnd = math.max(
        controller.position.pixels - controller.position.maxScrollExtent, 0.0);
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
      if (refresher?.widget?.onLoading != null) {
        refresher.widget.onLoading();
      }
      else if(widget.onLoading!=null){
        widget.onLoading().then((result){
          if(result){
            mode = LoadStatus.idle;
          }
          else{
            mode = LoadStatus.noMore;
          }
        });
      }
    }
  }

  void handleDragMove() {

    if (_scrollController.position.userScrollDirection.index == 2 &&
        _scrollController.position.extentAfter <= widget.triggerDistance &&
        widget.autoLoad &&
        mode == LoadStatus.idle) {
      mode = LoadStatus.loading;
    }
  }


  void _handleOffsetChange() {
    if (!mounted || _isHide) {
      return;
    }
    final double overscrollPast = calculateScrollOffset(_scrollController);

    if (refresher?.widget?.onOffsetChange != null &&
        _scrollController.position.extentAfter == 0.0) {
      refresher?.widget?.onOffsetChange(false, overscrollPast);
    }
    handleDragMove();
    onOffsetChange(overscrollPast);
  }

  // updateListener
  void _update() {
    refresher = SmartRefresher.of(context);
    if (refresher == null) {
      _updateListener(_mode ?? ValueNotifier<LoadStatus>(LoadStatus.idle),
          Scrollable.of(context).widget.controller);
    } else {
      _updateListener(refresher.widget.controller.footerMode,
          refresher.widget.controller.scrollController);
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
  SmartRefresherState  refresher;

  set mode(mode) => _mode?.value = mode;

  get mode => _mode?.value;

  ValueNotifier<dynamic> _mode;

  ScrollController _scrollController;

  void onOffsetChange(double offset) {}

  void _handleOffsetChange();

  void disposeListener() {
    _mode?.removeListener(handleModeChange);
    _scrollController?.removeListener(_handleOffsetChange);
    _scrollController = null;
    _mode = null;
  }

  void handleModeChange();

  void _updateListener(
      ValueNotifier<dynamic> mode, ScrollController controller) {
    final ValueNotifier<dynamic> newMode = mode;
    final ScrollController newController = controller;
    if (newMode != null && newMode != _mode) {
      _mode?.removeListener(handleModeChange);
      _mode = newMode;
      _mode?.addListener(handleModeChange);
    }
    if (newController != _scrollController) {
      _scrollController?.removeListener(_handleOffsetChange);
      _scrollController = newController;
      _scrollController?.addListener(_handleOffsetChange);
    }
  }
}
