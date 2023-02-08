//
//  BalloonCalloutView.swift
//  Demo
//
//  Created by Andreas Verhoeven on 08/02/2023.
//

import UIKit

/// A Callout view that is a balloon that can be shown and hidden with animation. Automatically updates its position.
/// Add subviews to the contentView
open class BalloonCalloutView: UIView {
	public var backgroundView = BalloonShapeView()
	public let contentView = UIView()
	
	/// if true, will automatically update its position when the attached view changes
	var automaticallyTrackPositionOfAttachedView = true {
		didSet {
			guard automaticallyTrackPositionOfAttachedView != oldValue else { return }
			startOrStopTrackingIfNeeded()
		}
	}
	
	/// The view this callout should be attached to: the balloon is position according to this view.
	public var attachedToView: UIView? {
		didSet {
			update()
			startOrStopTrackingIfNeeded()
		}
	}
	
	/// Call this to add the callout to a parent view: sets up constraints
	open func addToParentView(_ parentView: UIView) {
		translatesAutoresizingMaskIntoConstraints = false
		parentView.addSubview(self)
		
		let locationCenterXConstraint = parentView.centerXAnchor.constraint(equalTo: centerXAnchor)
		let locationCenterYConstraint = parentView.centerYAnchor.constraint(equalTo: centerYAnchor)
		let constraints = [
			parentView.safeAreaLayoutGuide.leadingAnchor.constraint(lessThanOrEqualTo: leadingAnchor, constant: -8),
			parentView.safeAreaLayoutGuide.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: 8),
			parentView.safeAreaLayoutGuide.topAnchor.constraint(lessThanOrEqualTo: topAnchor, constant: -8),
			parentView.safeAreaLayoutGuide.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: 8),
		]
		constraints.forEach { $0.priority = .required }
		locationCenterXConstraint.priority = .defaultLow
		locationCenterYConstraint.priority = .defaultLow
		NSLayoutConstraint.activate(constraints + [locationCenterXConstraint, locationCenterYConstraint])
		
		setContentHuggingPriority(.required, for: .vertical)
		setContentHuggingPriority(.required, for: .horizontal)
		widthAnchor.constraint(lessThanOrEqualTo: parentView.widthAnchor, multiplier: 0.7).isActive = true
		self.locationCenterXConstraint = locationCenterXConstraint
		self.locationCenterYConstraint = locationCenterYConstraint
	}
	
	/// shows the callout
	public func show(animated: Bool) {
		startOrStopTrackingIfNeeded()
		
		guard animated else {
			alpha = 1
			return
		}
		
		removeAllAnimationsInHierarchy()
		self.alpha = 0
		
		UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: []) {
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0) {
				self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
			}
			
			UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
				self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
			}
			
			UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
				self.transform = CGAffineTransform(scaleX: 1, y: 1)
			}
			
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
				self.alpha = 1
			}
		}
	}
	
	/// hides the callout
	public func hide(animated: Bool) {
		guard animated else {
			alpha = 0
			startOrStopTrackingIfNeeded()
			return
		}
		
		UIView.animate(withDuration: 0.25, animations: {
			self.alpha = 0
			self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
		}, completion: { [weak self] _ in
			self?.startOrStopTrackingIfNeeded()
		})
	}
	
	/// can be called to update positions manually
	public func update() {
		guard let locationCenterXConstraint = locationCenterXConstraint else { return }
		guard let locationCenterYConstraint = locationCenterYConstraint else { return }
		guard let parentView = superview else { return }
		guard let attachedToView = attachedToView else { return }
		
		let inset = CGFloat(32)
		let rect = CGRect(origin: .zero, size: parentView.bounds.size).inset(by: parentView.safeAreaInsets).inset(by: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset))
		let frameInParent = attachedToView.convert(attachedToView.bounds, to: parentView)
		let diff = CGPoint(x: parentView.bounds.midX - frameInParent.midX, y: parentView.bounds.midY - frameInParent.minY)
		
		var configuration = backgroundView.configuration
		let offset: CGFloat
		configuration.stem.edge = .bottom
		if frameInParent.minY - bounds.height < rect.minY + 12 {
			configuration.stem.edge = .top
			offset = inset + frameInParent.height + bounds.height + 4
		} else {
			configuration.stem.edge = .bottom
			offset = -4 + inset
		}
		
		let newPosition = CGPoint(x: diff.x, y: diff.y + bounds.height * 0.5 - offset)
		guard newPosition.x.isAlmostEqual(to: locationCenterXConstraint.constant) == false
				|| newPosition.y.isAlmostEqual(to: locationCenterYConstraint.constant) == false
				|| backgroundView.configuration != configuration else {
			return
		}
		
		locationCenterXConstraint.constant = newPosition.x
		locationCenterYConstraint.constant = newPosition.y
		backgroundView.configuration = configuration
		
		updateStemPosition()
	}
	
	/// can be called to update the stem position manually
	public func updateStemPosition() {
		guard let parentView = superview else { return }
		guard let attachedToView = attachedToView else { return }
		
		let centerX = attachedToView.convert(CGPoint(x: attachedToView.bounds.width * 0.5, y: 0), to: parentView).x
		
		backgroundView.configuration.stem.offset = centerX - center.x
		updateContentViewAndShadowPath()
	}
	
	// MARK: - Input
	@objc private func displayLinkFired(_ sender: Any) {
		update()
	}
	
	// MARK: - Private
	private var displayLink: CADisplayLink?
	private var locationCenterXConstraint: NSLayoutConstraint!
	private var locationCenterYConstraint: NSLayoutConstraint!
	
	private var contentViewLeadingConstraint: NSLayoutConstraint!
	private var contentViewTrailingConstraint: NSLayoutConstraint!
	private var contentViewTopConstraint: NSLayoutConstraint!
	private var contentViewBottomConstraint: NSLayoutConstraint!
	
	private func updateContentViewAndShadowPath() {
		let configuration = backgroundView.configuration
		let rect = CGRect(origin: .zero, size: bounds.size)
		layer.shadowPath = UIBezierPath(balloonInRect: rect, configuration: configuration).cgPath
		
		let insets = configuration.insetsForStem(in: rect)
		let cornerRadius = configuration.effectiveCornerRadius(in: rect)
		
		let extraInset = cornerRadius * 0.5
		let finalInsets = NSDirectionalEdgeInsets(top: insets.top + extraInset, leading: insets.left + extraInset, bottom: insets.bottom + extraInset, trailing: insets.right + extraInset)
		
		contentViewLeadingConstraint.setConstantIfNeeded(finalInsets.leading)
		contentViewTrailingConstraint.setConstantIfNeeded(-finalInsets.trailing)
		contentViewTopConstraint.setConstantIfNeeded(finalInsets.top)
		contentViewBottomConstraint.setConstantIfNeeded(-finalInsets.bottom)
	}
	
	private func startOrStopTrackingIfNeeded() {
		if automaticallyTrackPositionOfAttachedView == true && attachedToView != nil && superview != nil && window != nil && alpha > 0 {
			if displayLink == nil {
				displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFired(_:)))
				if #available(iOS 15, *) {
					displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 120)
				}
				displayLink?.add(to: .main, forMode: .common)
				displayLink?.add(to: .main, forMode: .tracking)
			}
		} else {
			
		}
	}
	
	// MARK: - UIView
	open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		guard super.point(inside: point, with: event) else { return false }
		return backgroundView.shapeLayer.path?.contains(point) ?? super.point(inside: point, with: event)
	}
	
	override open var frame: CGRect {
		didSet {
			updateStemPosition()
		}
	}
	
	override open var center: CGPoint {
		didSet {
			updateStemPosition()
		}
	}
	
	override open func layoutSubviews() {
		super.layoutSubviews()
		
		update()
		updateContentViewAndShadowPath()
	}
	
	open override func didMoveToWindow() {
		super.didMoveToWindow()
		startOrStopTrackingIfNeeded()
	}
	
	override public init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundView.configuration.stem.size = CGSize(width:  34, height: 18)
		backgroundView.configuration.cornerRadius = .fixed(16)
		backgroundView.configuration.stem.tipSmoothenWidth = 6
		backgroundView.configuration.stem.cornerSmoothening = .custom(widthRatio: 0.4, heightRatio: 0.4)
		
		layer.shadowOpacity = 0.25
		layer.shadowRadius = 10
		layer.shadowOffset = .zero
		
		backgroundView.fillColor = .secondarySystemBackground
		backgroundView.strokeColor = UIColor.label.withAlphaComponent(0.5)
		backgroundView.lineWidth = 1.0 / UIScreen.main.scale * 2
		
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(backgroundView)
		NSLayoutConstraint.activate([
			backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
			backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
			backgroundView.topAnchor.constraint(equalTo: topAnchor),
			backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
		])
		
		
		contentView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(contentView)
		contentViewLeadingConstraint = contentView.leadingAnchor.constraint(equalTo: leadingAnchor)
		contentViewTrailingConstraint = contentView.trailingAnchor.constraint(equalTo: trailingAnchor)
		contentViewTopConstraint = contentView.topAnchor.constraint(equalTo: topAnchor)
		contentViewBottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
		NSLayoutConstraint.activate([
			contentViewLeadingConstraint,
			contentViewTrailingConstraint,
			contentViewTopConstraint,
			contentViewBottomConstraint,
		])
	}
	
	@available(*, unavailable)
	required public init?(coder: NSCoder) {
		fatalError("Not implemented")
	}
}

extension NSLayoutConstraint {
	fileprivate func setConstantIfNeeded(_ value: CGFloat) {
		guard constant.isAlmostEqual(to: value) == false else { return }
		constant = value.roundedToNearestPixel
	}
}

extension CGFloat {
	fileprivate var roundedToNearestPixel: CGFloat {
		let scale = UIScreen.main.scale
		return (self * scale).rounded() / scale
	}
}

extension UIView {
	/// Removes all animations in the complete hierarchy
	fileprivate func removeAllAnimationsInHierarchy() {
		removeAllAnimations()
		for subview in subviews {
			subview.removeAllAnimationsInHierarchy()
		}
	}
	
	/// Removes all animations in this view
	fileprivate func removeAllAnimations() {
		layer.removeAllAnimations()
	}
}
