# flutter_pulltorefresh

## 介绍
一个提供上拉加载和下拉刷新的组件,同时支持Android和Ios

## 特性
* 提供上拉加载和下拉刷新
* 几乎适合所有部件
* 高度扩展性和很低的限制性
* 支持反转列表
* 提供多种刷新指示器风格:跟随,不跟随,位于背部,位于前部

## 指示器截图
### 四种指示器风格
|Style| 跟随经典指示器|不跟随经典指示器|
|:---:|:---:|:---:|
|art| ![](example/images/classical_follow.gif) | ![](example/images/classical_unfollow.gif) |

|Style|背部指示器|前面悬浮指示器|
|:---:|:---:|:---:|
|art| ![](arts/screen1.gif) | ![](example/images/material_classic.gif) |

### 各种指示器

|Style| [ClassicIndicator](https://github.com/peng8350/flutter_pulltorefresh/blob/master/lib/src/indicator/classic_indicator.dart) | [WaterDropHeader](https://github.com/peng8350/flutter_pulltorefresh/blob/master/lib/src/indicator/waterdrop_header.dart) |
|:---:|:---:|:---:|
|art| ![](example/images/classical_follow.gif) | ![](example/images/warterdrop.gif) |

|Style| [MaterialClassicHeader](https://github.com/peng8350/flutter_pulltorefresh/blob/master/lib/src/indicator/material_indicator.dart) | [WaterDropMaterialHeader](https://github.com/peng8350/flutter_pulltorefresh/blob/master/lib/src/indicator/material_indicator.dart) |
|:---:|:---:|:---:|
|art| ![](example/images/material_classic.gif) | ![](example/images/material_waterdrop.gif) |

## 我该怎么用?


```

   dependencies:
     pull_to_refresh: ^1.4.3

```

```
import 'package:pull_to_refresh/pull_to_refresh.dart';


RefreshController _refreshController;

initState(){

    super.initState();
    // initialRefresh可以在组件初始化时执行一次刷新操作
    _refreshController = RefreshController(initialRefresh:true);
    // 如果你需要开始就请求一次刷新,1.3.9版本之前要这么做
    /*

        SchedulerBinding.instance.addPostFrameCallback((_) {
            _refreshController.requestRefresh();
           });

     */
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


另外,假如你每个页面的头部和尾部指示器几乎都是一样的情况下,可以考虑使用RefreshConfiguration,使用这个可以减少每次新建页面构造
header和footer的重复性的工作,在RefreshConfiguration子树下的SmartRefresher没有header和footer节点默认会采用IndicatorConfiguration的指示器。
同时,你也可以设置一些全局的属性,比如是否开启自动加载,刷新触发距离,是否自动隐藏尾部指示器当不满足一页。[例子](https://github.com/peng8350/flutter_pulltorefresh/blob/master/example/lib/ui/MainActivity.dart)里有使用到这个

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


## 更多
- [SmartRefresher,RefreshController](refresher_controller.md)
- [自定义指示器](custom_indicator.md)
- [指示器内部属性介绍](indicator_attribute.md)
- [更新日志](CHANGELOG.md)
- [注意地方](notice.md)

## F.A.Q
* <h3>IOS状态栏双击为什么ListView不自动滚动到顶部?</h3>
这个问题经测试不是我封装的失误,当ListView里的controller被替换后,这个问题就会出现,原因大概是Scaffold里的处理操作,请issue flutter。

* <h3>如何兼容NestedScrollView?</h3>
1.3.0提供了一个新属性isNestWrapped来兼容这东西,注意,这个属性打开后,scollController取决于NestScrollView,内部通过PrimaryScrollController.of(context)
来获取scrollController,所以scrollController要放在NestedScrollView里。(1.3.8后isNestWrapped就没必要使用了)

* <h3>为什么使用CuperNavigationBar后(不只这一个情况),顶部或者尾部指示器有空白的地方?</h3>
很大可能是因为SafeArea,。解决方法一般是在SmartRefresher外围套用SafeArea

* <h3>兼容性方面?</h3>
自1.3.0换了一套新的方法去实现指示器，内部指示器实现是通过监听scrollController位置变化来实现的，并没有使用到类如NotificationListener和GestureDector这类可能引起滑动手势冲突的方法，
所以应该可以兼容大多需要利用到手势之间的库。但是，可能不兼容一些库需要改写ScrollPhysics，内部的FrontStyle就很明显需要用到这个。

## 感谢

[SmartRefreshLayout](https://github.com/scwang90/SmartRefreshLayout)


## 开源协议

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