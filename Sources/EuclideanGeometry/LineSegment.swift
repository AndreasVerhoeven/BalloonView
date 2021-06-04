//
//  LineSegment.swift
//  Scratc
//
//  Created by Andreas Verhoeven on 30/05/2021.
//

import UIKit

public struct LineSegment: Hashable {
	public private(set) var start: CGPoint
	public private(set) var end: CGPoint

	public var line: Line {
		return Line(from: start, to: end)
	}

	public var slope: Slope {
		return Slope(from: start, to: end)
	}

	public init(start: CGPoint, end: CGPoint) {
		// ensure we always have the same order for two given points,
		// so that they compare equally
		if start.y < end.y || (start.y == end.y && start.x <= end.x)  {
			self.start = start
			self.end = end
		} else {
			self.start = end
			self.end = start
		}

		self.start = start
		self.end = end
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(start.x)
		hasher.combine(start.y)

		hasher.combine(end.x)
		hasher.combine(end.y)
	}
}
