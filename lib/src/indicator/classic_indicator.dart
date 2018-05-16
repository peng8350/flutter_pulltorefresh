/**
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 17:39
 */

import 'package:flutter/material.dart' hide RefreshIndicator;
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum IconPosition { left, right, top, bottom }

class ClassicRefresher extends Indicator {
  final String releaseText, idleText, refreshingText, completeText, failedText;

  final Widget releaseIcon, idleIcon, refreshingIcon, completeIcon, failedIcon;

  final double height;

  final double spacing;

  final IconPosition iconPos;

  final TextStyle textStyle;

  final bool openRotate;

  ClassicRefresher(
      {int mode,
      ValueNotifier<double> offset,
      this.textStyle: const TextStyle(color: const Color(0xff555555)),
      this.releaseText: 'Refresh when release',
      this.refreshingText: 'Refreshing...',
      this.completeText: 'Refresh complete!',
      this.height: 60.0,
      this.failedText: 'Refresh failed',
      this.idleText: 'Pull down refesh',
      this.openRotate: true,
      this.iconPos: IconPosition.left,
      this.spacing: 15.0,
      this.refreshingIcon: const CircularProgressIndicator(strokeWidth: 2.0),
      this.failedIcon: const Icon(Icons.clear, color: Colors.grey),
      this.completeIcon: const Icon(Icons.done, color: Colors.grey),
      this.idleIcon = const Icon(Icons.arrow_downward, color: Colors.grey),
      this.releaseIcon = const Icon(Icons.arrow_downward, color: Colors.grey),
      int completeTime: 800,
      double visibleRange: 60.0,
      double triggerDistance: 80.0})
      : super(mode: mode);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _ClassicRefresherState();
  }
}

class _ClassicRefresherState extends State<ClassicRefresher>
    with TickerProviderStateMixin {
  AnimationController rorateController;

  Widget _buildText() {
    return new Text(
        widget.mode == RefreshStatus.canRefresh
            ? widget.releaseText
            : widget.mode == RefreshStatus.completed
                ? widget.completeText
                : widget.mode == RefreshStatus.failed
                    ? widget.failedText
                    : widget.mode == RefreshStatus.refreshing
                        ? widget.refreshingText
                        : widget.idleText,
        style: widget.textStyle);
  }

  Widget _buildIcon() {
    return widget.mode == RefreshStatus.canRefresh
        ? widget.releaseIcon
        : widget.mode == RefreshStatus.idle
            ? widget.idleIcon
            : widget.mode == RefreshStatus.completed
                ? widget.completeIcon
                : widget.mode == RefreshStatus.failed
                    ? widget.failedIcon
                    : new SizedBox(
                        width: 25.0,
                        height: 25.0,
                        child:
                            const CircularProgressIndicator(strokeWidth: 2.0),
                      );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement buildContent
    Widget textWidget = _buildText();
    Widget iconWidget = _buildIcon();
    List<Widget> childrens = <Widget>[
      iconWidget,
      new Container(
        width: widget.spacing,
        height: widget.spacing,
      ),
      textWidget
    ];
    Widget container = (widget.iconPos == IconPosition.top ||
            widget.iconPos == IconPosition.bottom)
        ? new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            verticalDirection: widget.iconPos == IconPosition.top
                ? VerticalDirection.down
                : VerticalDirection.up,
            children: childrens,
          )
        : new Row(
            textDirection: widget.iconPos == IconPosition.right
                ? TextDirection.rtl
                : TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.center,
            children: childrens,
          );
    return container;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rorateController = new AnimationController(
        vsync: this,
        upperBound: 0.5,
        duration: const Duration(milliseconds: 100));
  }
}

class ClassicLoadIndicator extends Indicator {


  ClassicLoadIndicator({int mode}):super(mode:mode);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _ClassicLoadIndicatorState();
  }
}

class _ClassicLoadIndicatorState extends State<ClassicLoadIndicator>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return buildContent();
  }

  @override
  Widget buildContent() {
    // TODO: implement buildContent
    final child = widget.mode == RefreshStatus.refreshing
        ? new SizedBox(
      width: 25.0,
      height: 25.0,
      child: const CircularProgressIndicator(strokeWidth: 2.0),
    )
        : new Text(
      widget.mode== RefreshStatus.idle
          ? 'Load More...'
          : widget.mode == RefreshStatus.noMore
          ? 'No more data'
          : 'Network exception!',
      style: new TextStyle(color: const Color(0xff555555)),
    );
    return new Container(
      height: 50.0,
      child: new Center(
        child: child,
      ),
    );
  }

}
