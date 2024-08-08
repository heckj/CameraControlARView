import RealityKit
import Spatial

/// The representation of camera position and orientation when you orbit a position within a 3D scene.
public struct ArcBallState: Sendable {
    public static let defaultInclinationConstraint: ClosedRange<Float> = (-Float.pi / 2) ... (Float.pi / 2)
    public static let defaultRotationConstraint: ClosedRange<Float> = (-Float.pi * 2) ... (Float.pi * 2)
    public static let defaultRadiusConstraint: ClosedRange<Float> = 0.0 ... Float.infinity

    public var inclinationConstraint: ClosedRange<Float>
    public var rangeConstraint: ClosedRange<Float>
    public var rotationConstraint: ClosedRange<Float>
    /// The target for the camera when in arcball mode.
    public var arcballTarget: SIMD3<Float>

    var movestart_rotation: Float = 0
    var movestart_inclination: Float = 0

    private var _radius: Float
    /// The camera's orbital distance from the target when in arcball mode.
    public var radius: Float {
        get {
            return _radius
        }
        set {
            _radius = newValue.clamped(to: rangeConstraint)
        }
    }

    private var _inclination: Float
    /// The angle of inclination of the camera when in arcball mode.
    public var inclinationAngle: Float {
        get {
            return _inclination
        }
        set {
            _inclination = newValue.clamped(to: inclinationConstraint)
        }
    }

    private var _rotation: Float
    /// The angle of rotation of the camera when in arcball mode.
    public var rotationAngle: Float {
        get {
            return _rotation
        }
        set {
            _rotation = newValue.clamped(to: rotationConstraint)
        }
    }

    public init(arcballTarget: SIMD3<Float> = SIMD3<Float>(0, 0, 0),
                radius: Float = 2,
                inclinationAngle: Float = 0,
                rotationAngle: Float = 0,
                inclinationConstraint: ClosedRange<Float> = Self.defaultInclinationConstraint,
                rotationConstraint: ClosedRange<Float> = Self.defaultRotationConstraint,
                radiusConstraint: ClosedRange<Float> = Self.defaultRadiusConstraint)
    {
        self.inclinationConstraint = inclinationConstraint
        rangeConstraint = radiusConstraint
        self.rotationConstraint = rotationConstraint

        _radius = radius.clamped(to: radiusConstraint)
        _inclination = inclinationAngle.clamped(to: inclinationConstraint)
        _rotation = rotationAngle.clamped(to: rotationConstraint)

        self.arcballTarget = arcballTarget
    }

    public func cameraTransform() -> Transform {
        let translationTransform = Transform(scale: .one,
                                             rotation: simd_quatf(),
                                             translation: SIMD3<Float>(0, 0, radius))
        let rotate_to_move: Transform = .init(
            pitch: inclinationAngle,
            yaw: rotationAngle,
            roll: 0
        )

        // ORDER of operations is critical here to getting the correct transform:
        // - identity -> rotation -> translation
        let computed_transform = matrix_identity_float4x4 * rotate_to_move.matrix * translationTransform.matrix
        // We only care about the position for the camera
        let position: SIMD3<Float> = Transform(matrix: computed_transform).translation

        // For the rest, we look at the target position - using the Spatial library, but it's annoyingly
        // set to ONLY return double formats, so we screw with it to fit...
        let lookRotation = Rotation3D(position: Point3D(position), target: Point3D(arcballTarget))
        let bigQuat = lookRotation.quaternion
        let smallQuat = simd_quatf(ix: Float(bigQuat.imag.x), iy: Float(bigQuat.imag.y), iz: Float(bigQuat.imag.z), r: Float(bigQuat.real))

        return Transform(scale: .one, rotation: smallQuat, translation: position)
    }
}
