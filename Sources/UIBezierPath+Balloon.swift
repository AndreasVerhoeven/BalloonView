//
//  UIBezierPath+Balloon.swift
//  Scratc
//
//  Created by Andreas Verhoeven on 03/06/2021.
//

import UIKit

extension UIBezierPath {
	/// Creates a UIBezier path that is the balloon. The stem will be outside of the given rectangle.
	public convenience init(balloonWithRect rect: CGRect, configuration: BalloonConfiguration) {
		self.init()
		addBalloonEdges(BalloonEdges(for: rect, configuration: configuration))
	}

	public convenience init(balloonInRect rect: CGRect, configuration: BalloonConfiguration) {
		self.init()
		addBalloonEdges(BalloonEdges(for: configuration.rectWithoutStem(rect), configuration: configuration))
	}
}
