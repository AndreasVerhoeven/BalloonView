//
//  Circle.swift
//  Scratc
//
//  Created by Andreas Verhoeven on 30/05/2021.
//

import UIKit

public struct Circle {
	public var point: CGPoint
	public var radius: CGFloat
}

extension Circle: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(point.x)
		hasher.combine(point.y)
		hasher.combine(radius)
	}
}
