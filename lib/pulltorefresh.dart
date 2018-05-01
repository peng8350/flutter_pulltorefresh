library pulltorefresh;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

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

  SmartRefresher(
      {@required this.child,
      this.enablePulldownRefresh: true,
      this.enablePullUpLoad: false,
      this.header,
      this.footer})
      : assert(child != null);

  @override
  _SmartRefresherState createState() => new _SmartRefresherState();
}

class _SmartRefresherState extends State<SmartRefresher> {
  // if your renderHeader null, it will be replaced by it
  Widget _buildDefaultHeader() {
    return new Container(
      color:const Color(0xffdddddd),
      height: 50.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new CupertinoActivityIndicator(),
          new Text('Refreshing....')
        ],
      ),
    );
  }

  // if your renderFooter null, it will be replaced by it
  Widget _buildDefaultFooter() {
    return new Container(
      color:const Color(0xffdddddd),
      alignment: Alignment.center,
      height: 50.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new CupertinoActivityIndicator(),
          new Text('LoadMore....')
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new ListView(
      children: <Widget>[
        _buildDefaultHeader(),
        widget.child,
        _buildDefaultFooter()
      ],
    );
  }
}
