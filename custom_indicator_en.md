# About Custom Indicator

## First
Assuming that the indicator function you want to implement is not too complex, you can use CustomHeader or CustomFooter, and use the onOffset Change
 callback in Smart Refresher to complete some simple animations.((1.5.2 add new callback in CustomHeader and customFooter,you can use this to implements complex animation))

```dart
   Widget buildHeader(BuildContext context,RefreshStatus mode){
      .....
   }

   SmartRefresher(
      ...
      header: CustomHeader(builder:buildHeader,
             onOffsetChange:(offset){
                  //do some ani
             }
     ),

      ...
   )

```

## Second


This method may be relatively difficult to say above to achieve is relatively complex, but through this way can better achieve some of the more gorgeous animation.
First, the head indicator (drop-down refresh) has four styles: Follow, UnFollow, Behind, Front, and the bottom indicator (load more) has only one style: Follow
Let's first understand the difference between these four styles.

* Follow: Height will not change, but position moves as the list moves.
* UnFollow: Height does not change, location does not change, but does not follow the list, when it is fully visible, will not follow the list.
* Behind:Height will vary with the distance across the boundary and will not move.
* Front: Unlike the previous three mechanisms, height and position will not change. It's stuck at the top of the list.


First,header Indicator need to extend RefreshIndicator,footer Indicator need to extend LoadIndicator,At the same time, the State has been encapsulated internally((RefreshIndicatorState,LoadIndicatorState)。)
Here, you don't need to worry about the following questions: how to monitor the offset changes of the indicator, how to get the indicator into a certain state, and how to decide whether to enter a refresh state based on offset?
How to promulgate the refresh state change logic? You don't need to care about these problems, because I have dealt with them internally. You only need to care about the following things:
What layout to return to in different states, how to set the progress of some animations according to offset changes, what operations to perform before entering refresh state, and so on.
Let's take a simple indicator as an example, so that we can better understand how to design an indicator.
Now, suppose we want to implement an indicator like this, as follows:

![](arts/custom_header.gif)

When dragging, change the size of the picture as offset changes, and then after refreshing, call a moving picture to form the effect of running past.
So, the question arises, how should we achieve such a function?
First of all, I prepared a JPG and a gif. JPG represents the first frame of gif. Of course, if you want to control gif, there is a way. A GIF is enough.
Define a class to inherit RefreshIndicator (note the material package rename)

```dart

class RunningHeader extends RefreshIndicator {
  RunningHeader({@required OnRefresh onRefresh})
      : super(
            refreshStyle: RefreshStyle.Follow,
            height: 80.0,
            onRefresh: onRefresh);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return RunningHeaderState();
  }
}

```
As mentioned above, RefreshIndicator has specific attributes, you can see [here](indicator_attribute.md), and you can specify the style of the indicator by using super (refreshStyle:), because here I think
Follow is more suitable, so I chose Follow.

Next, Running Header State is the key part, which inherits from Refresh Indicator State rather than State. There is a built Content method that must be rewritten inside to specify what the indicator will display, which I believe most people can understand, let alone go into details.
The first step is how to zoom in and out in the process of dragging gestures. Scale Transition must be used to zoom in and out. Then the problem arises again. How can I know the current offset?
There's an onOffsetChange callback method inside, which triggers at any time. If you don't want to trigger during refresh or when the layout is floating, you can use the floating property, which is
Attributes indicate whether the indicator occupies a high state. If it occupies a high state, it can be seen. If it does not, it rolls back and hides.

```dart

class RunningHeaderState extends RefreshIndicatorState<RunningHeader>
    with TickerProviderStateMixin {

    AnimationController _scaleAnimation;

    void onOffsetChange(){
         if (!floating) {
              _scaleAnimation.value = offset / 80.0;
            }
         //call super,will call setState
         super.onOffsetChange(offset);
    }
    Widget buildContent(BuildContext context, RefreshStatus mode){
        return ScaleTransition(
                child: (mode != RefreshStatus.idle || mode != RefreshStatus.canRefresh)
                    ? Image.asset("images/custom_2.gif")
                    : Image.asset("images/custom_1.jpg"),
                scale: _scaleAnimation,
        );
    }

}


```

The second step is what happens when the refresh is complete. This requires the endRefresh method, which returns to a Future. Note that this method call is in RefreshStatus. completed or failed state
Then when this method is finished, floating = false, the header starts to hide.

```dart

    @override
    Future<void> endRefresh() {
      // TODO: implement endRefresh
      return _offsetController.animateTo(1.0).whenComplete(() {});
    }


  Widget buildContent(BuildContext context, RefreshStatus mode) {
    // TODO: implement buildContent
    return SlideTransition(
      child: ScaleTransition(
        child: (mode != RefreshStatus.idle || mode != RefreshStatus.canRefresh)
            ? Image.asset("images/custom_2.gif")
            : Image.asset("images/custom_1.jpg"),
        scale: _scaleAnimation,
      ),
      position: offsetTween.animate(_offsetController),
    );
  }

```

So far, the indicator is almost complete. But one more step is that your animations have to be restored to their original position, and you can't stay there. The next time the user drops down and refreshes, it may still be that state value.
So what should we do here? There is no specific method inside, but you can restore the status of RefreshStatus to idle, and then restore the value in the controller, which exposes a resetValue method.

```dart

  @override
  void resetValue() {
    // TODO: implement handleModeChange
      _scaleAnimation.value = 0.0;
      _offsetController.value = 0.0;
  }

```

This header is not included in packages, because most people don't use it, just as an example.。[Code](example/lib/other/RunningHeader.dart)


 the most important api in RefreshIndicatorState

```dart
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

   // When the indicator status changes, it calls back
   void onModeChange(RefreshStatus mode);

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


## Third(support after 1.5.2,recommended!)

1.5.2 converts footer and header to Widget restriction type, which has the advantage of making it easier to combine indicators. This design is more in line with flutter's design rules than returning a function
We can encapsulate CustomHeader in a StatelessWidget and StatefulWidget. When we need to combine other components, we can use the callback function up, refer to BeizerHeader.
You can also combine Classic Header and TwoLevel Header based on Classic Header.

```dart

    class XXXXHeader extends StatelessWidget{

       Widget build(){

           return CustomHeader(
                ....
           );
       }

    }


```
