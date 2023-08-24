import simd

public struct GridLensState {
    static let defaultHeightConstraint: ClosedRange<Float> = 0 ... Float.infinity
    static let defaultDepthConstraint: ClosedRange<Float> = 0 ... Float.infinity
    static let defaultXConstraint: ClosedRange<Float> = -Float.infinity ... Float.infinity
    static let defaultZConstraint: ClosedRange<Float> = -Float.infinity ... Float.infinity

    public var heightConstraint: ClosedRange<Float>
    public var depthConstraint: ClosedRange<Float>
    public var xConstraint: ClosedRange<Float>
    public var zConstraint: ClosedRange<Float>

    /// The target for the camera when in lens mode.
    public var lensFocalPoint: simd_float3

    private var _x: Float
    public var x: Float {
        get {
            return _x
        }
        set {
            _x = newValue.clamped(to: xConstraint)
        }
    }

    private var _z: Float
    public var z: Float {
        get {
            return _z
        }
        set {
            _z = newValue.clamped(to: zConstraint)
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

    init(lensFocalPoint: simd_float3 = simd_float3(0, 0, 0),
         radius: Float = 2,
         height: Float = 0,
         depth: Float = 2,
         rotationAngle: Float = 0,
         heightConstraint: ClosedRange<Float> = Self.defaultHeightConstraint,
         depthConstraint: ClosedRange<Float> = Self.defaultDepthConstraint,
         xConstraint: ClosedRange<Float> = Self.defaultXConstraint,
         zConstraint: ClosedRange<Float> = Self.defaultZConstraint)
    {
        self.heightConstraint = heightConstraint
        self.depthConstraint = depthConstraint
        self.xConstraint = xConstraint
        self.zConstraint = zConstraint

        _x = radius.clamped(to: xConstraint)
        _z = rotationAngle.clamped(to: zConstraint)
        _height = height.clamped(to: heightConstraint)
        _depth = depth.clamped(to: depthConstraint)

        self.lensFocalPoint = lensFocalPoint
    }
}
