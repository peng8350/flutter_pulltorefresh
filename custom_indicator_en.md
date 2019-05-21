# About Custom Indicator

## First
Assuming that the indicator function you want to implement is not too complex, you can use CustomHeader or CustomFooter, and use the onOffset Change
 callback in Smart Refresher to complete some simple animations.

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

## Second
This method may be relatively difficult to say above to achieve is relatively complex, but through this way can better achieve some of the more gorgeous animation.
First, the header indicator inherits RefreshIndicator, the bottom indicator inherits LoadIndicator, and the state is encapsulated internally.
Here's an example

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
            refreshStyle: RefreshStyle.UnFollow,//Specify the style of the refresh indicator
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

 the most important api in RefreshIndicatorState

```
   /*
  	Represents whether the indicator has a layout height. If it occupies a height, the indicator will be displayed at the top.
  	If not, the indicator will scroll back and hide.
    */
   bool floating;
   // the state of RefreshIndicator
   RefreshStatus mode;


   /*
       The parameter in this method returns a value representing the distance visible to the indicator or the distance across the top of the ScrollView.
       You can use this method to achieve some beautiful drag animation. For example, the effect of droplet dragging in WaterDropHeader.
       It depends on this function. Finally, the onOffsetChange of the parent class is called to update the interface.
   */
   void onOffsetChange(double offset) ;

   /*
     This method represents the operation to be performed when the refresh state is about to enter, and returns a Future. This method cannot be refreshed until it has been called.

    */
  Future<void> readyToRefresh();

  /**
     End the operation when refreshing the status. This method is triggered when the state changes to success or failure.
     When this method is executed, the indicator becomes floating = false
  */
  Future<void> endRefresh();

  // Return different content depending on the RefreshStatus
  Widget buildContent(BuildContext context,RefreshStatus mode);

```


LoadIndicatorState does not expand on the introduction, which is similar to the above.


