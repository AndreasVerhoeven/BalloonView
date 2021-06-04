//
//  BalloonShapeView.swift
//  Scratc
//
//  Created by Andreas Verhoeven on 03/06/2021.
//

import UIKit

/// A view that has a balloon shape
@IBDesignable open class BalloonShapeView: UIView {

	/// The configuration for the balloon
	open var configuration = BalloonConfiguration() {
		didSet {
			guard configuration != oldValue else { return }
			setNeedsLayout()
		}
	}

	/// The color the balloon is filled with
	@IBInspectable open var fillColor: UIColor? {
		didSet {
			updateColors()
		}
	}

	/// The color the balloon is stroked with
	@IBInspectable open var strokeColor: UIColor? {
		didSet {
			updateColors()
		}
	}

	/// same as CAShapeLayer.strokeStart
	@IBInspectable open var strokeStart: CGFloat {
		get {return shapeLayer.strokeStart}
		set {shapeLayer.strokeStart = newValue}
	}

	/// same as CAShapeLayer.strokeEnd
	@IBInspectable open var strokeEnd: CGFloat {
		get {return shapeLayer.strokeEnd}
		set {shapeLayer.strokeEnd = newValue}
	}

	/// The line width of the balloon
	@IBInspectable open var lineWidth: CGFloat {
		get {return shapeLayer.lineWidth}
		set {shapeLayer.lineWidth = newValue}
	}

	/// same as CAShapeLayer.lineDashPhase
	@IBInspectable open var lineDashPhase: CGFloat {
		get {return shapeLayer.lineDashPhase}
		set {shapeLayer.lineDashPhase = newValue}
	}

	/// same as CAShapeLayer.lineDashPattern
	open var lineDashPattern: [CGFloat]? {
		get {return shapeLayer.lineDashPattern?.map{CGFloat($0.doubleValue)}}
		set {shapeLayer.lineDashPattern = newValue?.map{NSNumber(value: Double($0))}}
	}

	/// the shape layer for this balloon
	open var shapeLayer: CAShapeLayer {
		return layer as! CAShapeLayer
	}

	open var effectiveContentRect: CGRect {
		return configuration.rectWithoutStem(bounds)
	}

	open var effectiveContentRectWithCornersInsetted: CGRect {
		let rect = effectiveContentRect
		return rect.insetBy(dx: cornerRadius * 0.5, dy: cornerRadius * 0.5)
	}

	// MARK: - Private
	open func updateColors() {
		shapeLayer.fillColor = fillColor?.cgColor
		shapeLayer.strokeColor = strokeColor?.cgColor
	}

	// MARK: - UIView
	override open func layoutSubviews() {
		super.layoutSubviews()
		shapeLayer.path = UIBezierPath(balloonInRect: CGRect(origin: .zero, size: bounds.size), configuration: configuration).cgPath
	}

	override public class var layerClass: AnyClass {
		return CAShapeLayer.self
	}

	override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateColors()
	}

	// MARK: - CALayerDelegate
	override open func action(for layer: CALayer, forKey key: String) -> CAAction? {
		if key == "path" || key == "strokeStart" || key == "strokeEnd" || key == "strokeColor" || key == "fillColor" {
			if let animation = layer.action(forKey: "opacity") as? CABasicAnimation {
				animation.keyPath = key
				animation.fromValue = layer.value(forKey: key)
				animation.toValue = nil
				animation.byValue = nil
				return animation
			}
		}

		return super.action(for: layer, forKey: key)
	}
}

/// Helpers for use in InterfaceBuilder
extension BalloonShapeView {
	@IBInspectable var cornerRadius: CGFloat {
		get {
			switch configuration.cornerRadius {
				case .oval:
					return .infinity

				case .fixed(let value):
					return value
			}
		}
		set {
			configuration.cornerRadius = newValue.isInfinite  ? .oval: .fixed(newValue)
		}
	}

	@IBInspectable var stemOffset: CGFloat {
		get { configuration.stem.offset }
		set { configuration.stem.offset = newValue }
	}

	@IBInspectable var stemWidth: CGFloat {
		get { configuration.stem.size.width }
		set { configuration.stem.size.width = newValue }
	}

	@IBInspectable var stemHeight: CGFloat {
		get { configuration.stem.size.height }
		set { configuration.stem.size.height = newValue }
	}

	@IBInspectable var stemTipWidth: CGFloat {
		get { configuration.stem.tipSmoothenWidth }
		set { configuration.stem.tipSmoothenWidth = newValue }
	}

	@IBInspectable var stemSmoothCornersWidthRatio: CGFloat {
		get {
			switch configuration.stem.cornerSmoothening {
				case .custom(let widthRatio, _):
					return widthRatio
			}
		}
		set {
			configuration.stem.cornerSmoothening = .custom(widthRatio: newValue, heightRatio: stemSmoothCornersHeightRatio)

		}
	}

	@IBInspectable var stemSmoothCornersHeightRatio: CGFloat {
		get {
			switch configuration.stem.cornerSmoothening {
				case .custom(_, let heightRatio):
					return heightRatio
			}
		}
		set {
			configuration.stem.cornerSmoothening = .custom(widthRatio: stemSmoothCornersWidthRatio, heightRatio: newValue)

		}
	}
}
