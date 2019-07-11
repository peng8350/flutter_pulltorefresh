/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-07-11 12:23
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ExpandedViewport extends Viewport {
  ExpandedViewport({
    Key key,
    AxisDirection axisDirection = AxisDirection.down,
    AxisDirection crossAxisDirection,
    double anchor = 0.0,
    ScrollPosition offset,
    Key center,
    double cacheExtent,
    List<Widget> slivers = const <Widget>[],
  }) : super(
            key: key,
            slivers: slivers,
            axisDirection: axisDirection,
            crossAxisDirection: crossAxisDirection,
            anchor: anchor,
            offset: offset,
            center: center,
            cacheExtent: cacheExtent);

  @override
  RenderViewport createRenderObject(BuildContext context) {
    // TODO: implement createRenderObject
    return _RenderExpandedViewport(
      axisDirection: axisDirection,
      crossAxisDirection: crossAxisDirection ??
          Viewport.getDefaultCrossAxisDirection(context, axisDirection),
      anchor: anchor,
      offset: offset,
      cacheExtent: cacheExtent,
    );
  }
}

class _RenderExpandedViewport extends RenderViewport {
  _RenderExpandedViewport({
    AxisDirection axisDirection = AxisDirection.down,
    @required AxisDirection crossAxisDirection,
    @required ViewportOffset offset,
    double anchor = 0.0,
    List<RenderSliver> children,
    RenderSliver center,
    double cacheExtent,
  }) : super(
            axisDirection: axisDirection,
            crossAxisDirection: crossAxisDirection,
            offset: offset,
            anchor: anchor,
            children: children,
            center: center,
            cacheExtent: cacheExtent);

  @override
  void performLayout() {
    // TODO: implement performLayout
    super.performLayout();

    RenderSliver expandSliver ;
    double totalLayoutExtent = 0.0;
    RenderSliver p = firstChild;
    final double reverseDirectionRemainingPaintExtent = (size.height - offset.pixels).clamp(0.0, size.height);
    while(p!=null){
      if(p is _RenderExpanded){
        expandSliver = p;
      }
      totalLayoutExtent +=p.geometry.layoutExtent;
      p = childAfter(p);
    }

    if(expandSliver!=null&&totalLayoutExtent<size.height) {
      double cha = reverseDirectionRemainingPaintExtent;
      p = lastChild;
      while (p != expandSliver) {
        updateChildLayoutOffset(p,paintOffsetOf(p).dy
            +cha, expandSliver.constraints.growthDirection);
        p = childBefore(p);
      }


    }

  }
}

//tag
class SliverExpanded extends SingleChildRenderObjectWidget{

  SliverExpanded():super(child:Container());


  @override
  RenderSliver createRenderObject(BuildContext context) {
    // TODO: implement createRenderObject
    return _RenderExpanded();
  }
}

class _RenderExpanded extends RenderSliver
    with RenderObjectWithChildMixin<RenderBox>{
  @override
  void performLayout() {
    // TODO: implement performLayout
    geometry=SliverGeometry.zero;
  }

}