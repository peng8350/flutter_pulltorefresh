/**
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 17:39
 */

import 'package:flutter/material.dart' hide RefreshIndicator;
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum IconPosition{
  left,right,top,bottom
}

class ClassicRefreshIndicator extends RefreshIndicator {
  AnimationController rorateController;

  final String releaseText,idleText,refreshingText,completeText,failedText;

  final Widget releaseIcon,idleIcon,refreshingIcon,completeIcon,failedIcon;

  final double height;

  final double spacing;

  final IconPosition iconPos;

  final TextStyle textStyle;

  final bool openRotate;


  ClassicRefreshIndicator(
      {@required TickerProvider vsync,
      @required bool up,
        this.textStyle:const TextStyle(color: const Color(0xff555555)),
        this.releaseText:'Refresh when release',
        this.refreshingText:'Refreshing...',
        this.completeText:'Refresh complete!',
        this.height:60.0,
        this.failedText:'Refresh failed',
        this.idleText:'Pull down refesh',
        this.openRotate: true,
        this.iconPos:IconPosition.left,
        this.spacing:15.0,
        this.refreshingIcon: const CircularProgressIndicator(strokeWidth: 2.0),
        this.failedIcon:const Icon(Icons.clear, color: Colors.grey),
        this.completeIcon:const Icon(Icons.done, color: Colors.grey),
        this.idleIcon = const Icon(Icons.arrow_downward, color: Colors.grey),
        this.releaseIcon = const Icon(Icons.arrow_downward, color: Colors.grey),
      int completeTime: 800,
      double visibleRange: 60.0,
      double triggerDistance: 80.0})
      : assert(vsync != null, up != null),
        super(
            up: up,
            vsync: vsync,
            completeTime: completeTime,
            visibleRange: visibleRange,
            triggerDistance: triggerDistance) {
    rorateController = new AnimationController(
        vsync: vsync,
        upperBound: 0.5,
        duration: const Duration(milliseconds: 100));
  }


  @override
  set mode(int mode) {
    // TODO: implement mode
    if (this.mode == mode) return;
    super.mode = mode;
    if (this.mode == RefreshStatus.canRefresh) {
      rorateController.animateTo(1.0);
    }
    if (this.mode == RefreshStatus.idle) {
      rorateController.animateTo(0.0);
    }
  }

  Widget _buildText(){
    return new Text(mode == RefreshStatus.canRefresh
        ? releaseText
        : mode == RefreshStatus.completed
        ? completeText
        : mode == RefreshStatus.failed
        ? failedText
        : mode == RefreshStatus.refreshing
        ? refreshingText
        : idleText,
      style: textStyle);
  }

  Widget _buildIcon(){
    return mode==RefreshStatus.canRefresh?releaseIcon:mode==RefreshStatus.idle?idleIcon:
        mode==RefreshStatus.completed?completeIcon:mode==RefreshStatus.failed?failedIcon:
        new SizedBox(
          width: 25.0,
          height: 25.0,
          child: const CircularProgressIndicator(strokeWidth: 2.0),
        );
  }


  @override
  Widget buildContent() {
    // TODO: implement buildContent
    Widget textWidget= _buildText();
    Widget iconWidget = _buildIcon();
    List<Widget> childrens = <Widget>[
      iconWidget,
      new Container(
        width: spacing,
        height: spacing,
      ),
      textWidget
    ];
    Widget container = (iconPos==IconPosition.top||iconPos==IconPosition.bottom)?new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      verticalDirection: iconPos==IconPosition.top?VerticalDirection.down:VerticalDirection.up,
      children: childrens ,
    ):new Row(
      textDirection: iconPos==IconPosition.right?TextDirection.rtl:TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.center,
      children: childrens,
    );
    return new Container(
      height: height,
      alignment: Alignment.center,
      child: new Center(
        child: container,
      ),
    );
  }
}

class ClassicLoadIndicator extends LoadIndicator {
  ClassicLoadIndicator({@required bool up, bool autoLoad: true})
      :assert(up!=null), super(up: up, autoLoad: autoLoad);

  @override
  Widget buildContent() {
    // TODO: implement buildContent
    final child = mode == RefreshStatus.refreshing
        ? new SizedBox(
            width: 25.0,
            height: 25.0,
            child: const CircularProgressIndicator(strokeWidth: 2.0),
          )
        : new Text(
            mode == RefreshStatus.idle
                ? 'Load More...'
                : mode == RefreshStatus.noMore
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
