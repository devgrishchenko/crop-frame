# CropFrame

[![Version](https://img.shields.io/cocoapods/v/CropFrame.svg?style=flat)](https://cocoapods.org/pods/CropFrame)
[![License](https://img.shields.io/cocoapods/l/CropFrame.svg?style=flat)](https://cocoapods.org/pods/CropFrame)
[![Platform](https://img.shields.io/cocoapods/p/CropFrame.svg?style=flat)](https://cocoapods.org/pods/CropFrame)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

CropFrame is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CropFrame', '~> 0.0.1'
```

## Usage

- Drag and drop a new UIView and assign it to UICropFrameView class.
- Connect the view with the controller.

```swift
@IBOutlet var cropFrameView: UICropFrameView!
```

## Features

- Flexible customization of UICropFrameView properties.
- Crop UICropFrameView region to UIImage:

```swift
let image: UIImage = self.cropFrameView.crop
```

## Author

Igor Grishchenko

## License

CropFrame is available under the MIT license. See the LICENSE file for more info.
