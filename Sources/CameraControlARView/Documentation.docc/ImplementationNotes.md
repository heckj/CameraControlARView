# Implementation Notes

Notes to future me, and any other contributors, that are trying to understand the moving parts of this library.

## Overview

This library started as a means of getting a 3D view, rendered using the RealityKit engine, exposed on macOS, mostly for utility and debugging purposes.
Since then, VisionOS was released, along with purpose-built RealityKit kits on that platform.
To accommodate the goal of writing code that can relatively easily work on all of macOS, iOS, and visionOS, this library expanded its effort against a SwiftUI oriented API.


### Getting an ARView configured in a declarative format

ARView is a class, and awkwardly doesn't fit easily into declarative structures. You need to create it, configure it (if needed, and mostly this does), and **then** use it.
With OG UIKit and AppKit apps, you can create it externally as a part of the app setup process and pass it in, which is where this library started.
With SwiftUI, the choices are retain that external setup and pass it in (which is what ``ExternalRealityKitView`` does), or establish the ARView and any relevant scene configuration within a closure (``RealityKitView``). 
In the case of ``RealityKitView``, this closure is invoked on the view initialization, which is inordinately heavy-weight for a SwiftUI View.

The main code for what gets created to handle user input events is within ``CameraControlledARView``, which takes explicit control of the camera positioning and orientation, and maps incoming inputs to adjust the camera's transform.

### Choices of Motion

The first version of the library hard coded an arc-ball style, set up to orbiting a location and map user inputs into adjusting the positioning of the camera, while automatically "looking at" a specific point.
In a later version, I wanted to add a sort of "top-down" view that could be panned around in the sky, so I refactored the state needed to manage each of these into ``ArcBallState`` and ``BirdsEyeState``.
The full set of motion modes is captured in ``MotionMode``.

An instance of ``CameraControlledARView`` has both states within it, under a whack-notion of mine that I'd like to offer changing motion modes while retaining the same fundamental ARview with its configuration, scene, etc.
If/when this is implemented, we'll need to accommodate updating one state from the other, or transitioning (perhaps with a camera transition of some form) in some smooth animation process.
The general idea was wanting to enable switching from an over-head view to a first-person or over-the-should style view moving down into a view and hovering over, or around, a specific model within the scene. 

### Mapping User Inputs

In order to support any sort of additional interaction, I opted to constrain inputs to two-finger gestures, reserving single-point-of-contact interactions for user interactions (click/touch, double-click/double-tap, click-and-drag/touch-and-drag, long touch, etc).
Unfortunately, macOS and iOS expose the common gesture patterns differently.

In macOS, we have to reach for the NSView subclass overrides, which capture mouse and trackpad events within `mouseDown(with:)`, `mouseDragged(with:)`. 
TrackPad two-finger gestures, in particular, map to `scrollWheel(with:)`, `rotate(with:)`, and `magnify(with:)`.
In addition, we can capture keyboards, which provide a means of expanding the options for camera motion control, or replacing them entirely from mouse/trackpad events.
Those events are captured within `keyDown(with:)`, and use `keyCode` and `isARepeat` on the provided instance of `NSEvent`.

There's a whole slew of `NSResponder` overrides that could make additional sense of mouse, tablet, or other support options.
I'm seriously considering trying to use `flagsChanged(with:)` to capture keyboard optional events to change modes/state within the motion setup to allow pan, rotate, and/or zoom gestures to take on either constrained (shift key) or alternate (option key) movement options.

When it comes to moving the camera - there's loosely 6 degrees of freedom to accommodate. 
Three that make up the `x`, `y`, and `z` positioning of the camera itself (its translation or position).
The remaining three can map to the camera's rotation.

How they these various inputs map, and what they do, is captured within switch statements in these overrides, updating a state instance for the relevant ``MotionMode``.
In each of the overrides, if I _don't_ capture the event and consume it, I call `super.whatever(with: event)` to propagate the relevant event further along the responder chain.
