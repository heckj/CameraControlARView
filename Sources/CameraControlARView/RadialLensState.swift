import simd

public struct RadialLensState {
    static let defaultHeightConstraint: ClosedRange<Float> = 0.001 ... Float.infinity
    static let defaultDepthConstraint: ClosedRange<Float> = 0.001 ... Float.infinity
    static let defaultRotationConstraint: ClosedRange<Float> = -Float.infinity ... Float.infinity
    static let defaultRadiusConstraint: ClosedRange<Float> = 0.001 ... Float.infinity

    public var heightConstraint: ClosedRange<Float>
    public var depthConstraint: ClosedRange<Float>
    public var rotationConstraint: ClosedRange<Float>
    public var radiusConstraint: ClosedRange<Float>

    /// The target for the camera when in lens mode.
    public var target: simd_float3

    private var _radius: Float
    public var radius: Float {
        get {
            return _radius
        }
        set {
            _radius = newValue.clamped(to: radiusConstraint)
        }
    }

    private var _rotation: Float
    public var rotation: Float {
        get {
            return _rotation
        }
        set {
            _rotation = newValue.clamped(to: rotationConstraint)
        }
    }

    private var _height: Float
    public var height: Float {
        get {
            return _height
        }
        set {
            _height = newValue.clamped(to: heightConstraint)
        }
    }

    private var _depth: Float
    public var depth: Float {
        get {
            return _depth
        }
        set {
            _depth = newValue.clamped(to: depthConstraint)
        }
    }

    public var lensFocalPoint: simd_float3 {
        return simd_float3(target.x, target.y - depth, target.z)
    }

    init(target: simd_float3 = simd_float3(0, 0, 0),
         radius: Float = 2,
         height: Float = 0,
         depth: Float = 2,
         rotationAngle: Float = 0,
         heightConstraint: ClosedRange<Float> = Self.defaultHeightConstraint,
         depthConstraint: ClosedRange<Float> = Self.defaultDepthConstraint,
         rotationConstraint: ClosedRange<Float> = Self.defaultRotationConstraint,
         radiusConstraint: ClosedRange<Float> = Self.defaultRadiusConstraint)
    {
        self.heightConstraint = heightConstraint
        self.depthConstraint = depthConstraint
        self.rotationConstraint = rotationConstraint
        self.radiusConstraint = radiusConstraint

        _radius = radius.clamped(to: radiusConstraint)
        _rotation = rotationAngle.clamped(to: rotationConstraint)
        _height = height.clamped(to: heightConstraint)
        _depth = depth.clamped(to: depthConstraint)

        self.target = target
    }
}
