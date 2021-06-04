//
//  BalloonConfiguration.swift
//  Scratc
//
//  Created by Andreas Verhoeven on 31/05/2021.
//

import UIKit

/// This defines the properties of a balloon
public struct BalloonConfiguration: Equatable {

	/// the corner radius of the balloon
	public var cornerRadius: CornerRadius = .fixed(8)

	/// the stem configuration
	public var stem: StemConfiguration = StemConfiguration()

	/// the edge at which we show the stem
	public enum Edge {
		/// the stem is at the top edge
		case top

		/// the stem is at the left edge
		case left

		/// the stem is at the bottom edge
		case bottom

		/// the stem is at the right edge
		case right
	}

	/// how the corner radius is rendered
	public enum CornerRadius: Equatable {
		/// use a corner radius that results in an oval
		case oval

		/// use a fixed corner radius
		case fixed(CGFloat)

		/// no corner radius
		static let none: Self = .fixed(0)
	}

	/// how the stem is rendered
	public struct StemConfiguration: Equatable {

		/// how we smooth the stems corners
		public enum CornerSmoothening: Equatable {
			///  corner smoothing uses a custom smoothening ratio
			/// of the width/height
			case custom(widthRatio: CGFloat, heightRatio: CGFloat)

			/// corner smoothing is disabled
			static let disabled: Self = .custom(widthRatio: 0, heightRatio: 0)

			/// corner smoothing is enabled
			static let enabled: Self = .custom(widthRatio: 0.3, heightRatio: 0.25)
		}

		/// which edge to add the stem too
		public var edge: Edge = .bottom

		/// offset from the center
		public var offset: CGFloat = 0

		/// the size of the stem
		public var size = CGSize(width: 40, height: 40)

		/// how much we smoothen the corners
		public var cornerSmoothening: CornerSmoothening = .enabled

		/// how much we smoothen the tip of the stem
		public var tipSmoothenWidth = CGFloat(4)
	}
}


extension BalloonConfiguration {
	/// gets the rect without the stem
	public func rectWithoutStem(_ rect: CGRect) -> CGRect {
		return rect.inset(by: insetsForStem(in: rect))
	}

	/// gets the insets for the stem
	public func insetsForStem(in rect: CGRect) -> UIEdgeInsets {
		let (stemSize, _) = stem.stemSizeAndCornerSmootheningSize(for: rect)
		switch stem.edge {
			case .top:
				return UIEdgeInsets(top: stemSize.height, left: 0, bottom: 0, right: 0)

			case .bottom:
				return UIEdgeInsets(top: 0, left: 0, bottom: stemSize.height, right: 0)

			case .left:
				return UIEdgeInsets(top: 0, left: stemSize.width, bottom: 0, right: 0)

			case .right:
				return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: stemSize.width)
		}
	}

	/// gets the effective corner radius for a rectangle
	public func effectiveCornerRadius(in rect: CGRect) -> CGFloat {
		return cornerRadius.width(for: rectWithoutStem(rect))
	}

	/// gets the effective corner radius for a rectangle with the rectangle not taken the stem into account
	public func effectiveCornerRadius(with rect: CGRect) -> CGFloat {
		return cornerRadius.width(for: rect)
	}
}
