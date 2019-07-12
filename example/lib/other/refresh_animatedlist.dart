/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-15 17:50
 */

import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshAnimatedList extends AnimatedList {
  /// Creates a scrolling container that animates items when they are inserted or removed.
  RefreshAnimatedList({
    Key key,
    @required Function itemBuilder,
    int initialItemCount = 0,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    @required this.refreshController,
    this.header,
    this.footer,
    this.enablePullDown: true,
    this.enablePullUp: false,
    this.onRefresh,
    this.onLoading,
    this.onOffsetChange,
    ScrollController scrollController,
    bool primary,
    ScrollPhysics physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry padding,
  })  : assert(itemBuilder != null),
        assert(initialItemCount != null && initialItemCount >= 0),
        super(
            key: key,
            initialItemCount: initialItemCount,
            reverse: reverse,
            itemBuilder: itemBuilder,
            shrinkWrap: shrinkWrap,
            padding: padding,
            physics: physics,
            controller: scrollController,
            scrollDirection: scrollDirection);

  final RefreshIndicator header;

  final LoadIndicator footer;

  final bool enablePullUp;

  final bool enablePullDown;

  final Function onRefresh, onLoading;

  final OnOffsetChange onOffsetChange;

  final RefreshController refreshController;

  @override
  AnimatedListState createState() {
    // TODO: implement createState
    return _RefreshAnimatedListState();
  }
}

class _RefreshAnimatedListState extends AnimatedListState {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final RefreshAnimatedList widget1 = widget as RefreshAnimatedList;
    return SmartRefresher(
      controller: widget1.refreshController,
      enablePullDown: widget1.enablePullDown,
      enablePullUp: widget1.enablePullUp,
      child: super.build(context),
      footer: widget1.footer,
      header: widget1.header,
      onOffsetChange: widget1.onOffsetChange,
      onLoading: widget1.onLoading,
      onRefresh: widget1.onRefresh,
    );
  }
}
