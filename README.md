# flutter_pulltorefresh

## Intro
a widget provided to the flutter scroll component drop-down refresh and pull up load.support android and ios.
If you are Chinese,click here([中文文档](https://github.com/peng8350/flutter_pulltorefresh/blob/master/README_CN.md))

## Features
* pull up and pull down
* It's almost fit for all Scroll witgets,like GridView,ListView...
* powerful Bouncing
* support reverse ScrollView
* provide more refreshStyle: Behind,Follow,UnFollow


## ScreenShots

### Four RefreshStyle
|Style| Follow | UnFollow |
|:---:|:---:|:---:|
|art| ![](example/images/classical_follow.gif) | ![](example/images/classical_unfollow.gif) |

|Style| Behind | Front |
|:---:|:---:|:---:|
|art| ![](arts/screen1.gif) | ![](example/images/material_classic.gif) |

### Indicator

|Style| [ClassicIndicator](https://github.com/peng8350/flutter_pulltorefresh/blob/master/lib/src/indicator/classic_indicator.dart) | [WaterDropHeader](https://github.com/peng8350/flutter_pulltorefresh/blob/master/lib/src/indicator/waterdrop_header.dart) |
|:---:|:---:|:---:|
|art| ![](example/images/classical_follow.gif) | ![](example/images/warterdrop.gif) |

|Style| [MaterialClassicHeader](https://github.com/peng8350/flutter_pulltorefresh/blob/master/lib/src/indicator/material_indicator.dart) | [WaterDropMaterialHeader](https://github.com/peng8350/flutter_pulltorefresh/blob/master/lib/src/indicator/material_indicator.dart) |
|:---:|:---:|:---:|
|art| ![](example/images/material_classic.gif) | ![](example/images/material_waterdrop.gif) |




## How to use?

```

   dependencies:
     pull_to_refresh: ^1.4.2

```

```

import 'package:pull_to_refresh/pull_to_refresh.dart';

RefreshController _refreshController;

initState(){

    super.initState();
    // if you need refreshing when init,notice:initialRefresh is new  after 1.3.9
    _refreshController = RefreshController(initialRefresh:true);

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
      header: defaultTargetPlatform == TargetPlatform.iOS?WaterDropHeader():WaterDropMaterialHeader(),
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


In addition, if you have almost the same header and tail indicators for each page, consider using RefreshConfiguration
, which reduces the repeatability of constructing headers and footers for each new page.
At the same time, you can also set some global properties, such as whether to turn on automatic loading, refresh the trigger distance, whether to automatically hide the tail indicator should not meet a page.
the [example](https://github.com/peng8350/flutter_pulltorefresh/blob/master/example/lib/ui/MainActivity.dart) in my demo
```

    RefreshConfiguration(
        headerBuilder: () => WaterDropHeader(),
        footerBuilder:  () => ClassicFooter(),
        clickLoadingWhenIdle: true,
         headerTriggerDistance: 80.0,
         hideFooterWhenNotFull: true,
        child: .....
    )

```


## More
- [SmartRefresher,RefreshController](refresher_controller_en.md)
- [Custom Indicator](custom_indicator_en.md)
- [Inner Attribute Of Indicators](indicator_attribute_en.md)
- [Update Log](CHANGELOG.md)
- [Notice](notice_en.md)




## Frequent problems
* <h3>IOS Status Bar Double-click Why ListView does not automatically scroll to the top?</h3>
This problem is not my encapsulation error after testing. When the controller in ListView is replaced, this problem will occur, probably
because of the processing operation in Scaffold.,please issue flutter。

* <h3>How to use it with NestedScrollView?</h3>
1.3.0 provides a new attribute isNestWrapped for compatibility. Note that when this attribute is opened, scollController depends on NestScrollView,
internally via PrimaryScrollController. of (context) To get scrollController, scrollController is placed in NestedScrollView。
(The isNestWrapped attribute is unnecessary after 1.3.8)

* <h3>Why is there a empty space in the top or tail indicator after using CuperNavigationBar (not just in this case)?</h3>
the reason may be SafeArea,the solution: wrap SmartRefresher in SafeArea

* <h3>Compatibility?</h3>
1.3.0 replaces a new method to implement the indicator. The internal indicator is implemented by monitoring scroll Controller position changes. There are no methods such as NotificationListener and GestureDector that may cause sliding gesture conflicts.
So it should be compatible with most of the libraries that need to be used between gestures. However, some libraries may not be compatible and ScrollPhysics needs to be rewritten, which is clearly required for internal FrontStyle.



## Thanks

[SmartRefreshLayout](https://github.com/scwang90/SmartRefreshLayout)

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
