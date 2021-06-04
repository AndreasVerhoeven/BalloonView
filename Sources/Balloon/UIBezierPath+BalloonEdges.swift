//
//  BalloonPath.swift
//  Scratc
//
//  Created by Andreas Verhoeven on 30/05/2021.
//

import UIKit

extension UIBezierPath {
	func addBalloonEdge(_ edge: BalloonEdge) {
		addArc(edge.startSegment.roundRectCorner)
		addStraightLine(to: edge.startSegment.stemCorner.start)
		addSmoothCorner(edge.startSegment.stemCorner)
		addStraightLine(to: edge.startSegment.stemEdgeEndPoint)
		addQuadCurve(to: edge.endSegment.stemEdgeEndPoint, controlPoint: edge.stemTipPoint)
		addStraightLine(to: edge.endSegment.stemCorner.start)
		addSmoothCorner(edge.endSegment.stemCorner)
		addStraightLine(to: edge.endSegment.roundRectCorner.start.point)

	}

	func addBalloonEdges(_ edges: BalloonEdges) {
		move(to: edges.bottom.startSegment.roundRectCorner.start.point)
		addBalloonEdge(edges.bottom)
		addBalloonEdge(edges.right)
		addBalloonEdge(edges.top)
		addBalloonEdge(edges.left)
		close()
	}

	func addArc(_ arc: BalloonEdge.Segment.Arc) {

		//addArc(withCenter: arc.center, radius: arc.radius, startAngle: arc.start.angle, endAngle: arc.end.angle, clockwise: false)

		// we use a bezier curve as arc, because a regular arc cannot be animated correctly, sadly.

		addBezierArc(center: arc.center, end: arc.end.point)
	}

	func addStraightLine(to: CGPoint) {
		let mid = CGPoint(x: currentPoint.x + (to.x - currentPoint.x) * 0.5,
						  y: currentPoint.y + (to.y - currentPoint.y) * 0.5)
		addCurve(to: to, controlPoint1: mid, controlPoint2: mid)
	}

	func addSmoothCorner(_ corner: BalloonEdge.Segment.SmoothCorner) {
		addCurve(to: corner.end, controlPoint1: corner.controlPoint1, controlPoint2: corner.controlPoint2)
	}

	func addBezierArc(center: CGPoint, start: CGPoint, end: CGPoint) {
		if start.isAlmostEqual(to: end) || center.isAlmostEqual(to: start) {
			return addCurve(to: start, controlPoint1: start, controlPoint2: start)
		}

		let ax = start.x - center.x
		let ay = start.y - center.y
		let bx = end.x - center.x
		let by = end.y - center.y
		let q1 = (ax * ax) + (ay * ay)
		let q2 = q1 + (ax * bx) + (ay * by)
		let k2 = 4 / 3 * (sqrt(2 * q1 * q2) - q2) / ((ax * by) - (ay * bx))
		if k2.isInfinite {
			return addCurve(to: start, controlPoint1: start, controlPoint2: start)
		}
		let control1 = CGPoint(x: center.x + ax - (k2 * ay), y: center.y + ay + (k2 * ax))
		let control2 = CGPoint(x: center.x + bx + (k2 * by), y: center.y + by - (k2 * bx))
		addCurve(to: end, controlPoint1: control1, controlPoint2: control2)
	}

	func addBezierArc(center: CGPoint, end: CGPoint) {
		addBezierArc(center: center, start: currentPoint, end: end)
	}
}
