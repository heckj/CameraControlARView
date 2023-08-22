# ``/CameraControlARView``

An ARView with explicit camera controls to use RealityKit on macOS and iOS.

## Overview

Use this library to view a RealityKit scene on macOS, or iOS, independently of using ARKit and the live scene processing through the device's camera.
This project started out with the focus of providing a virtual camera and controls for RealityKit.

If you want explicit controls within an iOS app for a RealityKit scene, this package can work, but is more limited, by the devices, with easily used potential inputs.

To use with SwiftUI, create an instance of ``CameraControlledARView`` and pass it in to ``ExternalRealityKitView`` as a variable to own the lifetime of the view.
Use ``RealityKitView`` to provide a RealityKit view that is maintained in a singleton reference, with configuration available through a closure to the initializer of the view.

You can also assemble a view yourself using ``ARViewContainer``, providing it with your own configured ARView instead of ``CameraControlARView``.
The following snippet creates a SwiftUI view that manages its own instance of CameraControlARView, presenting a RealityKit scene:

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

### Motion Controls

On macOS, the `ARView` subclass controls the position and orientation of the AR camera with a mouse, trackpad and/or keyboard.
The view attempts to constrain camera movement and orientation controls to gestures on the trackpad, reserving click, double-click and combinations with any modifier keys for application use.

## Topics

### SwiftUI View for RealityKit 

- ``RealityKitView``
- ``RealityKitView/Context``
- ``ExternalRealityKitView``

### Components for the SwiftUI Views

- ``ARViewContainer``
- ``CameraControlledARView``
- ``MotionMode``
- ``ArcBallState``
- ``BirdsEyeState``

### Contributor Notes

- <doc:ImplementationNotes>
