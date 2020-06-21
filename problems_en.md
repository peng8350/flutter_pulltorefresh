1.  <h3>How to monitor the location change of ScrollView? it mean I need to use ScrollController.addListener?</h3>
set controller to the child(ScrollView) attribute 

2.  <h3>What is the purpose of position and scroll Contorller exposed in RefreshController?</h3>
First of all, scrollController is a pre-existing api. When it was changed later, it was found that scrollController had a share problem, so it was abandoned and was not intended to be deleted.
Maybe some people quote it, deleting it will cause some people having problems. The main reason for exposing these two things is that in some cases, addListener is not needed, but only needed.
Control the jump. For example, when I implement a chat list, I just need to control ScrollView to scroll to the bottom, but I don't need to monitor its location.

3.  <h3>throw error,with a hit text"Horizontal viewport was given unbounded height.",How to solve?</h3>
If you have this error message, it's usually because there's no limit on the height of the child. For example, PageView, you can't put it in the child directly. You need to give PageView a limit on the height.

4.  <h3>I have a need to disable pull-up loading when I don't have a screen, but I don't know how to calculate the height in ScrollView. Each item has a different height. How to solve it?</h3>
In RefreshConfiguration, there is an attribute hideFooterWhenNotFull, which in most cases can help you calculate and determine whether or not to hide.

5.  <h3>Does the indicator support custom frame animation? For example, I want to change the GIF schedule with drag-and-drop, reach a certain state and start cycling.</h3>
Now this question has been solved ,check out this [plugin](https://github.com/peng8350/flutter_gifimage),can help you controll gif progress,and [example](example/lib/ui/example/customindicator/gif_indicator_example1.dart) is here

6.  <h3>What is the relationship between the values of three variables in Spring Decription and how to use these values to achieve the rebound effect I want?</h3>
This question suggests that you look up the API in flutter, and you need to understand a certain amount of physics and mathematics. Actually, I don't know how to calculate it.

7.  <h3>Under Android, footer uses ShowAlways style. What if I don't want it to bounce back?</h3>
RefreshConfiguration have a contribute maxUnderScrollExtent,0.0 indicate no rebound

8.  <h3>I want to start loading data half way from the screen. How do I set it up?</h3>
RefreshConfigurationhave a contribute footerTriggerDistance,you can use MediaContent or LayoutBuilder compute screen height

9. <h3>IOS Status Bar Double-click Why ListView does not automatically scroll to the top?</h3>
the one,You give ScrollController to the child, so it's not PrimaryScrollController in Scaffold, so it doesn't jump.
The second possibility is that your external Scaffold is not your ancestry Scaffold.

10. <h3>Why is it that after using Cuper Navigation Bar (and not just this case), part of the list header is obscured?</h3>
Because I use CustomScrollView internally, and CustomScrollView doesn't inject padding like BoxScrollView does, so you need to inject padding or SafeArea yourself.

11. <h3>Compatiable?</h3>
1.3.0 replaces a new method to implement the indicator. The internal indicator is implemented by monitoring scroll Controller position changes. There are no methods such as NotificationListener and GestureDector that may cause sliding gesture conflicts.
So it should be compatible with most of the libraries that need to be used between gestures. However, some libraries may not be compatible and ScrollPhysics needs to be rewritten, which is clearly required for internal FrontStyle.

12.  <h3>I have a requirement that when footer is in a state where there is no more data, I want it to follow the end of the content and the other states remain at the bottom. Is that possible?</h3>
RefreshConfiguration's shouldFooterFollowWhenNotFull can solve

13.  <h3>Why not compatible with SingleChildView?</h3>
Because SingleChildView uses SingleChild as its internal Viewport, while other Viewports are basically MultipleChild, so I can't get sliver from its Viewport internally.
You can't add header and footer. just put it into SmartRefresher's child instead.

14. Why can't dragging to the maximum distance trigger refresh? Why load more without triggering?
This kind of problem usually occurs on Android systems, mostly because maxOverScrollExtent and maxUnderScrollExtent limit the height of the maximum drag. You need to make sure that it is larger than triggerDistance because it's internal.
Not automatically identifying and judging for you

15.Why performance become more and more slow with the large amount of data?
this situation is mostly because the setting shrinkWrap=true and physic:NeverScrollPhysics,ScrollView must be as SmartRefresher's child。

