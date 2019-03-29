import 'Example1.dart';
import 'Example2.dart';
import 'Example3.dart';
import 'Example4.dart';
import 'package:flutter/material.dart';
import 'SecondActivity.dart';

class MainActivity extends StatefulWidget {
  MainActivity({Key key, this.title}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MainActivityState createState() => new _MainActivityState();
}

class _MainActivityState extends State<MainActivity> with SingleTickerProviderStateMixin{
  int tabIndex = 0;

  List<Widget> views;
  TabController _tabController;
  GlobalKey<Example3State> example3Key= new GlobalKey();
  GlobalKey<Example1State> example1Key= new GlobalKey();

  void _changePage(){
    Navigator.of(context).pushNamed("sec");
  }

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
    return new Scaffold(

      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
        actions: <Widget>[new MaterialButton(onPressed: (){
         tabIndex==2? example3Key.currentState.enterRefresh():tabIndex==0?example1Key.currentState.scrollTop():_changePage();
        },child: new Text(tabIndex==2?'refresh3':tabIndex==0?"滚回顶部":"跳转页面",style: new TextStyle(color:Colors.white),))],
      ),
      body: new Stack(

        children: <Widget>[
          new Offstage(
            child: views[0],
            offstage: tabIndex!=0,
          ),
          new Offstage(
            child: views[1],
            offstage: tabIndex!=1,
          ),
          new Offstage(
            child: views[2],
            offstage: tabIndex!=2,
          ),
          new Offstage(
            child: views[3],
            offstage: tabIndex!=3,
          )
        ],
      ),
      bottomNavigationBar: new BottomNavigationBar(
        items: [
          new BottomNavigationBarItem(
              icon: new Icon(Icons.home,
                  color: tabIndex == 0 ? Colors.blue : Colors.grey),
              title: new Text('Example1',
                  style: new TextStyle(
                      color: tabIndex == 0 ? Colors.blue : Colors.grey))),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.cloud,
                  color: tabIndex == 1 ? Colors.blue : Colors.grey),
              title: new Text('Example2',
                  style: new TextStyle(
                      color: tabIndex == 1 ? Colors.blue : Colors.grey))),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.call,
                  color: tabIndex == 2 ? Colors.blue : Colors.grey),
              title: new Text('Example3',
                  style: new TextStyle(
                      color: tabIndex == 2 ? Colors.blue : Colors.grey))),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.transform,
                  color: tabIndex == 3 ? Colors.blue : Colors.grey),
              title: new Text('Example4',
                  style: new TextStyle(
                      color: tabIndex == 3 ? Colors.blue : Colors.grey))),
        ],
        onTap: (index) {
          setState(() {
            tabIndex = index;
          });
        },
        currentIndex: tabIndex,
        fixedColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    _tabController = new TabController(length: 4, vsync: this);
    views = [new Example1(key:example1Key),new Example2(),new Example3(key:example3Key),new Example4()];
    super.initState();
  }

}
