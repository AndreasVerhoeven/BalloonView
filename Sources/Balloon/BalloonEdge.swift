//
//  BalloonEdge.swift
//  Scratc
//
//  Created by Andreas Verhoeven on 03/06/2021.
//

import UIKit

/// This models a single edge of our balloon by describing all
/// the points where path drawing should happen.
///
/// If this edge doesn't have the stem extended, all those
/// points will describe a flat line essentially.
struct BalloonEdge: Equatable {
	/// A balloon edge is made up of two segments:
	///	  - the first corner to the top of the stem
	///	  - (then the tip)
	///	  - the tip of the stem to the last corner
	///
	/// A path is drawn as follows:
	/// 	- round rect corner arc
	/// 	- straight line until the stem corner
	///		- "smooth" stem corner
	///		- straight line of the stem edge until the tip start
	///		- tip arc to the tip end
	///		- straight line of the other stem edge until the start of the "smooth" stem corner
	///		- "smooth" stem corner
	///		- straight line until the final round rect corner arc
	///		- final round rect corner arc
	///
	/// As you can see, the description is mirrored around the stem, so we could
	/// do all the end calculation just like the start and then mirror the results to get the end,
	/// which results in less logic.
	struct Segment: Equatable {
		/// describes an arc
		struct Arc: Equatable {
			/// describes a point on an arc
			struct ArcPoint: Equatable {
				var point: CGPoint
				var angle: CGFloat
			}

			var center: CGPoint
			var radius: CGFloat
			var start: ArcPoint
			var end: ArcPoint
		}

		/// describes a smooth corner:
		/// the start and end points and the control points
		/// to smoothen the corner line
		struct SmoothCorner: Equatable {
			var start: CGPoint
			var end: CGPoint
			var controlPoint1: CGPoint
			var controlPoint2: CGPoint
		}


		var roundRectCorner: Arc
		var stemCorner: SmoothCorner
		var stemEdgeEndPoint: CGPoint
		var stemTipPoint: CGPoint
	}

	var startSegment: Segment
	var stemTipPoint: CGPoint
	var endSegment: Segment
}

extension BalloonEdge {
	/// this creates a BalloonEdge for the specified edge and the specified configuration.
	///
	/// This method works by rotating the rect and configuration to the bottom edge,
	/// doing the math for the bottom edge and then rotating it back to the right edge.
	///
	/// Also, if the configuration doesn't have a stem for the given edge, we'll flatten the stem for the configuration
	/// temporarily
	static func forEdge(_ edge: BalloonConfiguration.Edge, for rect: CGRect, configuration: BalloonConfiguration) -> Self {
		let angle = edge.rotation
		let rotatedRect = rect.rotated(angle: -angle)
		let rotatedConfiguration = configuration.rotated(for: rect, angle: -angle).adjustedForEdge(edge)

		// an edge is made up of our start segment and the end segment, which we combine
		let startSegment = Segment.bottomLeft(for: rotatedRect, configuration: rotatedConfiguration).rotated(in: rect, angle: angle)
		let endSegment = Segment.bottomRight(for: rotatedRect, configuration: rotatedConfiguration).rotated(in: rect, angle: angle)

		return Self(startSegment: startSegment, stemTipPoint: startSegment.stemTipPoint, endSegment: endSegment)
	}
}
