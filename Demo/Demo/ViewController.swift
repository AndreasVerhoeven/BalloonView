//
//  ViewController.swift
//  Scratc
//
//  Created by Andreas Verhoeven on 29/05/2021.
//

import UIKit

class ViewController: UITableViewController {

	@IBOutlet var balloonView: BalloonShapeView!
	@IBOutlet var contentLabel: UILabel!

	@IBOutlet var edgeSegmentedControl: UISegmentedControl!
	@IBOutlet var offsetSlider: UISlider!
	@IBOutlet var cornerRadiusSlider: UISlider!
	@IBOutlet var stemWidthSlider: UISlider!
	@IBOutlet var stemHeightSlider: UISlider!
	@IBOutlet var stemTipWidthSlider: UISlider!
	@IBOutlet var stemSmoothCornersWidthRatioSlider: UISlider!
	@IBOutlet var stemSmoothCornersHeightRatioSlider: UISlider!


	@IBAction func controlDidChange(_ sender: Any) {
		updateBalloonConfiguration(animated: (sender is UISlider) == false)
	}

	func updateBalloonConfiguration(animated: Bool) {
		let balloonView = self.balloonView
		var configuration = balloonView!.configuration
		configuration.stem.edge = edgeFromSegmentedControl
		
		configuration.stem.offset = CGFloat(offsetSlider.value)
		configuration.cornerRadius = .fixed(CGFloat(cornerRadiusSlider.value))
		configuration.stem.size = CGSize(width: CGFloat(stemWidthSlider.value), height: CGFloat(stemHeightSlider.value))
		configuration.stem.tipSmoothenWidth = CGFloat(stemTipWidthSlider.value)

		configuration.stem.cornerSmoothening = .custom(widthRatio: CGFloat(stemSmoothCornersWidthRatioSlider.value),
													   heightRatio: CGFloat(stemSmoothCornersHeightRatioSlider.value))

		view.setNeedsLayout()
		let updates = {
			balloonView?.configuration = configuration
			balloonView?.layoutIfNeeded()
			self.view.layoutIfNeeded()
		}

		if animated == true {
			UIView.animate(withDuration: 0.24, delay: 0, options: [.beginFromCurrentState], animations: updates)
		} else {
			updates()
		}
	}

	var edgeFromSegmentedControl: BalloonConfiguration.Edge {
		switch edgeSegmentedControl.selectedSegmentIndex {
			case 0: return .bottom
			case 1: return .left
			case 2: return .top
			case 3: return .right
			default: return .bottom
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		offsetSlider.minimumValue = Float(-balloonView.bounds.width * 0.5)
		offsetSlider.maximumValue = Float(balloonView.bounds.width * 0.5)

		let rect = balloonView.effectiveContentRectWithCornersInsetted
		contentLabel.frame = CGRect(x: floor(rect.origin.x), y: floor(rect.origin.y), width: ceil(rect.width), height: ceil(rect.height))
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		edgeSegmentedControl.setImage(UIImage(systemName: "bubble.middle.bottom", orientation: .up), forSegmentAt: 0)
		edgeSegmentedControl.setImage(UIImage(systemName: "bubble.middle.bottom", orientation: .right), forSegmentAt: 1)
		edgeSegmentedControl.setImage(UIImage(systemName: "bubble.middle.bottom", orientation: .down), forSegmentAt: 2)
		edgeSegmentedControl.setImage(UIImage(systemName: "bubble.middle.bottom", orientation: .left), forSegmentAt: 3)

		balloonView.layer.shadowColor = UIColor.black.cgColor
		balloonView.layer.shadowOffset = .zero
		balloonView.layer.shadowOpacity = 0.5
		balloonView.layer.shadowRadius = 5

		offsetSlider.value = Float(balloonView.stemOffset)
		cornerRadiusSlider.value = Float(balloonView.cornerRadius)
		stemWidthSlider.value = Float(balloonView.stemWidth)
		stemHeightSlider.value = Float(balloonView.stemHeight)
		stemTipWidthSlider.value = Float(balloonView.stemTipWidth)
		stemSmoothCornersWidthRatioSlider.value = Float(balloonView.stemSmoothCornersWidthRatio)
		stemSmoothCornersHeightRatioSlider.value = Float(balloonView.stemSmoothCornersHeightRatio)

		contentLabel.contentMode = .center

		let fontDescriptor = UIFont.boldSystemFont(ofSize: 17).fontDescriptor
		contentLabel.font = UIFont(descriptor: fontDescriptor.withDesign(.rounded) ?? fontDescriptor, size: 26)

		updateBalloonConfiguration(animated: false)

	}
}


extension UIImage {
	convenience init(systemName: String, orientation: UIImage.Orientation) {
		if let image  = UIImage(systemName: systemName), let cgImage = image.cgImage {
			self.init(cgImage: cgImage, scale: image.scale, orientation: orientation)
		} else {
			self.init()
		}
	}
}
