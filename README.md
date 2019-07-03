# flutter_pulltorefresh

## Intro
a widget provided to the flutter scroll component drop-down refresh and pull up load.support android and ios.
If you are Chinese,click here([中文文档](https://github.com/peng8350/flutter_pulltorefresh/blob/master/README_CN.md))

## Features
* pull up load and pull down refresh
* It's almost fit for all Scroll witgets,like GridView,ListView...
* provide global setting of default indicator and property
* provide some most common indicators
* Support Android and iOS default ScrollPhysics,the overScroll distance can be controlled
* horizontal and vertical refresh,support reverse ScrollView also(four direction)
* provide more refreshStyle: Behind,Follow,UnFollow,Front
* Support twoLevel refresh,implments just like TaoBao twoLevel,Wechat TwoLevel
* enable link indicator which placing other place,just like Wechat FriendCircle refresh effect

## Usage

tips:<br>
1.Because 1.3.0 has made great changes to the internal, version 1.3.0-1.3.9 is not recommended to use,there has a lot of Bug , 1.4.0 began to stabilize.<br>
2.Make sure flutter sdk version >= 1.2.1

```

   dependencies:
     pull_to_refresh: ^1.4.7

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
        use _refreshController.loadComplete() or loadNoData(),loadFailed() to end loading
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
      child: "child",
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

finally,[here](https://github.com/peng8350/flutter_pulltorefresh/tree/master/example/lib/ui/example) is the examples,you can find more details in this


## ScreenShots

### Examples
|Style| [ basic usage ](example/lib/ui/example/useStage/basic.dart) | [header in other place](example/lib/ui/example/useStage/link_header_example.dart) |
|:---:|:---:|:---:|
|art| ![](arts/example1.gif) | ![](arts/example2.gif) |

|Style| [ reverse + horizontal](example/lib/ui/example/useStage/horizontal+reverse.dart) | [twoLevel refresh](example/lib/ui/example/useStage/twolevel_refresh.dart) |
|:---:|:---:|:---:|
|art| ![](arts/example3.gif) | ![](arts/example4.gif) |

|Style| [ use with other widgets](example/lib/ui/example/otherwidget) |  [ empty View](example/lib/ui/example/useStage/empty_view.dart) |
|:---:|:---:|:---:|
|art| ![](arts/example5.gif) | ![](arts/example6.gif) |

|Style| [ simple custom header(使用SpinKit)](example/lib/ui/example/useStage/custom_header.dart)| [dragableScrollSheet+LoadMore](example/lib/ui/example/otherwidget/draggable_bottomsheet_loadmore.dart)|
|:---:|:---:| :---:|
|art| ![](arts/example7.gif) | ![](arts/example8.gif) |


### Indicator

|Style| [ClassicIndicator](https://github.com/peng8350/flutter_pulltorefresh/blob/master/lib/src/indicator/classic_indicator.dart) | [WaterDropHeader](https://github.com/peng8350/flutter_pulltorefresh/blob/master/lib/src/indicator/waterdrop_header.dart) |
|:---:|:---:|:---:|
|art| ![](example/images/classical_follow.gif) | ![](example/images/warterdrop.gif) |

|Style| [MaterialClassicHeader](https://github.com/peng8350/flutter_pulltorefresh/blob/master/lib/src/indicator/material_indicator.dart) | [WaterDropMaterialHeader](https://github.com/peng8350/flutter_pulltorefresh/blob/master/lib/src/indicator/material_indicator.dart) |
|:---:|:---:|:---:|
|art| ![](example/images/material_classic.gif) | ![](example/images/material_waterdrop.gif) |






## More
- [Property Document](refresher_controller_en.md)
- [Custom Indicator](custom_indicator_en.md)
- [Inner Attribute Of Indicators](indicator_attribute_en.md)
- [Update Log](CHANGELOG.md)
- [Notice](notice_en.md)




## Frequent problems
* <h3>IOS Status Bar Double-click Why ListView does not automatically scroll to the top?</h3>
This problem is not my encapsulation error after testing. When the controller in ListView is replaced, this problem will occur, probably
because of the processing operation in Scaffold.,please issue flutter。

* <h3>Is Supporting NestedScrollView?</h3>
It's not recommended to use NestedScrollView. Now I've found a problem (in conflict with Bouncing ScrollPhysics),
which is similar in flutter issue (33367, 34316) and can only be solved by flutter. So it's better to use CustomScrollView to avoid using it, because there may be many unknown
 problems that I haven't found yet.

* <h3>Why is it that after using Cuper Navigation Bar (and not just this case), part of the list header is obscured?</h3>
Because I use CustomScrollView internally, and CustomScrollView doesn't inject padding like BoxScrollView does, so you need to inject padding or SafeArea yourself.

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
