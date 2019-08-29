/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-08-29 09:41
 */

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'classic_indicator.dart';
import '../smart_refresher.dart';

class TwoLevelHeader extends StatefulWidget {
  final BoxDecoration decoration;

  final Widget twoLevelWidget;

  final String releaseText,
      idleText,
      refreshingText,
      completeText,
      failedText,
      canTwoLevelText;
  final Widget releaseIcon,
      idleIcon,
      refreshingIcon,
      completeIcon,
      failedIcon,
      canTwoLevelIcon;

  /// icon and text middle margin
  final double spacing;
  final IconPosition iconPos;

  final TextStyle textStyle;

  final double height;
  final Duration completeDuration;

  const TwoLevelHeader({
    Key key,
    this.height: 80.0,
    this.decoration,
    this.completeDuration: const Duration(milliseconds: 600),
    this.textStyle: const TextStyle(color: const Color(0xff555555)),
    this.releaseText: 'Refresh when release',
    this.refreshingText: 'Refreshing...',
    this.canTwoLevelIcon,
    this.canTwoLevelText: 'release to enter secondfloor',
    this.completeText: 'Refresh complete',
    this.failedText: 'Refresh failed',
    this.idleText: 'Pull down to refresh',
    this.iconPos: IconPosition.left,
    this.spacing: 15.0,
    this.refreshingIcon,
    this.failedIcon: const Icon(Icons.error, color: Colors.grey),
    this.completeIcon: const Icon(Icons.done, color: Colors.grey),
    this.idleIcon = const Icon(Icons.arrow_downward, color: Colors.grey),
    this.releaseIcon = const Icon(Icons.refresh, color: Colors.grey),
    this.twoLevelWidget
  });


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TwoLevelHeaderState();
  }
}

class _TwoLevelHeaderState extends State<TwoLevelHeader> {
  @override
  void initState() {
    // TODO: implement initState
    // this will rebuild,because position.viewportDimension return null when first build,I have no idea how to catch Viewport height in first build
//    WidgetsBinding.instance.addPostFrameCallback((_) {
//      setState(() {});
//    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
//    print(Scrollable.of(context).position.viewportDimension);
    return ClassicHeader(
      refreshStyle: RefreshStyle.Follow,
      height: widget.height,
      refreshingIcon: widget.refreshingIcon,
      refreshingText: widget.refreshingText,
      releaseIcon: widget.releaseIcon,
      releaseText: widget.releaseText,
      completeDuration: widget.completeDuration,
      canTwoLevelIcon: widget.canTwoLevelIcon,
      canTwoLevelText: widget.canTwoLevelText,
      failedIcon: widget.failedIcon,
      failedText: widget.failedText,
      idleIcon: widget.idleIcon,
      idleText: widget.idleText,
      completeIcon: widget.completeIcon,
      completeText: widget.completeText,
      spacing: widget.spacing,
      textStyle: widget.textStyle,
      iconPos: widget.iconPos,
      outerBuilder: (child) {
        final RefreshStatus mode =
            SmartRefresher.of(context).controller.headerStatus;
        final bool isTwoLevel = (mode == RefreshStatus.twoLevelClosing ||
            mode == RefreshStatus.twoLeveling ||
            mode == RefreshStatus.twoLevelOpening);
        return Container(
          decoration: !isTwoLevel
              ? (widget.decoration ?? BoxDecoration(color: Colors.redAccent))
              : null,
          height: Scrollable.of(context).position.viewportDimension,
          alignment: isTwoLevel ? null : Alignment.bottomCenter,
          child: isTwoLevel
              ? widget.twoLevelWidget
              : Padding(
                  child: child,
                  padding: EdgeInsets.only(bottom: 15),
                ),
        );
      },
    );
  }
}
