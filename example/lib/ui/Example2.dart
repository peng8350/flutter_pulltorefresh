import 'dart:async';
import 'dart:convert' show json;
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
      _controller.sendBack(false, RefreshStatus.idle);
      indexPage++;
    }).catchError(() {
      _controller.sendBack(false, RefreshStatus.failed);
    });
  }

  void _onRefresh(bool up) {
    if (up)
      Future.delayed(const Duration(milliseconds: 2009)).then((val) {
        _controller.sendBack(true, RefreshStatus.completed);
//                refresher.sendStatus(RefreshStatus.completed);
      });
    else {
      Future.delayed(const Duration(milliseconds: 2009)).then((val) {
        _fetch();
      });
    }
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = RefreshController();
  }

  Widget _headerCreate(BuildContext context, RefreshStatus mode) {
    final _loadingContainer = Container(
        height: 50.0,
        color: Colors.black12,
        child: Center(
          child: Opacity(
            opacity: 0.9,
            child: SpinKitWave(
              color: Colors.red,
              size: 50.0,
            ),
          ),
        ));
    return _loadingContainer;
  }

  Widget _footerCreate(BuildContext context, RefreshStatus mode) {
    return ClassicIndicator(
      mode: mode,
      refreshingText: 'loading...',
      idleIcon: const Icon(Icons.arrow_upward),
      idleText: 'Loadmore...',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      controller: _controller,
      onRefresh: _onRefresh,
      headerBuilder: _headerCreate,
      footerBuilder: _footerCreate,
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
