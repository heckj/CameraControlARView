# ``/CameraControlARView``

An ARView with camera controls and SwiftUI wrappers to use RealityKit on macOS.

## Overview

The package provides an `ARView` subclass that you can use within AppKit, or with SwiftUI through a wrapping representable view.
RealityKit includes an `ARView` that functions on macOS in a limited fashion.
This library provides a subclassed ARView that controls the position and orientation of the AR camera with a mouse, trackpad and/or keyboard.
Use this library to view RealityKit scene elements on macOS, or iOS, independently of using ARKit and the live scene processing through the device's camera.

You can create an instance of ``CameraControlledARView`` and pass it in to ``ExternalRealityKitView`` as a variable to own the lifetime of the view.
Use ``RealityKitView`` to provide a RealityKit view that is maintained as a singleton reference, with configuration available through a closure to the initializer of the view.

You can also assemble a view yourself using ``ARViewContainer``, providing it an instead of ``CameraControlARView``
For example, the following snippet creates a SwiftUI view that manages its own instance of CamearControlARView, presenting a RealityKit scene:

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

### Components for the SwiftUI Views

- ``ARViewContainer``
- ``CameraControlledARView``
- ``MotionMode``
