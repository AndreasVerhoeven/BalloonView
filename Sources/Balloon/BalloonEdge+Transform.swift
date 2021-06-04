//
//  BalloonEdge+Transform.swift
//  Scratc
//
//  Created by Andreas Verhoeven on 03/06/2021.
//

import UIKit

extension CGPoint {
	func mirrored(in rect: CGRect) -> Self {
		let mid = rect.minX + (rect.width * 0.5)
		return CGPoint(x: -(x - mid) + mid, y: y)
	}

	func rotated(in rect: CGRect, angle: CGFloat) -> Self {
		let mid = CGPoint(x: rect.minX + rect.width * 0.5, y: rect.minY + rect.height * 0.5)
		return applying(CGAffineTransform(translationX: mid.x, y: mid.y).rotated(by: angle).translatedBy(x: -mid.x, y: -mid.y))
	}
}

extension CGRect {
	func rotated(angle: CGFloat) -> Self {
		let mid = CGPoint(x: minX + width * 0.5, y: minY + height * 0.5)
		return applying(CGAffineTransform(translationX: mid.x, y: mid.y).rotated(by: angle).translatedBy(x: -mid.x, y: -mid.y))
	}
}

extension BalloonConfiguration {
	func mirror(for rect: CGRect) -> Self {
		var item = self
		item.stem.offset *= -1
		return item
	}

	func rotated(for rect: CGRect, angle: CGFloat) -> Self {
		var item = self
		item.stem.size = CGRect(origin: .zero, size: item.stem.size).applying(CGAffineTransform(rotationAngle: angle)).size
		if angle >= 0 && angle < .pi {
			item.stem.offset = stem.offset
		} else {
			item.stem.offset = -stem.offset
		}
		item.stem.cornerSmoothening = stem.cornerSmoothening.rotated(for: rect, angle: angle)
		return item
	}

	func adjustedForEdge(_ edge: BalloonConfiguration.Edge) -> Self {
		var item = self
		if item.stem.edge != edge {
			item.stem.tipSmoothenWidth = 0
			item.stem.cornerSmoothening = .disabled
			item.stem.offset = 0
			item.stem.size = .zero
		}
		return item
	}
}

extension BalloonConfiguration.StemConfiguration.CornerSmoothening {
	func rotated(for rect: CGRect, angle: CGFloat) -> Self {
		switch self {
			case .custom(let widthRatio, let heightRatio):
				let ratioRect = CGRect(x: 0, y: 0, width: widthRatio, height: heightRatio).rotated(angle: angle)
				return .custom(widthRatio: ratioRect.size.width, heightRatio: ratioRect.size.height)
		}
	}
}


extension BalloonConfiguration.Edge {
	var rotation: CGFloat {
		switch self {
			case .bottom: return 0
			case .left: return .pi * 0.5
			case .top: return .pi
			case .right: return .pi * 1.5
		}
	}
}

extension BalloonEdge.Segment {
	func mirrored(in rect: CGRect) -> Self {
		var item = self
		item.roundRectCorner = item.roundRectCorner.mirrored(in: rect)
		item.stemCorner = item.stemCorner.mirrored(in: rect)
		item.stemEdgeEndPoint = item.stemEdgeEndPoint.mirrored(in: rect)
		item.stemTipPoint = item.stemTipPoint.mirrored(in: rect)
		return item
	}

	func rotated(in rect: CGRect, angle: CGFloat) -> Self {
		var item = self
		item.roundRectCorner = item.roundRectCorner.rotated(in: rect, angle: angle)
		item.stemCorner = item.stemCorner.rotated(in: rect, angle: angle)
		item.stemEdgeEndPoint = item.stemEdgeEndPoint.rotated(in: rect, angle: angle)
		item.stemTipPoint = item.stemTipPoint.rotated(in: rect, angle: angle)
		return item
	}
}

extension BalloonEdge.Segment.SmoothCorner {
	func mirrored(in rect: CGRect) -> Self {
		var item = self
		item.start = end.mirrored(in: rect)
		item.end = start.mirrored(in: rect)
		item.controlPoint1 = controlPoint2.mirrored(in: rect)
		item.controlPoint2 = controlPoint1.mirrored(in: rect)
		return item
	}

	func rotated(in rect: CGRect, angle: CGFloat) -> Self {
		var item = self
		item.start = start.rotated(in: rect, angle: angle)
		item.end = end.rotated(in: rect, angle: angle)
		item.controlPoint1 = controlPoint1.rotated(in: rect, angle: angle)
		item.controlPoint2 = controlPoint2.rotated(in: rect, angle: angle)
		return item
	}
}

extension BalloonEdge.Segment.Arc {
	func mirrored(in rect: CGRect) -> Self {
		var item = self
		item.center = item.center.mirrored(in: rect)
		item.start = end.mirrored(in: rect)
		item.end = start.mirrored(in: rect)
		return item
	}

	func rotated(in rect: CGRect, angle: CGFloat) -> Self {
		var item = self
		item.center = item.center.rotated(in: rect, angle: angle)
		item.start = start.rotated(in: rect, angle: angle)
		item.end = end.rotated(in: rect, angle: angle)
		return item
	}
}

extension BalloonEdge.Segment.Arc.ArcPoint {

	init(angle: CGFloat, radius: CGFloat, center: CGPoint) {
		let point = CGPoint(x: center.x + asin(angle) + radius, y: center.y + acos(angle) + radius)
		self.init(point: point, angle: angle)
	}

	func mirrored(in rect: CGRect) -> Self {
		var item = self
		item.point = item.point.mirrored(in: rect)
		item.angle = (item.angle + .pi).truncatingRemainder(dividingBy: .pi)
		return item
	}

	func rotated(in rect: CGRect, angle: CGFloat) -> Self {
		var item = self
		item.point = point.rotated(in: rect, angle: angle)
		item.angle = (item.angle + angle)
		return item
	}
}
