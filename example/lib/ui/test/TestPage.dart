import 'Test1.dart';
import 'Test2.dart';
import 'Test3.dart';
import 'Test4.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  TestPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _TestPageState createState() => new _TestPageState();
}

class _TestPageState extends State<TestPage>
    with SingleTickerProviderStateMixin {
  int tabIndex = 0;
  PageController _pageController;
  List<Widget> views;
  GlobalKey<Test3State> example3Key = GlobalKey();
  GlobalKey<Test1State> example1Key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
//    return new Scaffold(
//
//      appBar: new AppBar(
//        // Here we take the value from the MyHomePage object that was created by
//        // the App.build method, and use it to set our appbar title.
//        bottom: new TabBar(controller: _tabController,tabs: <Widget>[            new Tab(icon: new Icon(Icons.nature),) , new Tab(icon: new Icon(Icons.directions_bike),),
//        new Tab(icon: new Icon(Icons.directions_boat),),
//        new Tab(icon: new Icon(Icons.directions_bus),),],),
//        title: new Text(widget.title),
//        actions: <Widget>[(tabIndex==2||tabIndex==0)?new MaterialButton(onPressed: (){
//          tabIndex==2? example3Key.currentState.enterRefresh():example1Key.currentState.scrollTop();
//        },child: new Text(tabIndex==2?'refresh3':"滚回顶部",style: new TextStyle(color:Colors.white),)):new Container()],
//      ),
//      body: new TabBarView(children: views,controller:_tabController ,),
//    );
    return Column(
      children: <Widget>[
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            children: views,
            onPageChanged: (index) {
              tabIndex = index;
              if (mounted) setState(() {});
            },
          ),
        ),
        BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home,
                    color: tabIndex == 0 ? Colors.blue : Colors.grey),
                title: Text('Example1',
                    style: TextStyle(
                        color: tabIndex == 0 ? Colors.blue : Colors.grey))),
            BottomNavigationBarItem(
                icon: Icon(Icons.cloud,
                    color: tabIndex == 1 ? Colors.blue : Colors.grey),
                title: Text('Example2',
                    style: TextStyle(
                        color: tabIndex == 1 ? Colors.blue : Colors.grey))),
            BottomNavigationBarItem(
                icon: Icon(Icons.call,
                    color: tabIndex == 2 ? Colors.blue : Colors.grey),
                title: Text('Example3',
                    style: TextStyle(
                        color: tabIndex == 2 ? Colors.blue : Colors.grey))),
            BottomNavigationBarItem(
                icon: Icon(Icons.transform,
                    color: tabIndex == 3 ? Colors.blue : Colors.grey),
                title: Text('Example4',
                    style: TextStyle(
                        color: tabIndex == 3 ? Colors.blue : Colors.grey))),
          ],
          onTap: (index) {
            _pageController.jumpToPage(index);
          },
          currentIndex: tabIndex,
          fixedColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        )
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    _pageController = PageController();
    views = [
      Test1(key: example1Key),
      Test2(),
      Test3(key: example3Key),
      Test4()
    ];
    super.initState();
  }
}
