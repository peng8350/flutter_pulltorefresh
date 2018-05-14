import 'dart:async';
import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as HTTP;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Example2 extends StatefulWidget {
  @override
  _Example2State createState() => new _Example2State();
}

class _Example2State extends State<Example2> {
//  RefreshMode refreshing = RefreshMode.idle;
//  LoadMode loading = LoadMode.idle;
  int indexPage = 2;
  List<String> data = [];

  void _fetch() {
    HTTP
        .get(
            'http://image.baidu.com/channel/listjson?pn=$indexPage&rn=30&tag1=%E6%98%8E%E6%98%9F&tag2=%E5%85%A8%E9%83%A8&ie=utf8')
        .then((HTTP.Response response) {
      Map map = json.decode(response.body);

      return map["data"];
    }).then((array) {
      for (var item in array) {
        data.add(item["image_url"]);
      }
      indexPage++;
      setState(() {
//        loading = LoadMode.idle;
      });
    }).catchError(() {
      setState(() {
//        loading = LoadMode.failed;
      });
    });
  }

//  void _onModeChange(mode) {
//    //must be do it
//    setState(() {
//      refreshing = mode;
//    });
//    // this is equals onRefresh()
//    if (mode == RefreshMode.refreshing) {
//      new Future.delayed(const Duration(milliseconds: 2000), () {
//        setState(() {
//          refreshing = RefreshMode.completed;
//        });
//      });
//    }
//  }
//
//  _onLoadChange(LoadMode mode) {
//    //must be do it
//    setState(() {
//      loading = mode;
//    });
//    // this is equals onLoaadmore()
//    if(mode==LoadMode.loading){
//      _fetch();
//    }
//  }

  Widget buildImage(context, index) {
    if (data[index] == null) return new Container();
    return new Image.network(data[index]);
  }

  void _onOffsetCallback(bool isUp, double offset) {
    // if you want change some widgets state ,you should rewrite the callback
    if (isUp) {
    } else {}
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
