# flutter_pulltorefresh

## Intro
a widget provided to the flutter scroll component drop-down refresh and pull up load.support android and ios.
If you are Chinese,click here([中文文档](https://github.com/peng8350/flutter_pulltorefresh/blob/master/README_CN.md))

## Features
* Android and iOS both spported
* pull up and pull down
* It's almost fit for all Scroll witgets,like GridView,ListView...
* High extensibility,High degree of freedom
* powerful Bouncing
* support reverse ScrollView
* provide more refreshStyle: Behind,Follow,UnFollow


## 指示器截图

|Classic Follow| Classic UnFollow |
|:---:|:---:|
|![](example/images/classical_follow.gif)|![](example/images/classical_unfollow.gif)|

| Behind | WaterDrop(QQ)|
|:---:|:---:|
|![](arts/screen1.gif)|![](example/images/warterdrop.gif)|




## How to use?

```

   dependencies:
     pull_to_refresh: ^1.3.1

```



```

RefreshController _refreshController;

initState(){

    super.initState();
    _refreshController = RefreshController();
}

void _onRefresh(){

   /*.  after the data return,
        use _refreshController.refreshComplete() or refreshFailed() to end refreshing
   */
}

void _onLoading(){
   /*
        use _refreshController.loadComplete() or loadNoData() to end loading
   */
}

build(){
...
SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: "yourContentScrollView",
    )
....
}

// don't forget to dispose refreshController
void dispose(){
    _refreshController.dispose();
    super.dispose();
}

```

When the amount of data is too small, there is no automatic judgment to hide. You need to dynamically judge the height and actual size of listView. The height of listView can be determined by LayoutBuilder
,[example1](https://github.com/peng8350/flutter_pulltorefresh/blob/master/example/lib/ui/Example1.dart) is an example.

```

       double innerListHeight= ...;
       // listView height
       double listHeight = ...;

       new SmartRefresher(
           enablePullUp: innerListHeight>listHeight
          .....
       )


```



## Custom
1.In the first way, assuming that the indicator function you want to implement is not too complex, you can use CustomHeader or CustomFooter

```
   Widget buildHeader(BuildContext context,RefreshStatus mode){
      .....
   }

   SmartRefresher(
      ...
      header: CustomHeader(builder:buildHeader)

      ...
   )

```

2.The second way is by integrating RefreshInditor or Load Indicator, for detailed reference [ClassicIndicator](lib/src/indicator/classic_indicator.dart)

## Props Table

SmartRefresher:

| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| controller | controll inner some states  | RefreshController | null | necessary |
| child      | your content View   | ? extends ScrollView   |   null |  necessary |
| header | the header indictor     | RefreshIndicator | ClassicHeader | optional |
| footer | the footer indictor     | LoadIndicator  | ClassicFooter | optional |
| enablePullDown | switch of the pull down      | boolean | true | optional |
| enablePullUp |   switch of the pull up  | boolean | false |optional |
| onRefresh | will callback when the header indicator is getting refreshing   | () => Void | null | optional |
| onLoad | will callback when the footer indicator is getting loading   | () => Void | null | optional |
| onOffsetChange | callback while you dragging and outOfrange  | (bool,double) => Void | null | optional |
| enableOverScroll |  the switch of Overscroll,When you use  RefreshIndicator(Material), you may have to shut down.    | bool | true | optional |
| isNestWrapped | it will set true when SmartRefresher is wrapped by NestedScrollView  | bool | false | optional |


## Frequent problems
* <h3>IOS Status Bar Double-click Why ListView does not automatically scroll to the top?</h3>
This problem is not my encapsulation error after testing. When the controller in ListView is replaced, this problem will occur, probably
because of the processing operation in Scaffold.,please issue flutter。

* <h3>How to use it with NestedScrollView?</h3>
1.3.0 provides a new attribute isNestWrapped for compatibility. Note that when this attribute is opened, scollController depends on NestScrollView,
internally via PrimaryScrollController. of (context) To get scrollController, scrollController is placed in NestedScrollView。

* <h3>Why is there a empty space in the top or tail indicator after using CuperNavigationBar (not just in this case)?</h3>
the reason may be SafeArea,the solution: wrap SmartRefresher in SafeArea

* <h3>Is it possible to automatically determine that the amount of data is larger than one page and hide the pull-up component?</h3>
There's no good way to do that right now. Flutter doesn't seem to provide Api so that we can get the total height of all items in ListView (before the interface is rendered). If anyone can solve this problem, please put it forward. Thank you very much.


* <h3>Does it support simple RefreshIndicator (material) + pull up loading and no elastic refresh combination?<br></h3>
Yes, as long as you set the node properties enableOverScroll = false, enablePullDown = false, it's OK to wrap a single RefreshIndicator outside, and
[Example4](https://github.com/peng8350/flutter_pulltorefresh/blob/master/example/lib/ui/Example3.dart) has given an example in demo.





## LICENSE
 
```
 
MIT License

Copyright (c) 2018 Jpeng

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

 
 ```
