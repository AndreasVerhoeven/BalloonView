//
//  BalloonEdgeSegment.swift
//  Scratc
//
//  Created by Andreas Verhoeven on 03/06/2021.
//

import UIKit

extension BalloonEdge.Segment {
	/// This calculates the left segment (from rounded corner to the stem tip) for the bottom edge.
	///
	/// From this segment, we can calculate the right segment by mirroring and the other edges by rotating.
	///
	/// A segment is made up of:
	/// 	- rounded corner
	/// 	- line to the stem
	/// 	- smooth corner for the stem
	/// 	- the edge of the left stem
	static func bottomLeft(for rect: CGRect, configuration: BalloonConfiguration) -> Self {
		let left = CGPoint(x: rect.minX, y: rect.maxY)

		let cornerRadius = configuration.cornerRadius.width(for: rect)
		let (stemSize, cornerSmootheningSize) = configuration.stem.stemSizeAndCornerSmootheningSize(for: rect)
		let stemOffset = configuration.stem.offset
		let cornerSmootheningWidth = cornerSmootheningSize.width
		let cornerSmootheningHeight = cornerSmootheningSize.height

		let stemMid = min(max(rect.minX + stemSize.width * 0.5 + cornerSmootheningWidth,
							  rect.minX + rect.width * 0.5 + stemOffset),
						  rect.maxX - stemSize.width * 0.5 - cornerSmootheningWidth)

		let stemLeft = stemMid - stemSize.width * 0.5
		//let stemRight = stemMid - stemSize.width * 0.5
		let stemSmoothenedWidth = min(stemSize.width * 0.5, configuration.stem.tipSmoothenWidth)

		let stemTipPoint = CGPoint(x: stemMid, y: left.y + stemSize.height)

		let stemSmoothenedCornerStartX = stemLeft - cornerSmootheningWidth
		let arcCenter = CGPoint(x: left.x + cornerRadius, y: left.y - cornerRadius)

		// figure out how much our corner overlaps with the arc and at what point we overlap
		let arcNonOverlappedWidth = max(0, min(cornerRadius, stemSmoothenedCornerStartX - left.x))
		let arcStartAngle = CGFloat.pi
		let arcEndAngle = cornerRadius != 0 ? acos((arcNonOverlappedWidth - cornerRadius) / cornerRadius) : arcStartAngle

		let arcEndPoint = CGPoint(x: left.x + arcNonOverlappedWidth, y: arcCenter.y - sin(arcEndAngle - arcStartAngle) * cornerRadius)

		let smoothenedCornerStartPoint = CGPoint(x: stemSmoothenedCornerStartX, y: arcEndPoint.y)

		// the point where the left edge would end up if we didn't smoothen the corner
		let stemEdgeStartPoint = CGPoint(x: stemLeft, y: left.y)

		// the lines going from the arc end and the left edge of the stem
		let arcTangentLine = Line(tangentFromPointOnCircle: arcEndPoint, center: arcCenter)
		let stemEdgeLine = Line(from: stemEdgeStartPoint, to: stemTipPoint)
		let stemSlope = stemEdgeLine.slope.valueIfAvailable ?? 0

		// the point where we stop smoothening the corner
		let smoothenedCornerEndPoint = stemEdgeLine.point(forY: stemEdgeStartPoint.y + cornerSmootheningHeight) ?? stemEdgeStartPoint

		/// To smoothly go from one line to another, we can use a bezier curve:
		///  if the first point to the first control point has the same tangent as the the first line
		/// and the second point to the second control point has the same tangent as the second line,
		/// the curve will smoothly change from the first line to the second line.

		// the point where our bezier quad's control point is to smoothly go from the arcTangentLine to the stemEdgeLine slope
		let line = Line(horizontalLineAtY: left.y)
		let stemCornerControlPoint = line.intersectionPoint(with: stemEdgeLine) ?? stemEdgeStartPoint
		let arcCornerControlPoint = line.intersectionPoint(with: arcTangentLine) ?? stemEdgeStartPoint

		let stemEdgeEndPoint = CGPoint(x: stemTipPoint.x - stemSmoothenedWidth * 0.5,
									   y: stemTipPoint.y - stemSmoothenedWidth * 0.5 * stemSlope)

		let roundRectCorner = Arc(center: arcCenter,
								  radius: cornerRadius,
								  start: Arc.ArcPoint(point: CGPoint(x: left.x, y: left.y - cornerRadius), angle: arcStartAngle),
								  end: Arc.ArcPoint(point: arcEndPoint, angle: arcEndAngle))

		let stemCorner = SmoothCorner(start: smoothenedCornerStartPoint,
									  end: smoothenedCornerEndPoint,
									  controlPoint1: arcCornerControlPoint,
									  controlPoint2: stemCornerControlPoint)

		return Self(roundRectCorner: roundRectCorner, stemCorner: stemCorner, stemEdgeEndPoint: stemEdgeEndPoint, stemTipPoint: stemTipPoint)
	}

	static func bottomRight(for rect: CGRect, configuration: BalloonConfiguration) -> Self {
		// calculate for the start, and then flip to the end
		let start =  bottomLeft(for: rect, configuration: configuration.mirror(for: rect))
		return start.mirrored(in: rect)
	}
}
