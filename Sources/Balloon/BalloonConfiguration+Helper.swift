//
//  BalloonConfiguration+Helper.swift
//  Scratc
//
//  Created by Andreas Verhoeven on 03/06/2021.
//

import UIKit

extension BalloonConfiguration.CornerRadius {
	internal func width(for rect: CGRect) -> CGFloat {
		let radius: CGFloat
		switch self {
			case .oval: radius = rect.height * 0.5
			case .fixed(let value): radius = value
		}

		return min(rect.width * 0.5, min(rect.height * 0.5, radius))
	}
}

extension BalloonConfiguration.StemConfiguration {
	internal  func stemSizeAndCornerSmootheningSize(for rect: CGRect) -> (CGSize, CGSize) {
		let stemSize = CGSize(width: min(rect.width, size.width), height: size.height)

		let wantedCornerSmootheningSize = cornerSmootheningSize(for: stemSize)
		let cornerSmootheningSize = CGSize(width: max(0, min(rect.width - stemSize.width, wantedCornerSmootheningSize.width)), height: wantedCornerSmootheningSize.height)
		return(stemSize, cornerSmootheningSize)
	}

	internal  func cornerSmootheningSize(for stemSize: CGSize) -> CGSize {
		switch cornerSmoothening {
			case .custom(let widthRatio, let heightRatio):
				return CGSize(width: stemSize.width * widthRatio, height: stemSize.height * heightRatio)
		}
	}
}
