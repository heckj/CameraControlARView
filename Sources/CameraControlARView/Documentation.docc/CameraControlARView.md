# ``/CameraControlARView``

An ARView with camera control and SwiftUI wrappers to use RealityKit with macOS.

## Overview

The package provides an `ARView` subclass that you can use within AppKit, or with SwiftUI through a wrapping representable view.
RealityKit includes an `ARView` that functions on macOS, but in a limited fashion.
The subclassed ARView provides controls to move the camera within the RealityKit scene with a mouse, trackpad and/or keyboard.

The wrapping SwiftUI view is crafted to allow you to create an instance of the ``CameraControlledARView`` externally and provide it to the view. 
The following example view illustrates creating a view so that you can also access the underlying view's properties to manipulate the view: 

Configure this subclass of ARView, potentially appending any scene details, before using it
to initialize ``ARViewContainer`` to present the via in SwiftUI. 

For example, the following snippet creates a SwiftUI view into a RealityKit scene:

```swift
struct ExampleARContentView: View {

    @StateObject var arview: CameraControlARView = {
        let arView = CameraControlARView(frame: .zero)

        // Set ARView debug options
        arView.debugOptions = [
            .showStatistics,
        ]

        // You can provide additional configuration
        // or constructing your rendering view.
        // If your project includes an experience
        // crafted with Reality Composer, you can
        // load it:
        //
        // let boxAnchor = try! Experience.loadBox()
        // arView.scene.anchors.append(boxAnchor)

        return arView
    }()

    var body: some View {
        ARViewContainer(cameraARView: arview)
    }
}
```

## Topics

### SwiftUI View for RealityKit 

- ``RealityKitView``
- ``RealityKitView/Context``

### Configurable SwiftUI View for RealityKit

- ``CameraControlledARView``
- ``ARViewContainer``
