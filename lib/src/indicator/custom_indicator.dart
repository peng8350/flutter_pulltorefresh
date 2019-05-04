/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/4 下午9:49
 */

import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;

import '../internals/indicator_wrap.dart';
import '../smart_refresher.dart';
import '../internals/default_constants.dart';

class CustomHeader extends RefreshIndicator {
  final double height;

  final double triggerDistance;

  final RefreshStyle refreshStyle;

  final HeaderBuilder builder;

  CustomHeader({
    Key key,
    @required this.builder,
    this.height: default_height,
    this.refreshStyle: RefreshStyle.Follow,
    this.triggerDistance: default_refresh_triggerDistance,
  }) : super(
            key: key,
            triggerDistance: triggerDistance,
            refreshStyle: refreshStyle,
            height: height);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CustomHeaderState();
  }
}

class _CustomHeaderState extends RefreshIndicatorState<CustomHeader> {
  @override
  Widget buildContent(BuildContext context, RefreshStatus mode) {
    // TODO: implement buildContent
    return widget.builder(context, mode);
  }
}

class CustomFooter extends LoadIndicator {
  final double triggerDistance;

  final bool autoLoad;

  final FooterBuilder builder;

  CustomFooter({
    Key key,
    @required this.builder,
    this.autoLoad: true,
    this.triggerDistance: default_load_triggerDistance,
  }) : super(key: key, autoLoad: autoLoad, triggerDistance: triggerDistance);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CustomFooterState();
  }
}

class _CustomFooterState extends LoadIndicatorState<CustomFooter> {
  @override
  Widget buildContent(BuildContext context, LoadStatus mode) {
    // TODO: implement buildContent
    return widget.builder(context, mode);
  }
}
