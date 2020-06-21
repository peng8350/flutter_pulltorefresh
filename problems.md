1. <h3>怎么去监听ScrollView的位置变化啊?也就是要用到ScrollController.addListener?</h3>
在child里的scrollView直接设置controller给它即可。

2. <h3>在RefreshController暴露了position和scrollContorller目的是什么?</h3>
首先,scrollController是先前的api就有的,后面改动的时候发现scrollController存在共用的问题,所以就弃用了,不打算删除,
主要是可能有一部分人引用了它,删了就会造成有的人更新报错。而暴露这两个东西,主要是为了在某些情况下,不需要addListener,只需要
控制跳转的情况。比如我实现聊天列表,我只需要控制ScrollView滚动到最下方,但我不需要监听它的位置的情况。

3. <h3>报错,有这个提示"Horizontal viewport was given unbounded height.",如何解决?</h3>
有这个报错提示的话,一般都是因为在child没有限定高度,比如说PageView,你不能直接在child里放进去,你需要给予PageView
一个高度的限制

4. <h3>我有一个需求,需要当不满一个屏幕,就禁用掉上拉加载，但是我不知道怎么计算ScrollView里的高度,每个item高度不一样,如何解决?</h3>
在RefreshConfiguration有提供一个属性hideFooterWhenNotFull,绝大多数的情况,它可以帮你计算并判断是否隐藏。

5. <h3>指示器支持自定义帧动画吗?比如,我想随着下拉拖动改变gif进度,到达某个状态开始循环播放</h3>
这个问题我内部已经有完美的解决方法,需要依赖到我的三方插件来解决控制gif进度的问题,用法详见[这里](https://github.com/peng8350/flutter_gifimage),[例子](example/lib/ui/example/customindicator/gif_indicator_example1.dart)


6. <h3>关于改变回弹动画的问题,SpringDecription里三个变量值是什么关系?怎么利用这三个值达到我要的回弹效果?</h3>
这个问题建议你去查flutter里的api,需要明白一定的物理和数学知识。事实上,我也不知道怎么算

7. <h3>在Android下,footer使用ShowAlways,我不想让它回弹怎么办?</h3>
RefreshConfiguration配置属性maxUnderScrollExtent,自己判断平台然后,0.0代表不回弹

8. <h3>我想在距离屏幕一半就开始加载数据,怎么设置?</h3>
RefreshConfiguration配置属性footerTriggerDistance,屏幕一半你可以借助MediaContent或者LayoutBuilder来计算屏幕高度

9. <h3>IOS状态栏双击为什么ListView不自动滚动到顶部?</h3>
第一种可能,就是你把给予了ScrollController给child,所以不是Scaffold里的PrimaryScrollController,所以不跳转
第二种可能,就是你外部的Scaffold不是你最顶层的Scaffold

10. <h3>为什么使用CuperNavigationBar后(不只这一个情况),上面好像被遮住了一部分</h3>
因为我内部就是采用CustomScrollView来实现的,而CustomScrollView它不像BoxScrollView会帮你注入padding,所以需要你自己注入padding或者使用SafeArea

11. <h3>兼容性方面?</h3>
自1.3.0换了一套新的方法去实现指示器，内部指示器实现是通过监听scrollController位置变化来实现的，并没有使用到类如NotificationListener和GestureDector这类可能引起滑动手势冲突的方法，
所以应该可以兼容大多需要利用到手势之间的库。但是，可能不兼容一些库需要改写ScrollPhysics，内部的FrontStyle就很明显需要用到这个。

12. <h3>我有这样一个需求:当footer为没有更多数据的状态时,我想让它追随内容的尾部,其他状态就一直居于底部,是否可以实现?</h3>
参见RefreshConfiguration里的shouldFooterFollowWhenNotFull，可完美解决。

13. <h3>为什么不兼容SingleChildView?</h3>
因为SingleChildView它内部采用的Viewport是SingleChild,而其他Viewport基本都是MultipleChild,所以我内部是没办法取它的Viewport里的sliver,取了也
不能添加header和footer,直接把child存放在SmartRefresher child里即可,child为非ScrollView,作用等同于SingleChildScrollView

14.为什么拖到最大的距离不能触发刷新?为什么加载更多不触发?
这类问题一般发生在Android系统，绝大数情况是因为maxOverScrollExtent和maxUnderScrollExtent限制了最大拖动的高度问题,你需要确保它要大于triggerDistance,因为内部
没有帮你自动识别判断

15.为什么引用库后,随着数据量大时越来越卡顿?
这种情况绝大多数都是因为开启了shrinkWrap=true和设置physic:NeverScrollPhysics,ScrollView一定要作为SmartRefresher's child,不可分开。
