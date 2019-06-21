/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-02 14:39
 */

import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/*
  use to add other scroll effect
  only support three common physics:
  1.  AlwaysScrollPhysics(default),
  2. ClampedScrollPhysics,
  3. BouncingScrollPhysics
*/

class RefreshPhysics extends ScrollPhysics {

  bool _clamped = false;

  RefreshPhysics({ScrollPhysics parent}) : super(parent: parent);


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
    // if createBallisticSimulation() return ClampingScrollSimulation,it should be stopped before scrollView bounce out of visual area
    if(_clamped) {
      if (value < position.minScrollExtent &&
          position.minScrollExtent < position.pixels) { // hit top edge
        return value - position.minScrollExtent;
      }
      if (position.pixels < position.maxScrollExtent &&
          position.maxScrollExtent < value) // hit bottom edge
        return value - position.maxScrollExtent;
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
    Simulation parentSimulation = super.createBallisticSimulation(position, velocity);

    _clamped =  parentSimulation is ClampingScrollSimulation;
    return parentSimulation;
  }

}

