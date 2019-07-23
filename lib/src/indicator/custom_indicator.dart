/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/4 下午9:49
 */

import 'package:flutter/widgets.dart';
import '../internals/indicator_wrap.dart';
import '../smart_refresher.dart';

/// custom header builder,you can use second paramter to know what header state is
typedef Widget HeaderBuilder(BuildContext context, RefreshStatus mode);
/// custom footer builder,you can use second paramter to know what footerr state is
typedef Widget FooterBuilder(BuildContext context, LoadStatus mode);

class CustomHeader extends RefreshIndicator {
  final HeaderBuilder builder;

  const CustomHeader({
    Key key,
    @required this.builder,
    double height: 60.0,
    Duration completeDuration: const Duration(milliseconds: 600),
    RefreshStyle refreshStyle: RefreshStyle.Follow,
  }) : super(
            key: key,
            completeDuration: completeDuration,
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
  final FooterBuilder builder;

  const CustomFooter({
    Key key,
    double height: 60.0,
    LoadStyle loadStyle: LoadStyle.ShowAlways,
    @required this.builder,
    Function onClick,
  }) : super(key: key, onClick: onClick, loadStyle: loadStyle, height: height);

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
