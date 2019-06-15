/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-02 14:39
 */

import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

class RefreshPhysics extends ScrollPhysics {
  /// Creates scroll physics that bounce back from the edge.
  const RefreshPhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  RefreshPhysics applyTo(ScrollPhysics ancestor) {
    return RefreshPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    // TODO: implement shouldAcceptUserOffset
    return true;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // TODO: implement applyBoundaryConditions
    if(parent is ClampingScrollPhysics) {
      if (value < position.minScrollExtent &&
          position.minScrollExtent < position.pixels) { // hit top edge
        return value - position.minScrollExtent;
      }
      if (position.pixels < position.maxScrollExtent &&
          position.maxScrollExtent < value) // hit bottom edge
        return value - position.maxScrollExtent;
      if (position.maxScrollExtent <= position.pixels && position.pixels < value) // overscroll
        return value - position.pixels;
    }
    return 0.0;
  }

  @override
  Simulation createBallisticSimulation(ScrollMetrics position, double velocity) {
    // TODO: implement createBallisticSimulation
    if(position.outOfRange){
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        // -1.0 avoid stop springing back ,and release gesture
        velocity: -1.0, // TODO(abarth): We should move this constant closer to the drag end.
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: tolerance,
      );
    }
    return super.createBallisticSimulation(position, velocity);
  }

}

