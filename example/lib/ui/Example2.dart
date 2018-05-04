import 'dart:async';
import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Example2 extends StatefulWidget {
  @override
  _Example2State createState() => new _Example2State();
}

class _Example2State extends State<Example2> {
  RefreshMode loading = RefreshMode.idel, refreshing = RefreshMode.idel;
  int indexPage = 2;
  List<String> data = [];

//  http://gank.io/api/data/%E7%A6%8F%E5%88%A9/10/1


  void _fetch(){
    http.get('http://gank.io/api/data/%E7%A6%8F%E5%88%A9/30/$indexPage').then((http.Response response){
      Map map = json.decode(response.body);
      return map["results"];
    }).then((array){
      for(var item in array){
        data.add(item["url"]);
      }
      indexPage++;
      setState(() {
        loading = RefreshMode.completed;
      });
    }).catchError((){
      setState(() {
        loading = RefreshMode.failed;
      });
    });
  }

  void _onModeChange(isUp, mode) {
    if (isUp) {
      //must be do it
      setState(() {
        refreshing = mode;
      });
      // this is equals onRefresh()
      if (mode == RefreshMode.refreshing) {
        new Future.delayed(const Duration(milliseconds: 2000), () {
          setState(() {
            refreshing = RefreshMode.completed;
          });
        });
      }
    } else {
      //must be do it
      setState(() {
        loading = mode;
      });
      // this is equals onLoaadmore()
      if (mode == RefreshMode.refreshing) {
        _fetch();

      }
    }
  }

  Widget buildImage(context, index) {
    return new Text('sdsd');
  }

  void _onOffsetCallback(double offset) {
    // if you want change some widgets state ,you should rewrite the callback
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new SmartRefresher(
            enablePullDownRefresh: true,
            enablePullUpLoad: true,
            refreshMode: this.refreshing,
            loadMode: this.loading,
            onModeChange: _onModeChange,
            onOffsetChange: _onOffsetCallback,
            child: new GridView.builder(
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: buildImage,
            )));
  }
}
