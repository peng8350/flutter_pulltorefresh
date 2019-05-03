/**
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 17:39
 */

import 'package:flutter/material.dart' hide RefreshIndicator;
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum IconPosition { left, right, top, bottom }

class ClassicIndicator extends Indicator {
  final String releaseText,
      idleText,
      refreshingText,
      completeText,
      failedText,
      noDataText;

  final Widget releaseIcon,
      idleIcon,
      refreshingIcon,
      completeIcon,
      failedIcon,
      noMoreIcon;

  final double height;

  final double spacing;

  final IconPosition iconPos;

  final TextStyle textStyle;

  const ClassicIndicator({
    @required RefreshStatus mode,
    Key key,
    this.textStyle: const TextStyle(color: const Color(0xff555555)),
    this.releaseText: 'Refresh when release',
    this.refreshingText: 'Refreshing...',
    this.completeText: 'Refresh complete',
    this.noDataText: 'No more data',
    this.height: 60.0,
    this.noMoreIcon: const Icon(Icons.clear, color: Colors.grey),
    this.failedText: 'Refresh failed',
    this.idleText: 'Pull down to refresh',
    this.iconPos: IconPosition.left,
    this.spacing: 15.0,
    this.refreshingIcon: const CircularProgressIndicator(strokeWidth: 2.0),
    this.failedIcon: const Icon(Icons.clear, color: Colors.grey),
    this.completeIcon: const Icon(Icons.done, color: Colors.grey),
    this.idleIcon = const Icon(Icons.arrow_downward, color: Colors.grey),
    this.releaseIcon = const Icon(Icons.arrow_upward, color: Colors.grey),
  }) : super(key: key, mode: mode);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ClassicIndicatorState();
  }
}

class _ClassicIndicatorState extends State<ClassicIndicator> {
  Widget _buildText() {
    return Text(
        widget.mode == RefreshStatus.canRefresh
            ? widget.releaseText
            : widget.mode == RefreshStatus.completed
                ? widget.completeText
                : widget.mode == RefreshStatus.failed
                    ? widget.failedText
                    : widget.mode == RefreshStatus.refreshing
                        ? widget.refreshingText
                        : widget.mode == RefreshStatus.noMore
                            ? widget.noDataText
                            : widget.idleText,
        style: widget.textStyle);
  }

  Widget _buildIcon() {
    Widget icon = widget.mode == RefreshStatus.canRefresh
        ? widget.releaseIcon
        : widget.mode == RefreshStatus.noMore
            ? widget.noMoreIcon
            : widget.mode == RefreshStatus.idle
                ? widget.idleIcon
                : widget.mode == RefreshStatus.completed
                    ? widget.completeIcon
                    : widget.mode == RefreshStatus.failed
                        ? widget.failedIcon
                        : SizedBox(
                            width: 25.0,
                            height: 25.0,
                            child: widget.refreshingIcon,
                          );
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement buildContent
    Widget textWidget = _buildText();
    Widget iconWidget = _buildIcon();
    List<Widget> children = <Widget>[iconWidget, Container(), textWidget];
    Widget container = (widget.iconPos == IconPosition.top ||
            widget.iconPos == IconPosition.bottom)
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            verticalDirection: widget.iconPos == IconPosition.top
                ? VerticalDirection.down
                : VerticalDirection.up,
            children: children,
          )
        : Row(
            textDirection: widget.iconPos == IconPosition.right
                ? TextDirection.rtl
                : TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          );
    return Container(
      height: widget.height,
      child: Center(
        child: container,
      ),
    );
  }
}
