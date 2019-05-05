import 'dart:async';
import 'dart:convert' show json,base64Decode ;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as HTTP;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Example2 extends StatefulWidget {
  @override
  _Example2State createState() => _Example2State();
}

class _Example2State extends State<Example2> with TickerProviderStateMixin {
  RefreshController _controller;
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
      setState(() {});
      _controller.loadComplete();
      indexPage++;
    }).catchError(() {
      _controller.loadComplete();
    });
  }

  void _onRefresh() {
    Future.delayed(const Duration(milliseconds: 2009)).then((val) {
      _controller.refreshCompleted();
//                refresher.sendStatus(RefreshStatus.completed);
    });
  }

  void _onLoading() {
    Future.delayed(const Duration(milliseconds: 2009)).then((val) {
      _fetch();
    });
  }

  Widget buildImage(context, index) {
    return Item(
      url: data[index],
    );
  }

  void _onOffsetCallback(bool isUp, double offset) {
    // if you want change some widgets state ,you should rewrite the callback
    if (isUp) {
    } else {}
  }

  Widget _headerCreate(BuildContext context, RefreshStatus mode) {
    if (mode == RefreshStatus.refreshing) {
      return SpinKitCircle(color: Colors.greenAccent);
    } else {
      return SpinKitDualRing(color: Colors.greenAccent);
    }
  }

  Widget _footerCreate(BuildContext context, LoadStatus mode) {
    return Image.memory(base64Decode("R0lGODlhFAAUALMAAGaZADOZzP8zM5mZmczMzNra2t7e3uLi4uXl5enp6e3t7fHx8fb29vn5+f7+/gAAACH/C05FVFNDQVBFMi4wAwEAAAAh/g9Qb3dlcmVkIGJ5IEFGRUkAIfkECRQADwAsAAAAABQAFAAABJLwkUmrpdLpzfue2jA4YliKowOmZBtu6drMQ1PbM96oBJnXwF+O52CIjEiU8UhcOJ/Q6KIpDQSkU5Biy1VYtwAAl5gomxPWcthMLgsE5XRiXSYi7u+79R6+I4gHgW+BVoFhgQdEBotvi1aLYYsGiowCjgGQAJJEBZ1vnVadYZ0FnJ4CoAGiAKREHq8cBBIXtBUPEQAh+QQJFAAPACwAAAAAFAAUAAAEjPCRSaul0unN+57aMDhiWIqjA6ZkG27p2sxDU9sz3qgEmdfAX47nYIiMSJTxSFw4n9DooimtOomKrECQ7XqzxIR4Ky6bxeGx4JwAAMpEhHwrryPcdeJhv937D25+RAaEW4QBAYRuhAaDhQKHiQaLhEQFl1uXiJdulwWWmAKaAZwAnkQeqRwEEheuFQ8RADs="));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = RefreshController();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      controller: _controller,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      onOffsetChange: _onOffsetCallback,
      child: GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: data.length,
        itemBuilder: buildImage,
      ),
    );
  }
}

class Item extends StatefulWidget {
  final String url;

  Item({this.url});

  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {
  @override
  Widget build(BuildContext context) {
    if (widget.url == null) return Container();
    return RepaintBoundary(
      child: Image.network(
        widget.url,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
