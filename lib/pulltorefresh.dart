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

  SmartRefresher(
      {@required this.child,
      this.enablePulldownRefresh: true,
      this.enablePullUpLoad: false,
      this.header,this.triggerDistance:150.0,
      this.footer})
      : assert(child != null);

  @override
  _SmartRefresherState createState() => new _SmartRefresherState();
}

class _SmartRefresherState extends State<SmartRefresher>
    with TickerProviderStateMixin {
  AnimationController _headerController, _footerController;
  double startDragY=0.0;

  void _disapperate(){
    if(!_headerController.isDismissed)
    _headerController.animateTo(0.01,curve: new Cubic(0.0, 0.0, 1.0, 1.0),duration: const Duration(milliseconds: 100));
    if(!_footerController.isDismissed)
      _footerController.animateTo(0.01,curve: new Cubic(0.0, 0.0, 1.0, 1.0),duration: const Duration(milliseconds: 100));
  }

  bool _onScrollUpdate(ScrollNotification notification) {
    if(notification is ScrollStartNotification){
      startDragY = notification.dragDetails.globalPosition.dy;
    }
    if(notification is OverscrollNotification){
        // This means that the distance that the user dragged occupies the height of the control.
        final ratio = ((notification.dragDetails.globalPosition.dy-startDragY)/context.size.height)*7.0;
        print(ratio);
        _headerController.value= ratio;
    }
    if(notification is ScrollEndNotification){
        _disapperate();
    }



    return false;
  }

  bool _isiOS(){
    return Theme.of(context).platform==TargetPlatform.iOS;
  }

  // if your renderHeader null, it will be replaced by it
  Widget _buildDefaultHeader() {
    return new Container(
      height:50.0,
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
  }
  
  @override
  Widget build(BuildContext context) {

    if(_isiOS()){

      _headerController = new AnimationController(vsync: this,duration: const Duration(milliseconds: 200),lowerBound: 0.0,upperBound: 25.0);
      _footerController = new AnimationController(vsync: this,duration: const Duration(milliseconds: 200),lowerBound: 0.0,upperBound: 1.0);
    }
    else{

    }

    return new NotificationListener(
      child: new ListView(
        physics: new ClampingScrollPhysics(),
        children: <Widget>[

         new Container(color:const Color(0xffdddddd),child:  new SizeTransition(

             axisAlignment: 1.0,
             sizeFactor: _headerController,
             child: _buildDefaultHeader()),),
          widget.child,
          new SizeTransition(
              axisAlignment: -1.0,
              sizeFactor: _headerController,
              child: _buildDefaultFooter())
        ],
      ),
      onNotification: _onScrollUpdate,
    );
  }
  
  
}
