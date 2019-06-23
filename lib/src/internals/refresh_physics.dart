/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-02 14:39
 */

import 'package:flutter/widgets.dart';
import 'dart:math' as math;

/*
 only support three parent physics:
 1. AlwaysScroll
 2.Clamping
 3.Bouncing 
 */
class RefreshPhysics extends ScrollPhysics {
  final double maxOverScrollExtent;
  final double maxUnderScrollExtent;
  final bool clamping;

  /// Creates scroll physics that bounce back from the edge.
  RefreshPhysics(
      {ScrollPhysics parent,
      this.clamping: false,
      double maxUnderScrollExtent,
      double maxOverScrollExtent})
      : maxOverScrollExtent = maxOverScrollExtent ?? double.infinity,
        maxUnderScrollExtent = maxUnderScrollExtent ??
            (!clamping
                ? double.infinity
                : 0.0),
        super(parent: parent);

  @override
  RefreshPhysics applyTo(ScrollPhysics ancestor) {
    return RefreshPhysics(
        parent: buildParent(ancestor),
        clamping: clamping,
        maxUnderScrollExtent: maxUnderScrollExtent,
        maxOverScrollExtent: maxOverScrollExtent);
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    // TODO: implement shouldAcceptUserOffset
    return true;
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // TODO: implement applyPhysicsToUserOffset
    if (position.outOfRange) {
      assert(offset != 0.0);
      assert(position.minScrollExtent <= position.maxScrollExtent);

      final double overscrollPastStart =
          math.max(position.minScrollExtent - position.pixels, 0.0);
      final double overscrollPastEnd =
          math.max(position.pixels - position.maxScrollExtent, 0.0);
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
