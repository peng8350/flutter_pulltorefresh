# Pulltorefresh

## Intro
a widget provided to the flutter scroll component drop-down refresh and pull up load.


## Features
* pull up and pull down
* It's almost fit for all witgets,like GridView,ListView,Container,Text...
* High extensibility
* smart and flexible

## How to use?
this is an example:

```
    new SmartRefresher(
            enablePulldownRefresh: true,
            enablePullUpLoad: true,
            headerBuilder: _buildHeader,
            refreshing: this.refreshing,
            headerHeight: 100.0,
            topVisibleRange: 100.0,
            loading: this.loading,
            child: new Container(
              //this is you content view
              child: new ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemExtent: 40.0,
                  children: _getDatas()
              ),
            ),
            onRefresh: _onRefresh,
            onLoadmore: _onLoadMore,
            onOffsetChange: _onOffsetCallback,
          )

```

You should set the indicator according to the different refresh mode.
There are five refresh modes here:idel, startDrag, canRefresh, refreshing, complete,
build footer is the same with that.

```

  Widget _buildHeader(context,mode){
    return new Image.asset("images/animate.gif",height: 100.0,fit: BoxFit.cover,);
  }


```

This refresh state requires you to update yourself in the logic code.

```

  void _onRefresh(){
    setState(() {
      refreshing = true;
    });
    //Simulation of a network request to obtain data
    new Future.delayed(const Duration(milliseconds: 2000),(){
      setState(() {
        refreshing = false;
      });
      print("Refreshed!!!");
    });

  }
  
```
* If your content view is a rolling component, such as ScrollView, ListView, GridView and so on, you assign these two attributes to the component.Because my parts are used in the ListView nested package

```
new ListView(){
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    child:...
}

```


## Attention point


* You should set the same indictor height for headerHeight and footerHeight.

```

/**

    the height is your headerContainer height
    Why do you want to set it this way?
    Look at the Exist problem.
*/


headerHeight:50.0,
footerHeight:50.0,


```

## Existing problems

* I don't know how to calculate the height of the subcomponents
 ahead of time in the build method, for example: I want to get
 the height of the head indicator. I've been looking for a
  long time on the Google. I don't know how to solve this
  problem. If you have an idea, you can mention issue or pr.
 So I had better choose to pass in a value to the component,
 but increase the complexity.
 
* When the content View is less than the outside container, 
 I don't know how to hide it when the View is loaded, because there is no construction complete callback method that can let me hide, or how I should get the height of the content View before the construction method.