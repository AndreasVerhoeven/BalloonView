//
//  BalloonEdges.swift
//  Scratc
//
//  Created by Andreas Verhoeven on 03/06/2021.
//

import UIKit

/// This models all the edges of a balloon
struct BalloonEdges {
	var bottom: BalloonEdge
	var left: BalloonEdge
	var top: BalloonEdge
	var right: BalloonEdge

	init(for rect: CGRect, configuration: BalloonConfiguration) {
		bottom = BalloonEdge.forEdge(.bottom, for: rect, configuration: configuration)
		left = BalloonEdge.forEdge(.left, for: rect, configuration: configuration)
		top = BalloonEdge.forEdge(.top, for: rect, configuration: configuration)
		right = BalloonEdge.forEdge(.right, for: rect, configuration: configuration)

		// make sure that the corners of the edge with the stem override other corners,
		// since they can be less than 90 degrees.
		switch configuration.stem.edge {
			case .bottom:
				left.endSegment.roundRectCorner = bottom.startSegment.roundRectCorner
				right.startSegment.roundRectCorner = bottom.endSegment.roundRectCorner
				
			case .left:
				top.endSegment.roundRectCorner = left.startSegment.roundRectCorner
				bottom.startSegment.roundRectCorner = left.endSegment.roundRectCorner

			case .top:
				right.endSegment.roundRectCorner = top.startSegment.roundRectCorner
				left.startSegment.roundRectCorner = top.endSegment.roundRectCorner

			case .right:
				bottom.endSegment.roundRectCorner = right.startSegment.roundRectCorner
				top.startSegment.roundRectCorner = right.endSegment.roundRectCorner
		}
	}
}
