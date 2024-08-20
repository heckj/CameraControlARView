//
//  CameraControlledARView.swift
//
//
//  Created by Joseph Heck on 2/7/22.
//

// swiftformat:options --selfrequired trace
// ^ needed for Autoclosure requirement need for self in logger.trace() calls

#if os(iOS)
    import ARKit
    public import UIKit
#endif
#if os(macOS)
    public import AppKit
#endif
import CoreGraphics
import Foundation
import OSLog
public import RealityKit

/// A 3D View for SwiftUI using RealityKit that provides movement controls for the camera within the view.
///
/// Initialize a new instance with `init()` or `init(frame:)` on macOS, `init(frame:cameraMode:)` on iOS.
/// The ARView creates and maintains the scene associated with the view upon initialization.
///
/// Once the view is initialized, configure the scene by updating it with entities attached to anchors, or apply view debugging
/// options through the `debugOptions` property.
///
/// Set the ``CameraControlledARView/motionMode-swift.property`` to define the motion controls.
/// - ``MotionMode-swift.enum/arcball_direct(keys:)`` for rotating around a specific point with point and click gestures.
/// - ``MotionMode-swift.enum/arcball(keys:)`` for rotating around a specific point with scrolling gestures.
/// - ``MotionMode-swift.enum/firstperson`` for moving freely within the environment.
///
/// The default motion mode is ``MotionMode-swift.enum/arcball_direct(keys:)``.
///
/// When used on iOS, a pinch gesture is automatically registered for interaction.
///
/// Additional properties control the target location, the camera's location, or the speed of movement within the environment.
@available(macOS 11.0, *)
@objc public final class CameraControlledARView: ARView, ObservableObject {
    /// The mode in which the camera is controlled by keypresses and/or mouse and gesture movements.
    ///
    /// The default option is ``MotionMode-swift.enum/arcball(keys:)``:
    /// - ``MotionMode-swift.enum/arcball_direct(keys:)`` for rotating around a specific point with point and click gestures.
    /// - ``MotionMode-swift.enum/arcball(keys:)`` for rotating around a specific point with scrolling gestures.
    /// - ``MotionMode-swift.enum/firstperson`` for moving freely within the environment.
    ///
    public var motionMode: MotionMode

    private let logger = Logger(subsystem: "CameraControlledARView", category: "cameraState")

    // MARK: - ARCBALL mode variables

    public var arcball_state: ArcBallState {
        didSet {
            switch motionMode {
            case .arcball_direct:
                updateCamera(arcball_state)
            case .arcball:
                updateCamera(arcball_state)
            default:
                break
            }
        }
    }

    public var birdseye_state: BirdsEyeState {
        didSet {
            switch motionMode {
            case .birdseye:
                updateCamera(birdseye_state)
            default:
                break
            }
        }
    }

    // MARK: movement mode agnostic state variables

    /// The speed at which drag operations map percentage of movement within the view to rotational or positional updates.
    public var movementSpeed: Float

    /// The speed at which keypresses change the angles of inclination or rotation.
    ///
    /// This view doubles the speed value when the key is held-down.
    public var keyspeed: Float

    private var movestart_location: CGPoint
    private var magnify_start: Float

    // MARK: - FPS mode variables

    /// The speed at which the camera moves when incrementing forward via the keyboard
    public var forward_speed: Float
    /// The speed at which the camera moves when rotating using the keyboard
    public var turn_speed: Float
    private var dragstart_transform: matrix_float4x4
    private let sixtydegrees = Float.pi / 3

    /// The homogenous transform that represents the camera's location and rotation.
    public var camera_transform: matrix_float4x4 {
        get {
            cameraAnchor.transform.matrix
        }
        set {
            cameraAnchor.transform = Transform(matrix: newValue)
        }
    }

    /// A reference to the camera anchor entity for moving, or reading the location values, for the camera.
    public var cameraAnchor: AnchorEntity
    /// A copy of the basic transform applied ot the camera, and updated in parallel to reflect "upward" to SwiftUI.
    @Published var macOSCameraTransform: Transform

    #if os(iOS)
        var pinchGesture: UIPinchGestureRecognizer?
        @IBAction func pinchRecognized(_ pinch: UIPinchGestureRecognizer) {
            let multiplier = ((pinch.scale > 1.0) ? -1.0 : 1.0) * Float(pinch.scale) / 100 // magnify_end
            arcball_state.radius = arcball_state.radius * (multiplier + 1)
            updateCamera(arcball_state)
        }

        var twoFingerSwipeGesture: UISwipeGestureRecognizer?
        @IBAction func twoFingerSwipeGestureRecognized(_: UISwipeGestureRecognizer) {}
    #endif

    #if os(iOS)
        /// Creates an augmented reality view with the camera location and orientation controlled by the view.
        ///
        /// The camera orientation and location is controlled by keyboard, mouse, touch, and multitouch gestures, with the specific sets of supported gestures and their effects defined by the view's ``MotionMode-swift.enum``.
        /// The default motion mode for the view is ``MotionMode-swift.enum/arcball``, which orbits the camera around a specific point in space.
        ///
        /// - Parameter frameRect: The frame rectangle for the view, measured in points.
        /// - Parameter cameraMode: An indication of whether to use the device’s camera or a virtual one.
        @MainActor public init(frame frameRect: CGRect, cameraMode: ARView.CameraMode) {
            motionMode = .arcball_direct(keys: true)

            // ARCBALL mode
            arcball_state = ArcBallState()
            // LENS mode
            birdseye_state = BirdsEyeState()

            keyspeed = 0.01
            movementSpeed = 0.01
            magnify_start = arcball_state.radius

            // FPS mode
            forward_speed = 0.05
            turn_speed = 0.01

            // Not mode specific
            cameraAnchor = AnchorEntity(world: .zero)
            movestart_location = CGPoint.zero
            dragstart_transform = cameraAnchor.transform.matrix
            // reflect the camera's transform as an observed object
            macOSCameraTransform = cameraAnchor.transform

            #if targetEnvironment(simulator)
                super.init(frame: frameRect,
                           cameraMode: .nonAR,
                           automaticallyConfigureSession: true)
                let cameraEntity = PerspectiveCamera()
                cameraEntity.camera.fieldOfViewInDegrees = 60
                cameraAnchor.addChild(cameraEntity)
                scene.addAnchor(cameraAnchor)
            #else
                super.init(frame: frameRect,
                           cameraMode: cameraMode,
                           automaticallyConfigureSession: true)
            #endif

            updateCamera(arcball_state)

            pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchRecognized(_:)))
            addGestureRecognizer(pinchGesture!)
        }
    #endif

    /// Creates an augmented reality view with the camera location and orientation controlled by the view.
    ///
    /// The camera orientation and location is controlled by keyboard, mouse, touch, and multitouch gestures, with the specific sets of supported gestures and their effects defined by the view's ``MotionMode-swift.enum``.
    /// The default motion mode for the view is ``MotionMode-swift.enum/arcball``, which orbits the camera around a specific point in space.
    ///
    /// - Parameter frameRect: The frame rectangle for the view, measured in points.
    /// - Parameter cameraMode: An indication of whether to use the device’s camera or a virtual one.
    @MainActor dynamic required init(frame frameRect: CGRect) {
        motionMode = .arcball_direct(keys: true)

        // ARCBALL mode
        arcball_state = ArcBallState()
        // LENS mode
        birdseye_state = BirdsEyeState()

        keyspeed = 0.01
        movementSpeed = 0.01

        magnify_start = arcball_state.radius

        // FPS mode
        forward_speed = 0.05
        turn_speed = 0.01

        // Not mode specific
        cameraAnchor = AnchorEntity(world: .zero)
        movestart_location = CGPoint.zero
        dragstart_transform = cameraAnchor.transform.matrix
        // reflect the camera's transform as an observed object
        macOSCameraTransform = cameraAnchor.transform
        super.init(frame: frameRect)

        #if os(macOS) || targetEnvironment(simulator)
            let cameraEntity = PerspectiveCamera()
            cameraEntity.camera.fieldOfViewInDegrees = 60
            cameraAnchor.addChild(cameraEntity)
            scene.addAnchor(cameraAnchor)
        #endif
        // Set initial camera position based on defaults from
        // the motion tracking state machinery
        switch motionMode {
        case .arcball_direct:
            updateCamera(arcball_state)
        case .arcball:
            updateCamera(arcball_state)
        case .birdseye:
            updateCamera(birdseye_state)
        case .firstperson:
            break
        }

        #if os(iOS)
            twoFingerSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(twoFingerSwipeGestureRecognized(_:)))
            twoFingerSwipeGesture?.numberOfTouchesRequired = 2
            twoFingerSwipeGesture?.direction = [.up, .down, .left, .right]

            pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchRecognized(_:)))
            addGestureRecognizer(pinchGesture!)
        #endif
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Camera positioning and orientation

    @MainActor func updateViewFromState() {
        logger.trace("motion mode: \(self.motionMode.description)")
        switch motionMode {
        case .arcball_direct:
            updateCamera(arcball_state)
        case .arcball:
            updateCamera(arcball_state)
        case .birdseye:
            updateCamera(birdseye_state)
        case .firstperson:
            break
        }
    }

    @MainActor private func updateCamera(_ state: ArcBallState) {
        cameraAnchor.transform = state.cameraTransform()
        // reflect the camera's transform as an observed object
        macOSCameraTransform = cameraAnchor.transform
        logger.trace("state: \(state.debugDescription)")
        logger.trace("camera position \(self.cameraAnchor.transform.translation), heading: \(headingVector(self.cameraAnchor.transform)) ")
    }

    @MainActor private func updateCamera(_ state: BirdsEyeState) {
        cameraAnchor.transform = state.cameraTransform()
        // reflect the camera's transform as an observed object
        macOSCameraTransform = cameraAnchor.transform
        logger.trace("state: \(state.debugDescription)")
        logger.trace("camera position \(self.cameraAnchor.transform.translation), heading: \(headingVector(self.cameraAnchor.transform)) ")
    }

    func moveStart() {
        // captures the starting position before movement tracking
        switch motionMode {
        case .arcball:
            break
        case .firstperson:
            dragstart_transform = cameraAnchor.transform.matrix
        case .arcball_direct:
            arcball_state.movestart_rotation = arcball_state.rotationAngle
            arcball_state.movestart_inclination = arcball_state.inclinationAngle
        case .birdseye:
            break
        }
    }

    func updateMove(_ deltaX: Float, _ deltaY: Float) {
        switch motionMode {
        case .arcball, .arcball_direct:
            arcball_state.rotationAngle -= deltaX * movementSpeed
            arcball_state.inclinationAngle += deltaY * movementSpeed
            updateCamera(arcball_state)
        case .firstperson:
            // print("delta X is \(deltaX)")
            // print("delta Y is \(deltaY)")
            // print("Divided by frame X: \(deltaX/Float(self.frame.width))")
            // print("Divided by frame Y: \(deltaY/Float(self.frame.height))")

            let proportion_view_vertical_drag = deltaY / Float(frame.height)
            let proportion_view_horizontal_drag = deltaX / Float(frame.width)

            let look_up_transform = rotationAroundXAxisTransform(
                radians: -sixtydegrees * proportion_view_vertical_drag)
            let left_turn_transform = rotationAroundYAxisTransform(
                radians: sixtydegrees * proportion_view_horizontal_drag)
            let combined_transform = dragstart_transform * look_up_transform * left_turn_transform
            cameraAnchor.transform = Transform(matrix: combined_transform)
        case .birdseye:
            birdseye_state.xAxis += deltaX * movementSpeed
            birdseye_state.zAxis += deltaY * movementSpeed
            // print("grid: x \(birdseye_state.xAxis) rad, z: \(birdseye_state.zAxis) m")
            updateCamera(birdseye_state)
        }
    }

    // MARK: - Touch, Trackpad, Mouse, and Gesture Input Handling

    #if os(iOS)
        override public dynamic func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
            movestart_location = touches.first!.location(in: self)
            moveStart()
        }

        override public dynamic func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
            let drag = touches.first!.location(in: self)
            let deltaX = Float(drag.x - movestart_location.x)
            let deltaY = Float(movestart_location.y - drag.y)
            updateMove(deltaX, deltaY)
        }
    #endif

    #if os(macOS)
        override public dynamic func mouseDown(with event: NSEvent) {
            // print("mouseDown EVENT: \(event)")
            // print(" at \(event.locationInWindow) of \(frame)")
            switch motionMode {
            case .arcball_direct:
                moveStart()
            case .arcball:
                // pass through events to the rest of the responder chain
                super.mouseDown(with: event)
            case .birdseye:
                // pass through events to the rest of the responder chain
                super.mouseDown(with: event)
            case .firstperson:
                movestart_location = event.locationInWindow
            }
        }

        override public dynamic func mouseDragged(with event: NSEvent) {
            // print("mouseDragged EVENT: \(event)")
            // print(" at \(event.locationInWindow) of \(frame)")
            switch motionMode {
            case .arcball_direct:
                let deltaX = Float(event.locationInWindow.x - movestart_location.x)
                let deltaY = Float(event.locationInWindow.y - movestart_location.y)
                updateMove(deltaX, deltaY)
            case .arcball:
                // pass through events to the rest of the responder chain
                super.mouseDragged(with: event)
            case .birdseye:
                // pass through events to the rest of the responder chain
                super.mouseDragged(with: event)
            case .firstperson:
                let deltaX = Float(event.locationInWindow.x - movestart_location.x)
                let deltaY = Float(event.locationInWindow.y - movestart_location.y)
                updateMove(deltaX, deltaY)
            }
        }

        override public dynamic func scrollWheel(with event: NSEvent) {
            // two fingers moving across the trackpad
//            print("scroll EVENT: \(event)")
            if event.phase == .changed {
                updateMove(Float(event.deltaX), Float(event.deltaY))
            }

            // scroll EVENT: NSEvent: type=ScrollWheel loc=(487.367,125.148) time=198692.7 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deltaX=0.000000 deltaY=0.000000 count:0 phase=MayBegin momentumPhase=None
            // scroll EVENT: NSEvent: type=ScrollWheel loc=(487.367,125.148) time=198692.8 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deltaX=0.000000 deltaY=-1.000000 count:0 phase=Began momentumPhase=None
            // scroll EVENT: NSEvent: type=ScrollWheel loc=(487.367,125.148) time=198692.8 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deltaX=8.000000 deltaY=-12.000000 count:0 phase=Changed momentumPhase=None
            // scroll EVENT: NSEvent: type=ScrollWheel loc=(487.367,125.148) time=198692.8 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deltaX=46.000000 deltaY=-44.000000 count:1 phase=Changed momentumPhase=None
            // scroll EVENT: NSEvent: type=ScrollWheel loc=(487.367,125.148) time=198692.8 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deltaX=0.000000 deltaY=0.000000 count:1 phase=Ended momentumPhase=None

            // if event.momentumPhase == ... to handle momentum based followthrough on
            // flicks/scroll events..

            // scroll EVENT: NSEvent: type=ScrollWheel loc=(487.367,125.148) time=198692.8 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deltaX=97.000000 deltaY=-81.000000 count:1 phase=None momentumPhase=Began
            // scroll EVENT: NSEvent: type=ScrollWheel loc=(487.367,125.148) time=198692.8 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deltaX=104.000000 deltaY=-88.000000 count:1 phase=None momentumPhase=Changed
            // scroll EVENT: NSEvent: type=ScrollWheel loc=(487.367,125.148) time=198692.9 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deltaX=103.000000 deltaY=-89.000000 count:1 phase=None momentumPhase=Changed
            // scroll EVENT: NSEvent: type=ScrollWheel loc=(487.367,125.148) time=198692.9 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deltaX=99.000000 deltaY=-86.000000 count:1 phase=None momentumPhase=Changed
            // scroll EVENT: NSEvent: type=ScrollWheel loc=(487.367,125.148) time=198692.9 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deltaX=96.000000 deltaY=-83.000000 count:1 phase=None momentumPhase=Changed
            // scroll EVENT: NSEvent: type=ScrollWheel loc=(487.367,125.148) time=198692.9 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deltaX=91.000000 deltaY=-79.000000 count:1 phase=None momentumPhase=Changed
            // scroll EVENT: NSEvent: type=ScrollWheel loc=(487.367,125.148) time=198692.9 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deltaX=90.000000 deltaY=-80.000000 count:1 phase=None momentumPhase=Changed

//            scroll EVENT: NSEvent: type=ScrollWheel loc=(487.367,125.148) time=198693.9 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deltaX=1.000000 deltaY=-1.000000 count:0 phase=None momentumPhase=Changed
//            scroll EVENT: NSEvent: type=ScrollWheel loc=(487.367,125.148) time=198693.9 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deltaX=1.000000 deltaY=-1.000000 count:0 phase=None momentumPhase=Changed
//            scroll EVENT: NSEvent: type=ScrollWheel loc=(487.367,125.148) time=198693.9 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deltaX=1.000000 deltaY=-1.000000 count:0 phase=None momentumPhase=Changed
//            scroll EVENT: NSEvent: type=ScrollWheel loc=(487.367,125.148) time=198694.0 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deltaX=1.000000 deltaY=0.000000 count:0 phase=None momentumPhase=Changed
//            scroll EVENT: NSEvent: type=ScrollWheel loc=(487.367,125.148) time=198694.0 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deltaX=0.000000 deltaY=0.000000 count:0 phase=None momentumPhase=Ended

            // pass through events to the rest of the responder chain?
            super.scrollWheel(with: event)
        }

        override public dynamic func rotate(with event: NSEvent) {
            // Two fingers moving in opposite semicircles is a gesture meaning rotate.
            print("rotate EVENT: \(event)")
            if event.phase == .began {
                birdseye_state.radiusStart = birdseye_state.radius
                birdseye_state.rotationStart = birdseye_state.rotation
            } else {
//                let currentRotation = birdseye_state.rotationStart + event.rotation
                // NOTE: rotation events are meant to be accumulated and summed to get a final rotation.
                birdseye_state.rotationStart += event.rotation
                birdseye_state.xAxis = birdseye_state.radiusStart * cos(birdseye_state.rotationStart)
                birdseye_state.zAxis = birdseye_state.radiusStart * sin(birdseye_state.rotationStart)
                updateCamera(birdseye_state)
            }

            // HECKJ: this is rotating around the center of the scene, when I think what we want
            // is just rotating the camera at it's current position, around the Y axis...

            // rotate EVENT: NSEvent: type=Rotate loc=(784.109,128.215) time=198608.2 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deviceID:0x200000000000027 rotation=-0.549038 phase:Changed
            // rotate EVENT: NSEvent: type=Rotate loc=(784.109,128.215) time=198608.2 flags=0 win=0x12684a6a0 winNum=7356 ctxt=0x0 deviceID:0x200000000000027 rotation=-0.772850 phase:Ended

            // pass through events to the rest of the responder chain ?
            super.rotate(with: event)
        }

        override public dynamic func keyDown(with event: NSEvent) {
            // print("keyDown: \(event)")
            // print("key value: \(event.keyCode)")
            switch motionMode {
            case let .arcball(useKeys):
                if useKeys {
                    switch event.keyCode {
                    case 123, 0:
                        // 123 = left arrow
                        // 0 = a
                        if event.isARepeat {
                            arcball_state.rotationAngle -= keyspeed * 2
                        } else {
                            arcball_state.rotationAngle -= keyspeed
                        }
                        updateCamera(arcball_state)
                    case 124, 2:
                        // 124 = right arrow
                        // 2 = d
                        if event.isARepeat {
                            arcball_state.rotationAngle += keyspeed * 2
                        } else {
                            arcball_state.rotationAngle += keyspeed
                        }
                        updateCamera(arcball_state)
                    case 126, 13:
                        // 126 = up arrow
                        // 13 = w
                        if arcball_state.inclinationAngle > -Float.pi / 2 {
                            if event.isARepeat {
                                arcball_state.inclinationAngle -= keyspeed * 2
                            } else {
                                arcball_state.inclinationAngle -= keyspeed
                            }
                            updateCamera(arcball_state)
                        }
                    case 125, 1:
                        // 125 = down arrow
                        // 1 = s
                        if arcball_state.inclinationAngle < Float.pi / 2 {
                            if event.isARepeat {
                                arcball_state.inclinationAngle += keyspeed * 2
                            } else {
                                arcball_state.inclinationAngle += keyspeed
                            }
                            updateCamera(arcball_state)
                        }
                    default:
                        // pass through events to the rest of the responder chain
                        super.keyDown(with: event)
                    }
                } else {
                    // pass through events to the rest of the responder chain
                    super.keyDown(with: event)
                }
            case .firstperson:
                switch event.keyCode {
                case 0:
                    // 0 = a (move left)
                    if event.isARepeat {
                        cameraAnchor.position = cameraAnchor.position - (rightVector(cameraAnchor.transform) * forward_speed * 2)
                    } else {
                        cameraAnchor.position = cameraAnchor.position - (rightVector(cameraAnchor.transform) * forward_speed)
                    }
                case 2:
                    // 2 = d (move right)
                    if event.isARepeat {
                        cameraAnchor.position = cameraAnchor.position + (rightVector(cameraAnchor.transform) * forward_speed * 2)
                    } else {
                        cameraAnchor.position = cameraAnchor.position + (rightVector(cameraAnchor.transform) * forward_speed)
                    }
                case 13:
                    // 13 = w (move forward)
                    if event.isARepeat {
                        cameraAnchor.position = cameraAnchor.position + (headingVector(cameraAnchor.transform) * forward_speed * 2)
                    } else {
                        cameraAnchor.position = cameraAnchor.position + (headingVector(cameraAnchor.transform) * forward_speed)
                    }
                case 1:
                    // 1 = s (move back)
                    if event.isARepeat {
                        cameraAnchor.position = cameraAnchor.position - (headingVector(cameraAnchor.transform) * forward_speed * 2)
                    } else {
                        cameraAnchor.position = cameraAnchor.position - (headingVector(cameraAnchor.transform) * forward_speed)
                    }
                case 123:
                    // 123 = left arrow (turn left)
                    let current_transform = cameraAnchor.transform.matrix
                    let left_turn_transform: matrix_float4x4 = if event.isARepeat {
                        rotationAroundYAxisTransform(radians: turn_speed * 2)
                    } else {
                        rotationAroundYAxisTransform(radians: turn_speed)
                    }
                    cameraAnchor.transform = Transform(matrix: matrix_multiply(current_transform, left_turn_transform))
                case 124:
                    // 124 = right arrow (turn right)
                    let current_transform = cameraAnchor.transform.matrix
                    let right_turn_transform: matrix_float4x4 = if event.isARepeat {
                        rotationAroundYAxisTransform(radians: -turn_speed * 2)
                    } else {
                        rotationAroundYAxisTransform(radians: -turn_speed)
                    }
                    cameraAnchor.transform = Transform(matrix: matrix_multiply(current_transform, right_turn_transform))
                case 126:
                    // 126 = up arrow (neg, X rotation)
                    let current_transform = cameraAnchor.transform.matrix
                    let look_up_transform: matrix_float4x4 = if event.isARepeat {
                        rotationAroundXAxisTransform(radians: -turn_speed * 2)
                    } else {
                        rotationAroundXAxisTransform(radians: -turn_speed)
                    }
                    cameraAnchor.transform = Transform(matrix: matrix_multiply(current_transform, look_up_transform))
                case 125:
                    // 125 = down arrow
                    let current_transform = cameraAnchor.transform.matrix
                    let look_down_transform: matrix_float4x4 = if event.isARepeat {
                        rotationAroundXAxisTransform(radians: turn_speed * 2)
                    } else {
                        rotationAroundXAxisTransform(radians: turn_speed)
                    }
                    cameraAnchor.transform = Transform(matrix: matrix_multiply(current_transform, look_down_transform))
                default:
                    // pass through events to the rest of the responder chain
                    super.keyDown(with: event)
                }
            case let .arcball_direct(useKeys):
                if useKeys {
                    switch event.keyCode {
                    case 123, 0:
                        // 123 = left arrow
                        // 0 = a
                        if event.isARepeat {
                            arcball_state.rotationAngle -= keyspeed * 2
                        } else {
                            arcball_state.rotationAngle -= keyspeed
                        }
                        updateCamera(arcball_state)
                    case 124, 2:
                        // 124 = right arrow
                        // 2 = d
                        if event.isARepeat {
                            arcball_state.rotationAngle += keyspeed * 2
                        } else {
                            arcball_state.rotationAngle += keyspeed
                        }
                        updateCamera(arcball_state)
                    case 126, 13:
                        // 126 = up arrow
                        // 13 = w
                        if arcball_state.inclinationAngle > -Float.pi / 2 {
                            if event.isARepeat {
                                arcball_state.inclinationAngle -= keyspeed * 2
                            } else {
                                arcball_state.inclinationAngle -= keyspeed
                            }
                            updateCamera(arcball_state)
                        }
                    case 125, 1:
                        // 125 = down arrow
                        // 1 = s
                        if arcball_state.inclinationAngle < Float.pi / 2 {
                            if event.isARepeat {
                                arcball_state.inclinationAngle += keyspeed * 2
                            } else {
                                arcball_state.inclinationAngle += keyspeed
                            }
                            updateCamera(arcball_state)
                        }
                    default:
                        // pass through events to the rest of the responder chain
                        super.keyDown(with: event)
                    }
                } else {
                    // pass through events to the rest of the responder chain
                    super.keyDown(with: event)
                }
            case .birdseye:
                // pass through events to the rest of the responder chain
                super.keyDown(with: event)
            }
        }

        override public dynamic func magnify(with event: NSEvent) {
            // Pinching movements (in or out) are gestures meaning zoom out or zoom in (also called magnification).
            if event.phase == NSEvent.Phase.ended {
                print("magnify: \(event)")
            }
            switch motionMode {
            case .arcball, .arcball_direct:
                let multiplier = Float(event.magnification) // magnify_end
                arcball_state.radius = arcball_state.radius * (multiplier + 1)
                updateCamera(arcball_state)
            case .firstperson:
                super.magnify(with: event)
            case .birdseye:
                // pass through events to the rest of the responder chain
                super.magnify(with: event)
            }
        }
    #endif
}
