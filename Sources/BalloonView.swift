//
//  BalloonView.swift
//  Scratc
//
//  Created by Andreas Verhoeven on 03/06/2021.
//

import UIKit

open class BalloonView: UIView {
	open var configuration = BalloonConfiguration() {
		didSet {
			balloonMask.configuration = configuration
		}
	}

	public var clipView = UIView()
	public var balloonMask = BalloonShapeView()
	public var backgroundView = UIView()
	public var contentView = UIView()

	// MARK: - Private
	private func setup() {
		balloonMask.fillColor = .red

		addSubview(clipView)
		clipView.addSubview(backgroundView)
		clipView.addSubview(contentView)

		clipView.mask = balloonMask
	}

	// MARK: - UIView
	open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		guard super.point(inside: point, with: event) else { return false }
		return balloonMask.shapeLayer.path?.contains(point) ?? super.point(inside: point, with: event)
	}

	open override func layoutSubviews() {
		super.layoutSubviews()
		
		let rect = CGRect(origin: .zero, size: bounds.size)
		balloonMask.frame = rect
		clipView.frame = rect
		backgroundView.frame = rect
		contentView.frame = configuration.rectWithoutStem(rect)
		layer.shadowPath = UIBezierPath(balloonInRect: rect, configuration: configuration).cgPath
	}

	public override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	// MARK: - CALayerDelegate
	override open func action(for layer: CALayer, forKey key: String) -> CAAction? {
		if key == "shadowPath" || key == "shadowRadius" || key == "shadowOffset" || key == "shadowColor" || key == "shadowOpacity" {
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
