# Notice

## RefreshController
* Remember to dispose RefreshController in widget dispose callback,Otherwise, when you refresh, the component is destroyed and the refresh happens to be finished, the null pointer warning will be reported.

## SmartRefresher
* child only support ListView,GridView,CustomView,This means that inheriting ScrollView is all right.When you want to put a single NON-SCROLLING view, use ListView.。
* When you want to turn off drop-down and pull-up functions, you can use enablePullUp and enablePullDown attributes
* When child does not inherit ScrollView, note that box constraints are unbounded in height under Smart Refresher
* SingleChildScrollView is not extends ScrollView,remember not to use this in child attribute,Doing so is just nesting ScrollView in ScrollView
* When you want to add background to ScrollView, remember not to wrap Container for ListView or GridView at the child node, wrap Container outside Smart Refresher


## Behind RefreshStyle
* In fact, the realization of this style is realized by the dynamic change of height. Try to use Align attributes more in the periphery, and there will be different sliding effects.
* It has been found that this style does not support Icon as a widget, i.e. Classial Header. It does not support Icon. Using this indicator,
you will find that Icon will be suspended in the attempt area for reasons I have not found out yet.

## footer indicator
* For the problem of not satisfying one page hiding, although the internal use of precedingScrollExtent to determine how many distances ahead, but this method is not advisable, there is a case that a sliver only occupies scrollExtent but not scrollExtent.
  The case of layoutExtent. So if your internal slivers have this kind of sliver, my internal judgment is not legitimate, you need to judge manually. Set hideWhenNotFull to false, and then use Boolean values to determine.

## NestedScrollView(Not advice to use unless necessary)
* ScrollController need to be placed in NestedScrollView,there is not work just placed in "child"。
* How to get the inner scrollController? by using refreshController.scrollController get the inner

## CustomScrollView
* For UnFollow refresh style, when you slivers first element with Sliver Appbar, Sliver Rheader, there will be a very strange phenomenon, do not know how to describe, that is,
 the location of Sliver AppBar will change with the position of the indicator. In this case, you can try adding SliverToBox Adapter to the first element of slivers.