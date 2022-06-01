![Viewer](https://raw.githubusercontent.com/3lvis/Viewer/master/GitHub/viewer-logo-2.jpg)

<div align = "center">
  <a href="https://cocoapods.org/pods/Viewer">
    <img src="https://img.shields.io/cocoapods/v/Viewer.svg?style=flat" />
  </a>

  <a href="https://github.com/3lvis/Viewer">
    <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" />
  </a>

  <img src="https://img.shields.io/badge/platforms-iOS%20%7C%20tvOS%20-lightgrey.svg" />

  <a href="https://cocoapods.org/pods/Viewer">
    <img src="https://img.shields.io/cocoapods/l/Viewer.svg?style=flat" />
  </a>
</div>

## Table of Contents

* [Features](#features)
  * [Focus](#focus)
  * [Browse](#browse)
  * [Rotation](#rotation)
  * [Zoom](#zoom)
  * [tvOS](#tvos)
* [Setup](#setup)
* [Installation](#installation)
* [License](#license)
* [Author](#author)

## Features

### Focus

Select an image to enter into lightbox mode.

<p align="center">
  <img src="https://github.com/3lvis/Viewer/raw/master/GitHub/focus.gif"/>
</p>

### Browse

Open an image or video to browse.

<p align="center">
  <img src="https://github.com/3lvis/Viewer/raw/master/GitHub/play.gif"/>
</p>

### Rotation

Portrait or landscape, it just works.

<p align="center">
  <img src="https://github.com/3lvis/Viewer/raw/master/GitHub/rotation.gif"/>
</p>

### Zoom

Pinch-to-zoom works seamlessly in images.

<p align="center">
  <img src="https://raw.githubusercontent.com/3lvis/Viewer/master/GitHub/zoom.gif"/>
</p>

### tvOS

Support for the Apple TV.

<p align="center">
  <img src="https://raw.githubusercontent.com/3lvis/Viewer/master/GitHub/tv.gif"/>
</p>

## Setup

You'll need a collection of items that comform to the [Viewable protocol](https://github.com/3lvis/Viewer/blob/master/Source/Viewable.swift). Then, from your UICollectionView:

```swift
import Viewer

override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let collectionView = self.collectionView else { return }

    let viewerController = ViewerController(initialIndexPath: indexPath, collectionView: collectionView)
    viewerController.dataSource = self
    presentViewController(viewerController, animated: false, completion: nil)
}

extension CollectionController: ViewerControllerDataSource {
    func viewerController(_ viewerController: ViewerController, viewableAt indexPath: IndexPath) -> Viewable {
        return photos[indexPath.row]
    }
}
```

## Installation

### CocoaPods

```ruby
pod 'Viewer'
```

### Carthage

```ruby
github "3lvis/Viewer"
```

## License

**Viewer** is available under the MIT license. See the [LICENSE](/LICENSE.md) file for more info.
