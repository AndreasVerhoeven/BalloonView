# BalloonView
A customizable view for a popup balloon that has mathematically correct smooth corners. Also provides access to a UIBezierPath.

<img width="340" alt="Screen Shot 2021-06-04 at 14 11 37" src="https://user-images.githubusercontent.com/168214/120800672-7f583c80-c540-11eb-8679-5502c4188ecc.png">

<img width="341" alt="Screen Shot 2021-06-04 at 14 24 57" src="https://user-images.githubusercontent.com/168214/120800793-a6167300-c540-11eb-8944-637eacfae5e6.png">

<img width="335" alt="Screen Shot 2021-06-04 at 14 26 05" src="https://user-images.githubusercontent.com/168214/120800932-d1995d80-c540-11eb-9063-d5caeb61cbbf.png">

# What?

This library allows one to create a `UIBezierPath` for a popup balloon, with a stem and a rounded rectangle. The  balloon has mathematically correct smoothed corners and can be customized.

There's also `BalloonShapeView`  that is a view with an animatable balloon.

## BalloonConfiguration

Balloons can be configured by setting the properties on a `BalloonConfiguration` object:
 
 - `cornerRadius` The corner radius of the balloon, either `.oval` for an oval or `.fixed(value)` or `none` for no rounded corners.
 
- `stem`: the configuration of the stem, with the following properties:

  - `edge` the edge the stem is attached to: `.bottom`, `.top`, `.left` or .`right`
  - `offset` The stem is, by default, centered in the edge. Use this to offset it. A positive offset moves the stem to the right (or down), a negative one moves it to the left (or up)
  - `size` the size of the stem.
  - `cornerSmoothening` How to smooth the corners between the stem and the edge it i attached to. Either `enabled`, `disabled` or `custom(widthRatio, heightRatio)`.
  - `tipSmoothenWidth` how much we should smoothen the tip of the stem, in points. 0 means that the tip is sharp, the larger the value, the more the tip is smoothened with an arc.
  
  
  # UIBezierPath
  
  To create a `UIBezierPath` balloon, you can call:
  
  `UIBezierPath.init(balloonInRect:configuration:)` with the rect you want the balloon to fit in and the balloon's configuration. The whole balloon and stem will fit inside the given rect. 
  

You can also call  `UIBezierPath.init(balloonWithRect:configuration)`, which will make a balloon path where the stem is outside of the given rect.
  
 
# BalloonShapeView

If you need a balloon as a view, use `BalloonShapeView`. 


## Configuration
Configure the balloon using the `configuration` parameter or the convenience properties such as `stemWidth`, `stemHeight`,  `cornerRadius`, `stemOffset`. The convenience properties are also accessible from InterfaceBuilder.

## Animation
To animate changes to the configuration, call  `layoutIfNeeded()` in an animation block:

	UIView.animateWithDuration(0.25) {
		// modify configuration
		balloonView.configuration.cornerRadius = .fixed(40)
		balloonView.layoutIfNeeded()
	}

## Fill, Stroke and Colors.
`BalloonShapeView` exposes most properties of `CAShapeLayer` such as `fillColor` and `strokeColor` and `lineWidth`.
