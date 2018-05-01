library pulltorefresh;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  AnimationController _headerController, _footerController;
  double _startDragY = 0.0;
  GlobalKey _headerKey,_footerKey;
  void _dismiss() {
    if (!_headerController.isDismissed)
      _headerController.animateTo(0.01,
          curve: new Cubic(0.0, 0.0, 1.0, 1.0),
          duration: const Duration(milliseconds: 150));
    if (!_footerController.isDismissed)
      _footerController.animateTo(0.01,
          curve: new ElasticOutCurve(),
          duration: const Duration(milliseconds: 150));
  }

  // This method calculates the size of the head or tail that should be resized.
  double _measureRatio(double nowY,double layoutSize,bool up){
    double widgetSize=  context.size.height;
    double ratio = ((nowY-_startDragY)/widgetSize)*0.5*(widgetSize/layoutSize);
    if(up)
      ratio=-ratio;
    return ratio;
  }

  bool _onScrollUpdate(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _startDragY = notification.dragDetails.globalPosition.dy;
    }
    else if (notification is OverscrollNotification) {

      if(notification.metrics.extentBefore==0){
        final ratio =_measureRatio(notification.dragDetails.globalPosition.dy, _headerKey.currentContext.size.height,false);
        _headerController.value = ratio;
      }
      else if(notification.metrics.extentAfter==0){
        print(notification.dragDetails.globalPosition);
        final ratio =_measureRatio(notification.dragDetails.globalPosition.dy, _footerKey.currentContext.size.height,true);
        _footerController.value = ratio;
      }
    }
    else if (notification is ScrollEndNotification) {
      _startDragY= 0.0;
      _dismiss();
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
    _headerKey = new GlobalKey();
    _footerKey = new GlobalKey();
    _headerController = new AnimationController(
        vsync: this,
        lowerBound: 0.0,
        upperBound: double.infinity,
        duration: const Duration(milliseconds: 200),
        );
    _footerController = new AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        lowerBound: 0.0,
        upperBound: double.infinity);
  }


  Widget _buildTopBottom(color,axisAlign,key,sizeFactor,layout){
    return new Container(
        color: color,
        child: new SizeTransition(
          axisAlignment: axisAlign,
            sizeFactor : sizeFactor,
        child: new Container(
          key: key,
          child: layout,
        )),
    );
  }

  @override
  Widget build(BuildContext context) {

    return new NotificationListener(
      child: new ListView(
        physics: new ClampingScrollPhysics(),
        children: <Widget>[
          _buildTopBottom(widget.headerColor,1.0, _headerKey, _headerController, _buildDefaultHeader()),
          widget.child,
          _buildTopBottom(widget.footerColor,-1.0, _footerKey, _footerController, _buildDefaultFooter())
        ],
      ),
      onNotification: _onScrollUpdate,
    );
  }
}
