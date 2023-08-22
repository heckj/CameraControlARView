/// The representation of camera position and orientation when you orbit a position within a 3D scene.
public struct ArcBallState {
    static let defaultInclinationConstraint: ClosedRange<Float> = (-Float.pi / 2) ... (Float.pi / 2)
    static let defaultRotationConstraint: ClosedRange<Float> = (-Float.pi * 2) ... (Float.pi * 2)
    static let defaultRadiusConstraint: ClosedRange<Float> = 0.0 ... Float.infinity

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

    init(arcballTarget: SIMD3<Float> = SIMD3<Float>(0, 0, 0),
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
}
