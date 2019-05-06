# flutter_pulltorefresh

## Intro
a widget provided to the flutter scroll component drop-down refresh and pull up load.support android and ios.
If you are Chinese,click here([中文文档](https://github.com/peng8350/flutter_pulltorefresh/blob/master/README_CN.md))

## Features
* Android and iOS both spported
* pull up and pull down
* It's almost fit for all witgets,like GridView,ListView,Container...
* High extensibility,High degree of freedom
* powerful Bouncing
* support reverse ScrollView
* provide more refreshStyle: Behind,Follow,UnFollow


## 指示器截图

|Style|Classic Follow| Classic UnFollow |
|:---:|:---:|:---:|
|art|![](example/images/classical_follow.gif)|![](example/images/classical_unfollow.gif))|

|Style| Behind | WaterDrop(QQ)|
|:---:|:---:|:---:|
|art|![](arts/screen1.gif)|![](example/images/warterdrop.gif))|




## How to use?

```

   dependencies:
     pull_to_refresh: ^1.3.0

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


## Props Table

SmartRefresher:

| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| controller | controll inner some states  | RefreshController | null | necessary |
| child      | your content View   | ? extends ScrollView   |   null |  necessary |
| header | the header indictor     | RefreshIndicator | ClassicHeader |if optional |
| footer | the footer indictor     | LoadIndicator  | optional |
| enablePullDown | switch of the pull down      | boolean | true | optional |
| enablePullUp |   switch of the pull up  | boolean | false |optional |
| onRefresh | will callback when the header indicator is getting refreshing   | (bool) => Void | null | optional |
| onLoad | will callback when the footer indicator is getting loading   | (bool) => Void | null | optional |
| onOffsetChange | callback while you dragging and outOfrange  | (bool,double) => Void | null | optional |
| enableOverScroll |  the switch of Overscroll,When you use  RefreshIndicator(Material), you may have to shut down.    | bool | true | optional |
| isNestWrapped | it will set true when SmartRefresher is wrapped by NestedScrollView  | bool | false | optional |


## FAQ
* <h3>Is it possible to automatically determine that the amount of data is larger than one page and hide the pull-up component?</h3>
There's no good way to do that right now. Flutter doesn't seem to provide Api so that we can get the total height of all items in ListView (before the interface is rendered). If anyone can solve this problem, please put it forward. Thank you very much.


* <h3>Does it support simple RefreshIndicator (material) + pull up loading and no elastic refresh combination?<br></h3>
Yes, as long as you set the node properties enableOverScroll = false, enablePullDown = false, it's OK to wrap a single RefreshIndicator outside, and
[Example4](https://github.com/peng8350/flutter_pulltorefresh/blob/master/example/lib/ui/Example3.dart) has given an example in demo.


* <h3>Why does child attribute extend from original widget to scrollView?<br></h3>
Because of my negligence, I didn't take into account the problem that child needed to cache the item,
so the 1.1.3 version had corrected the problem of not caching.


* <h3>Is there any way to achieve the maximum distance to limit springback?<br></h3>
The answer is negative. I know that it must be done by modifying the ScrollPhysics,
but I am not quite sure about the Api in it, but I failed.
If you have a way to solve this problem, please come to a PR



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
