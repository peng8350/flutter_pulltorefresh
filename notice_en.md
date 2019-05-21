# Notice

## RefreshController
* Remember to dispose RefreshController in widget dispose callback,Otherwise, when you refresh, the component is destroyed and the refresh happens to be finished, the null pointer warning will be reported.
* Perform refresh and load operations in initState initialization. Don't call it directly in initState, wait for the interface render  complete before calling it.
,Use SchedulerBinding.instance.addPostFrameCallback

## SmartRefresher
* child only support ListView,GridView,CustomView,This means that inheriting ScrollView is all right.When you want to put a single NON-SCROLLING view, use ListView.。
* When you want to turn off drop-down and pull-up functions, you can use enablePullUp and enablePullDown attributes
* When developing an iOS device, apply SafeArea externally to avoid automatic iOS injection into Sliver Padding.

## Front RefreshStyle
* This style is somewhat different from the implementation mechanism of Behind,Follow,UnFollow,Follow Implementation of Modification Based on ClampScrollPhysics
,Behind, Follow, UnFollow are three resilient sliding engines based on iOS。Front works for Android a little more.



* This is very important. After using Front style, the initial offset of the list is 100.0, which will bounce back between 0 and 100. So when calculating the offset of scrollController,
 you need to subtract the height of the indicator (100), which is the real offset in the list.Similarly, when you scroll to the top, animateTo (100.0), not animateTo (0.0).


## Behind RefreshStyle
* In fact, the realization of this style is realized by the dynamic change of height. Try to use Align attributes more in the periphery, and there will be different sliding effects.
* It has been found that this style does not support Icon as a widget, i.e. Classial Header. It does not support Icon. Using this indicator,
you will find that Icon will be suspended in the attempt area for reasons I have not found out yet.

## NestedScrollView
* Use isNested Wrapped to take effect
* RefreshStyle. Front is temporarily incompatible due to design problems. Try using CustomScrollView to see if it can be implemented.
* ScrollController need to be placed in NestedScrollView,there is not work just placed in "child"。
* How to get the inner scrollController? by using refreshController.scrollController get the inner


## CustomScrollView
* For UnFollow refresh style, when you slivers first element with Sliver Appbar, Sliver Rheader, there will be a very strange phenomenon, do not know how to describe, that is,
 the location of Sliver AppBar will change with the position of the indicator. In this case, you can try adding SliverToBox Adapter to the first element of slivers.