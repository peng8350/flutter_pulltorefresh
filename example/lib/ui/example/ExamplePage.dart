/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-24 17:21
 */
import 'package:flutter/material.dart';
import 'package:example/ui/example/useStage/empty_view.dart';
import 'package:example/ui/example/useStage/hidefooter_bycontent.dart';
import 'package:example/ui/example/otherwidget/refesh_expansiopn_panel_list_example.dart';
import 'package:example/ui/example/useStage/horizontal+reverse.dart';
import 'package:example/ui/example/useStage/Nested.dart';
import 'package:example/ui/example/otherwidget/refresh_animatedlist_example.dart';
import 'package:example/ui/example/useStage/custom_header.dart';
import 'package:example/ui/example/useStage/basic.dart';
import 'package:example/ui/example/otherwidget/refresh_pageView_example.dart';
import 'package:example/ui/example/useStage/link_header_example.dart';
import 'package:example/ui/example/useStage/twolevel_refresh.dart';
import 'otherwidget/refresh_recordable_listview_example.dart';

class ExamplePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ExamplePageState();
  }
}

class ExampleItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ExampleItemState();
  }

  final Function onClick;

  final String title;

  ExampleItem({this.title, this.onClick});
}

class _ExampleItemState extends State<ExampleItem> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
      onTap: widget.onClick,
      child: Container(
        height: 100.0,
        child: Card(
          child: Center(
            child: Text(widget.title),
          ),
        ),
      ),
    );
  }
}

class _ExamplePageState extends State<ExamplePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    final List<ExampleItem> items1 = [
      ExampleItem(
          title: "基础用法",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return BasicExample();
            }));
          }),

      ExampleItem(
          title: "手动隐藏footer",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return Scaffold(
                body: HideFooterManual(),
                appBar: AppBar(),
              );
            }));
          }),
      ExampleItem(
          title: "LinkHeader例子",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return LinkHeaderExample();
            }));
          }),
      ExampleItem(
          title: "水平刷新",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return Scaffold(
                body: HorizontalRefresh(),
                appBar: AppBar(),
              );
            }));
          }),
      ExampleItem(
          title: "NestedScrollView下刷新",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return Scaffold(
                body: NestedRefresh(),
                appBar: AppBar(),
              );
            }));
          }),
      ExampleItem(
          title: "空白视图+刷新",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return Scaffold(
                body: RefreshWithEmptyView(),
                appBar: AppBar(),
              );
            }));
          }),
      ExampleItem(
          title: "淘宝二楼例子",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return TwoLevelExample();
            }));
          }),
      ExampleItem(
          title: "简单自定义头部指示器",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return Scaffold(
                body: CustomHeaderExample(),
                appBar: AppBar(),
              );
            }));
          }),
    ];
    final List<ExampleItem> items2 = [
      ExampleItem(
          title: "animatedlist结合refresher",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return Scaffold(
                body: AnimatedListExample(),
                appBar: AppBar(),
              );
            }));
          }),
      ExampleItem(
          title: "ExpansionPanelList配合使用",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return Scaffold(
                appBar: AppBar(),
                body: RefreshExpansionPanelList(),
              );
            }));
          }),
      ExampleItem(
          title: "pageView共用SmartRefresher",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return Scaffold(
                body: PageViewExample(),
                appBar: AppBar(),
              );
            }));
          }),
      ExampleItem(
          title: "RecordableListView",
          onClick: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return Scaffold(
                body: ReorderableListDemo(),
                appBar: AppBar(),
              );
            }));
          }),
    ];

    return Column(
      children: <Widget>[
        Container(
          child: TabBar(
            controller: _tabController,
            tabs: <Widget>[
              Tab(
                text: "使用场景",
              ),
              Tab(
                text: "配合一些特殊组件",
              )
            ],
          ),
          height: 50.0,
          color: Colors.greenAccent,
        ),
        Expanded(
          child: TabBarView(
            children: <Widget>[
              ListView(children: items1),
              ListView(children: items2)
            ],
            controller: _tabController,
          ),
        )
      ],
    );
  }
}
