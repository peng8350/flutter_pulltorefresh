library pulltorefresh;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum RefreshMode{
  idel,startDrag,canRefresh,refreshing,completed
}

class SmartRefresher extends StatefulWidget {
  /*
     first:indicate your listView
     second: the View when you pull down
     third: the View when you pull up
   */
  final Widget child, header, footer;
  // This bool will affect whether or not to have the function of drop-up load.
  final bool enablePullUpLoad;
  //This bool will affect whether or not to have the function of drop-down refresh.
  final bool enablePulldownRefresh;

  final double triggerDistance;

  final Color headerColor, footerColor;

  SmartRefresher(
      {@required this.child,
      this.enablePulldownRefresh: true,
      this.enablePullUpLoad: false,
      this.headerColor: const Color(0xffdddddd),
      this.footerColor: const Color(0xffdddddd),
      this.header,
      this.triggerDistance: 150.0,
      this.footer})
      : assert(child != null);

  @override
  _SmartRefresherState createState() => new _SmartRefresherState();
}

class _SmartRefresherState extends State<SmartRefresher>
    with TickerProviderStateMixin {
  AnimationController _topController, _bottomController;
  ScrollController _scrollController=new ScrollController();
  RefreshMode _topMode,_bottomMode;
  GlobalKey _topKey, _bottomKey;

  void _dismiss() {
    if (!_topController.isDismissed)
      _topController.animateTo(0.01,
          curve: new Cubic(0.0, 0.0, 1.0, 1.0),
          duration: const Duration(milliseconds: 150));
    if (!_bottomController.isDismissed)
      _bottomController.animateTo(0.01,
          curve: new Cubic(0.0, 0.0, 1.0, 1.0),
          duration: const Duration(milliseconds: 150));
  }

  // This method calculates the size of the head or tail that should be resized.
  double _measureRatio(double offset) {
    return offset.abs()/40.0;
  }

  bool _onScrollUpdate(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {

      if(notification.metrics.extentBefore==0&&notification.dragDetails!=null){
        _topController.value =_measureRatio(_scrollController.offset);
      }
    }

    return false;
  }

  // if your renderHeader null, it will be replaced by it
  Widget _buildDefaultHeader() {
    return new Container(
      height: 50.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CupertinoActivityIndicator(),
          new Text('Refreshing....')
        ],
      ),
    );
  }

  // if your renderFooter null, it will be replaced by it
  Widget _buildDefaultFooter() {
    return new Container(
      height: 50.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CupertinoActivityIndicator(),
          new Text('LoadMore....')
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _topKey = new GlobalKey();
    _bottomKey = new GlobalKey();
    _topController = new AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 200),
    );
    _bottomController = new AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
  );
  }

  Widget _buildEmptySpace(key, sizeFactor) {
    return new Container(
      child: new SizeTransition(
          sizeFactor: sizeFactor,
          child: new Container(
            height: 50.0,
            key: key,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(builder: (context, BoxConstraints size) {
      return new OverflowBox(
        maxHeight: size.biggest.height+100.0,
        alignment: Alignment.center,
        child: new NotificationListener(
          child:
             new ListView(
               controller: _scrollController,
              physics: new BouncingScrollPhysics(),
              children: <Widget>[
                _buildEmptySpace(_topKey,_topController),
                _buildDefaultHeader(),
                widget.child,
                _buildDefaultFooter(),
                _buildEmptySpace(_bottomKey,_bottomController),
              ],
            ),

          onNotification: _onScrollUpdate,
        ),

      );
    });
  }
}
