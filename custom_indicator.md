# 关于自定义指示器

## 第一种
假设你要实现的指示器功能不是太过于复杂,可以使用CustomHeader或者CustomFooter,利用SmartRefresher里的onOffsetChange回调可完成一些简单的动画。

```
   Widget buildHeader(BuildContext context,RefreshStatus mode){
      .....
   }

   SmartRefresher(
      ...
      header: CustomHeader(builder:buildHeader)
      onOffsetChange:(offset){
        //do some ani
      }
      ...
   )

```

## 第二种
这种方式可能相对上面难说实现起来是相对来说比较复杂的,但通过这种方式可以更好的实现一些比较绚丽的动画。
首先,头部指示器继承RefreshIndicator,底部指示器继承LoadIndicator,同时内部已经封装好State。
下面是一个例子

```
class CustomHeader extends RefreshIndicator {

...

  const ClassicHeader({
    Key key,

    double height: default_height,
    double triggerDistance: default_refresh_triggerDistance,
    ......
   }) : super(
            key: key,
            refreshStyle: RefreshStyle.UnFollow,//指定刷新指示器的风格
            height: height,
            triggerDistance: triggerDistance);

  @override
  State createState() {
    // TODO: implement createState
    return _ClassicHeaderState();
  }
}

class _ClassicHeaderState extends RefreshIndicatorState<ClassicHeader> {


  @override
  Widget buildContent(BuildContext context, RefreshStatus mode) {
    // TODO: implement buildContent
    return Text(mode == RefreshStatus.refreshing?"刷新中":"下拉刷新");
  }
}
```

RefreshIndicatorState里一些非常重要的可重写方法和属性

```
   /*
  		 代表指示器有没有布局的高度,假如占有高度,指示器将会展示在顶部,假如没有,指示器将会滚动回去隐藏掉。
    */
   bool floating;
   //指示器的状态
   RefreshStatus mode;


   /*
     这个方法里的参数返回一个值,代表指示器可见的距离或者ScrollView顶部越界的距离。
     你可以利用这个方法来实现一些漂亮的拖动动画。比如WaterDropHeader里水滴拖动的效果,
     就是要依赖到这个函数。最后,调用父类的onOffsetChange可以更新界面。
   */
   void onOffsetChange(double offset) ;

   /*
     这个方法表示即将进入刷新状态时需要执行的操作,返回一个Future。这个方法调用完毕才能进入刷新状态。

    */
  Future<void> readyToRefresh();

  /**
     结束刷新状态时的操作。这个方法是在状态改变为成功或者失败后触发的。
     这个方法执行完毕后,指示器会变为无布局(floating = false)状态
  */
  Future<void> endRefresh();

  // 根据不同的状态,返回不同的内容
  Widget buildContent(BuildContext context,RefreshStatus mode);

```


LoadIndicatorState就不展开介绍了,和上面同理,只不过上面的比较多。


