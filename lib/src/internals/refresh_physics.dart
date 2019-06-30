/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-02 14:39
 */

import 'package:flutter/widgets.dart';
import 'dart:math' as math;

import 'package:pull_to_refresh/pull_to_refresh.dart';

/*
 only support three parent physics:
 1. AlwaysScroll
 2.Clamping
 3.Bouncing 
 */
class RefreshPhysics extends ScrollPhysics {
  final double maxOverScrollExtent, maxUnderScrollExtent;
  final bool enablePullDown, enablePullUp;
  final bool enableScrollWhenTwoLevel;
  final ValueNotifier headerMode, footerMode;
  final bool clamping;

  /// Creates scroll physics that bounce back from the edge.
  RefreshPhysics(
      {ScrollPhysics parent,
      this.clamping: false,
      double maxUnderScrollExtent,
      this.headerMode,
      this.footerMode,
      this.enablePullUp,
      this.enableScrollWhenTwoLevel:false,
      this.enablePullDown,
      double maxOverScrollExtent})
      : maxOverScrollExtent = maxOverScrollExtent ?? double.infinity,
        maxUnderScrollExtent =
            maxUnderScrollExtent ?? (!clamping ? double.infinity : 0.0),
        super(parent: parent);

  @override
  RefreshPhysics applyTo(ScrollPhysics ancestor) {
    return RefreshPhysics(
        parent: buildParent(ancestor),
        clamping: clamping,
        enablePullDown: enablePullDown,
        enablePullUp: enablePullUp,
        enableScrollWhenTwoLevel: enableScrollWhenTwoLevel,
        headerMode: headerMode,
        footerMode: footerMode,
        maxUnderScrollExtent: maxUnderScrollExtent,
        maxOverScrollExtent: maxOverScrollExtent);
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    // TODO: implement shouldAcceptUserOffset
    print("should");
    return true;
  }

  /*
    It seem that it was odd to do so,but I have no choose to do this for updating the state value(enablePullDown and enablePullUp),
    in Scrollable.dart _shouldUpdatePosition method,it use physics.runtimeType to check if the two physics is the same,this
    will lead to whether the newPhysics should replace oldPhysics,If flutter can provide a method such as "shouldUpdate",
    It can work perfectly.
   */
  @override
  // TODO: implement runtimeType
  Type get runtimeType {
    if (enablePullDown && !enablePullUp) {
      return Container;
    } else if (!enablePullUp && !enablePullDown) {
      return Stack;
    } else if (enablePullUp && !enablePullDown) {
      return Column;
    } else {
      return RefreshPhysics;
    }
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // TODO: implement applyPhysicsToUserOffset
    if ((offset > 0 && !enablePullDown) || (offset < 0 && !enablePullUp)) {
      return parent.applyPhysicsToUserOffset(position, offset);
    }
    if (position.outOfRange||headerMode.value==RefreshStatus.twoLeveling) {

      final double overscrollPastStart =
          math.max(position.minScrollExtent - position.pixels, 0.0);
      final double overscrollPastEnd =
          math.max(position.pixels - 0.0, 0.0);
      final double overscrollPast =
          math.max(overscrollPastStart, overscrollPastEnd);
      final bool easing = (overscrollPastStart > 0.0 && offset < 0.0) ||
          (overscrollPastEnd > 0.0 && offset > 0.0);

      final double friction = easing
          // Apply less resistance when easing the overscroll vs tensioning.
          ? frictionFactor(
              (overscrollPast - offset.abs()) / position.viewportDimension)
          : frictionFactor(overscrollPast / position.viewportDimension);
      final double direction = offset.sign;
      return direction * _applyFriction(overscrollPast, offset.abs(), friction);
    }
    return super.applyPhysicsToUserOffset(position, offset);
  }

  static double _applyFriction(
      double extentOutside, double absDelta, double gamma) {
    assert(absDelta > 0);
    double total = 0.0;
    if (extentOutside > 0) {
      final double deltaToLimit = extentOutside / gamma;
      if (absDelta < deltaToLimit) return absDelta * gamma;
      total += extentOutside;
      absDelta -= deltaToLimit;
    }
    return total + absDelta;
  }

  double frictionFactor(double overscrollFraction) =>
      0.52 * math.pow(1 - overscrollFraction, 2);

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // TODO: implement applyBoundaryConditions
    if ((position.pixels - value > 0 && !enablePullDown) ||
        (position.pixels - value < 0 && !enablePullUp)) {
      return parent.applyBoundaryConditions(position, value);
    }
    final double topBoundary = position.minScrollExtent - maxOverScrollExtent;
    final double bottomBoundary =
        position.maxScrollExtent + maxUnderScrollExtent;
    if (clamping) {
      if (value < position.minScrollExtent &&
          position.minScrollExtent < position.pixels) // hit top edge
        return value - position.minScrollExtent;
      if (position.pixels < position.maxScrollExtent &&
          position.maxScrollExtent < value) // hit bottom edge
        return value - position.maxScrollExtent;
    }
    if (maxOverScrollExtent != double.infinity &&
        value < position.pixels &&
        position.pixels <= topBoundary) // underscroll
      return value - position.pixels;
    if (maxUnderScrollExtent != double.infinity &&
        bottomBoundary <= position.pixels &&
        position.pixels < value) // overscroll
      return value - position.pixels;
    if (maxOverScrollExtent != double.infinity &&
        value < topBoundary &&
        topBoundary < position.pixels) // hit top edge
      return value - topBoundary;
    if (maxUnderScrollExtent != double.infinity &&
        position.pixels < bottomBoundary &&
        bottomBoundary < value) {
      // hit bottom edge
      return value - bottomBoundary;
    }
    return 0.0;
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // TODO: implement createBallisticSimulation
    if ((velocity < 0.0 && !enablePullDown) ||
        (velocity > 0 && !enablePullUp)) {
      return parent.createBallisticSimulation(position, velocity);
    }
    if (position.outOfRange) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        // -1.0 avoid stop springing back ,and release gesture
        velocity: -1.0,
        // TODO(abarth): We should move this constant closer to the drag end.
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: tolerance,
      );
    }
    return super.createBallisticSimulation(position, velocity);
  }
}
