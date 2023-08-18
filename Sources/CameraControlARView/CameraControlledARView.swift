//
//  CameraControlledARView.swift
//
//
//  Created by Joseph Heck on 2/7/22.
//

#if os(iOS)
    import ARKit
    import UIKit
#endif
#if os(macOS)
    import AppKit
#endif
import CoreGraphics
import Foundation
import RealityKit

/// A 3D View for SwiftUI using RealityKit that provides movement controls for the camera within the view.
///
/// Initialize a new instance with `init()` or `init(frame:)` on macOS, `init(frame:cameraMode:)` on iOS.
/// The ARView creates and maintains the scene associated with the view upon initialization.
///
/// Once the view is initialized, configure the scene by updating it with entities attached to anchors, or apply view debugging
/// options through the `debugOptions` property.
///
/// Set the ``CameraControlledARView/motionMode-swift.property`` to define the motion controls.
/// - ``MotionMode-swift.enum/arcball`` for rotating around a specific point.
/// - ``MotionMode-swift.enum/firstperson`` for moving freely within the environment.
///
/// The default motion mode is ``MotionMode-swift.enum/arcball``.
///
/// When used on iOS, a pinch gesture is automatically registered for interaction.
///
/// Additional properties control the target location, the camera's location, or the speed of movement within the environment.
@objc public final class CameraControlledARView: ARView, ObservableObject {

    /// The mode in which the camera is controlled by keypresses and/or mouse and gesture movements.
    ///
    /// The default option is ``MotionMode-swift.enum/arcball``:
    /// - ``MotionMode-swift.enum/arcball`` rotates around a specific target location, effectively orbiting and keeping the camera trained on that location.
    /// - ``MotionMode-swift.enum/firstperson`` moves freely in all axis within the world space, not locked to any location.
    ///
    public var motionMode: MotionMode

    // TODO: consider encapsulating all these values into a single struct to allow for assigning consolidated values.

    // MARK: - ARCBALL mode variables

    /// The target for the camera when in arcball mode.
    public var arcballTarget: simd_float3 {
        didSet {
            if motionMode == .arcball {
                updateCamera()
            }
        }
    }

    /// The angle of inclination of the camera when in arcball mode.
    public var inclinationAngle: Float {
        didSet {
            if motionMode == .arcball {
                updateCamera()
            }
        }
    }

    /// The angle of rotation of the camera when in arcball mode.
    public var rotationAngle: Float {
        didSet {
            if motionMode == .arcball {
                updateCamera()
            }
        }
    }

    /// The camera's orbital distance from the target when in arcball mode.
    public var radius: Float {
        didSet {
            if motionMode == .arcball {
                updateCamera()
            }
        }
    }

    /// The speed at which drag operations map percentage of movement within the view to rotational or positional updates.
    public var dragspeed: Float

    /// The speed at which keypresses change the angles of inclination or rotation.
    ///
    /// This view doubles the speed value when the key is held-down.
    public var keyspeed: Float

    private var dragstart: CGPoint
    private var dragstart_rotation: Float
    private var dragstart_inclination: Float
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
            radius = radius * (multiplier + 1)
            updateCamera()
        }
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
        motionMode = .arcball

        // ARCBALL mode
        arcballTarget = simd_float3(0, 0, 0)
        inclinationAngle = 0
        rotationAngle = 0
        radius = 2
        keyspeed = 0.01
        dragspeed = 0.01
        dragstart_rotation = 0
        dragstart_inclination = 0
        magnify_start = radius

        // FPS mode
        forward_speed = 0.05
        turn_speed = 0.01

        // Not mode specific
        cameraAnchor = AnchorEntity(world: .zero)
        dragstart = CGPoint.zero
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
        
        updateCamera()

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
        motionMode = .arcball

        // ARCBALL mode
        arcballTarget = simd_float3(0, 0, 0)
        inclinationAngle = 0
        rotationAngle = 0
        radius = 2
        keyspeed = 0.01
        dragspeed = 0.01
        dragstart_rotation = 0
        dragstart_inclination = 0
        magnify_start = radius

        // FPS mode
        forward_speed = 0.05
        turn_speed = 0.01

        // Not mode specific
        cameraAnchor = AnchorEntity(world: .zero)
        dragstart = CGPoint.zero
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
        updateCamera()

        #if os(iOS)
            pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchRecognized(_:)))
            addGestureRecognizer(pinchGesture!)
        #endif
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - rotational transforms

    /// Creates a 3D rotation transform that rotates around the Z axis by the angle that you provide
    /// - Parameter radians: The amount (in radians) to rotate around the Z axis.
    /// - Returns: A Z-axis rotation transform.
    private func rotationAroundZAxisTransform(radians: Float) -> simd_float4x4 {
        return simd_float4x4(
            SIMD4<Float>(cos(radians), sin(radians), 0, 0),
            SIMD4<Float>(-sin(radians), cos(radians), 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
    }

    /// Creates a 3D rotation transform that rotates around the X axis by the angle that you provide
    /// - Parameter radians: The amount (in radians) to rotate around the X axis.
    /// - Returns: A X-axis rotation transform.
    private func rotationAroundXAxisTransform(radians: Float) -> simd_float4x4 {
        return simd_float4x4(
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, cos(radians), sin(radians), 0),
            SIMD4<Float>(0, -sin(radians), cos(radians), 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
    }

    /// Creates a 3D rotation transform that rotates around the Y axis by the angle that you provide
    /// - Parameter radians: The amount (in radians) to rotate around the Y axis.
    /// - Returns: A Y-axis rotation transform.
    private func rotationAroundYAxisTransform(radians: Float) -> simd_float4x4 {
        return simd_float4x4(
            SIMD4<Float>(cos(radians), 0, -sin(radians), 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(sin(radians), 0, cos(radians), 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
    }

    /// Returns the rotational transform component from a homogeneous matrix.
    /// - Parameter matrix: The homogeneous transform matrix.
    /// - Returns: The 3x3 rotation matrix.
    private func rotationTransform(_ matrix: matrix_float4x4) -> matrix_float3x3 {
        // Extract the rotational component from the transform matrix
        let (col1, col2, col3, _) = matrix.columns
        let rotationTransform = matrix_float3x3(
            simd_float3(x: col1.x, y: col1.y, z: col1.z),
            simd_float3(x: col2.x, y: col2.y, z: col2.z),
            simd_float3(x: col3.x, y: col3.y, z: col3.z)
        )
        return rotationTransform
    }

    // MARK: - heading vectors

    /// Returns the unit-vector that represents the current heading for the camera.
    private func headingVector() -> simd_float3 {
        // Original heading is assumed to be the camera started out pointing in -Z direction.
        let short_heading_vector = simd_float3(x: 0, y: 0, z: -1)
        let rotated_heading = matrix_multiply(
            rotationTransform(cameraAnchor.transform.matrix),
            short_heading_vector
        )
        return rotated_heading
    }

    /// Returns the unit-vector that represents the heading 90° to the right of forward for the camera.
    private func rightVector() -> simd_float3 {
        // Original heading is assumed to be the camera started out pointing in -Z direction.
        let short_heading_vector = simd_float3(x: 1, y: 0, z: 0)
        let rotated_heading = matrix_multiply(
            rotationTransform(cameraAnchor.transform.matrix),
            short_heading_vector
        )
        return rotated_heading
    }

    @MainActor private func updateCamera() {
        switch motionMode {
        case .arcball:
            let translationTransform = Transform(scale: .one,
                                                 rotation: simd_quatf(),
                                                 translation: SIMD3<Float>(0, 0, radius))
            let combinedRotationTransform: Transform = .init(pitch: inclinationAngle, yaw: rotationAngle, roll: 0)

            // ORDER of operations is critical here to getting the correct transform:
            // - identity -> rotation -> translation
            let computed_transform = matrix_identity_float4x4 * combinedRotationTransform.matrix * translationTransform.matrix

            // This moves the camera to the right location
            cameraAnchor.transform = Transform(matrix: computed_transform)
            // This spins the camera AT its current location to look at a specific target location
            cameraAnchor.look(at: arcballTarget, from: cameraAnchor.transform.translation, relativeTo: nil)
            // reflect the camera's transform as an observed object
            macOSCameraTransform = cameraAnchor.transform
        case .firstperson:
            break
        }
    }
    
    func dragStart() {
        switch motionMode {
        case .arcball:
            dragstart_rotation = rotationAngle
            dragstart_inclination = inclinationAngle
        case .firstperson:
            dragstart_transform = cameraAnchor.transform.matrix
        }
    }

    func dragMove(_ deltaX: Float, _ deltaY: Float) {
        switch motionMode {
        case .arcball:
            rotationAngle = dragstart_rotation - deltaX * dragspeed
            inclinationAngle = dragstart_inclination + deltaY * dragspeed
            if inclinationAngle > Float.pi / 2 {
                inclinationAngle = Float.pi / 2
            }
            if inclinationAngle < -Float.pi / 2 {
                inclinationAngle = -Float.pi / 2
            }
            updateCamera()
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
        }
    }

    #if os(iOS)
    override public dynamic func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
            dragstart = touches.first!.location(in: self)
            dragStart()
        }

    override public dynamic func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
            let drag = touches.first!.location(in: self)
            let deltaX = Float(drag.x - dragstart.x)
            let deltaY = Float(dragstart.y - drag.y)
            dragMove(deltaX, deltaY)
        }
    #endif

    #if os(macOS)
    override public dynamic func mouseDown(with event: NSEvent) {
            // print("mouseDown EVENT: \(event)")
            // print(" at \(event.locationInWindow) of \(self.frame)")
            dragstart = event.locationInWindow
            dragStart()
        }

    override public dynamic func mouseDragged(with event: NSEvent) {
            // print("mouseDragged EVENT: \(event)")
            // print(" at \(event.locationInWindow) of \(self.frame)")
            let deltaX = Float(event.locationInWindow.x - dragstart.x)
            let deltaY = Float(event.locationInWindow.y - dragstart.y)
            dragMove(deltaX, deltaY)
        }

    override public dynamic func keyDown(with event: NSEvent) {
            // print("keyDown: \(event)")
            // print("key value: \(event.keyCode)")
            switch motionMode {
            case .arcball:
                switch event.keyCode {
                case 123, 0:
                    // 123 = left arrow
                    // 0 = a
                    if event.isARepeat {
                        rotationAngle -= keyspeed * 2
                    } else {
                        rotationAngle -= keyspeed
                    }
                    updateCamera()
                case 124, 2:
                    // 124 = right arrow
                    // 2 = d
                    if event.isARepeat {
                        rotationAngle += keyspeed * 2
                    } else {
                        rotationAngle += keyspeed
                    }
                    updateCamera()
                case 126, 13:
                    // 126 = up arrow
                    // 13 = w
                    if inclinationAngle > -Float.pi / 2 {
                        if event.isARepeat {
                            inclinationAngle -= keyspeed * 2
                        } else {
                            inclinationAngle -= keyspeed
                        }
                        updateCamera()
                    }
                case 125, 1:
                    // 125 = down arrow
                    // 1 = s
                    if inclinationAngle < Float.pi / 2 {
                        if event.isARepeat {
                            inclinationAngle += keyspeed * 2
                        } else {
                            inclinationAngle += keyspeed
                        }
                        updateCamera()
                    }
                default:
                    break
                }

            case .firstperson:
                switch event.keyCode {
                case 0:
                    // 0 = a (move left)
                    if event.isARepeat {
                        cameraAnchor.position = cameraAnchor.position - (rightVector() * forward_speed * 2)
                    } else {
                        cameraAnchor.position = cameraAnchor.position - (rightVector() * forward_speed)
                    }
                case 2:
                    // 2 = d (move right)
                    if event.isARepeat {
                        cameraAnchor.position = cameraAnchor.position + (rightVector() * forward_speed * 2)
                    } else {
                        cameraAnchor.position = cameraAnchor.position + (rightVector() * forward_speed)
                    }
                case 13:
                    // 13 = w (move forward)
                    if event.isARepeat {
                        cameraAnchor.position = cameraAnchor.position + (headingVector() * forward_speed * 2)
                    } else {
                        cameraAnchor.position = cameraAnchor.position + (headingVector() * forward_speed)
                    }
                case 1:
                    // 1 = s (move back)
                    if event.isARepeat {
                        cameraAnchor.position = cameraAnchor.position - (headingVector() * forward_speed * 2)
                    } else {
                        cameraAnchor.position = cameraAnchor.position - (headingVector() * forward_speed)
                    }
                case 123:
                    // 123 = left arrow (turn left)
                    let current_transform = cameraAnchor.transform.matrix
                    let left_turn_transform: matrix_float4x4
                    if event.isARepeat {
                        left_turn_transform = rotationAroundYAxisTransform(radians: turn_speed * 2)
                    } else {
                        left_turn_transform = rotationAroundYAxisTransform(radians: turn_speed)
                    }
                    cameraAnchor.transform = Transform(matrix: matrix_multiply(current_transform, left_turn_transform))
                case 124:
                    // 124 = right arrow (turn right)
                    let current_transform = cameraAnchor.transform.matrix
                    let right_turn_transform: matrix_float4x4
                    if event.isARepeat {
                        right_turn_transform = rotationAroundYAxisTransform(radians: -turn_speed * 2)
                    } else {
                        right_turn_transform = rotationAroundYAxisTransform(radians: -turn_speed)
                    }
                    cameraAnchor.transform = Transform(matrix: matrix_multiply(current_transform, right_turn_transform))
                case 126:
                    // 126 = up arrow (neg, X rotation)
                    let current_transform = cameraAnchor.transform.matrix
                    let look_up_transform: matrix_float4x4
                    if event.isARepeat {
                        look_up_transform = rotationAroundXAxisTransform(radians: -turn_speed * 2)
                    } else {
                        look_up_transform = rotationAroundXAxisTransform(radians: -turn_speed)
                    }
                    cameraAnchor.transform = Transform(matrix: matrix_multiply(current_transform, look_up_transform))
                case 125:
                    // 125 = down arrow
                    let current_transform = cameraAnchor.transform.matrix
                    let look_down_transform: matrix_float4x4
                    if event.isARepeat {
                        look_down_transform = rotationAroundXAxisTransform(radians: turn_speed * 2)
                    } else {
                        look_down_transform = rotationAroundXAxisTransform(radians: turn_speed)
                    }
                    cameraAnchor.transform = Transform(matrix: matrix_multiply(current_transform, look_down_transform))
                default:
                    break
                }
            }
        }

    override public dynamic func magnify(with event: NSEvent) {
            // if event.phase == NSEvent.Phase.ended {
            //    print("magnify: \(event)")
            // }
            switch motionMode {
            case .arcball:
                let multiplier = Float(event.magnification) // magnify_end
                radius = radius * (multiplier + 1)
                updateCamera()
            case .firstperson:
                break
            }
        }
    #endif
}
