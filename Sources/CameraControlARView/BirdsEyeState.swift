public import RealityKit
import simd
import Spatial

/// The representation of camera position and orientation when you hover over a 3D scene.
public struct BirdsEyeState {
    static let defaultHeightConstraint: ClosedRange<Float> = 0.001 ... Float.infinity
    static let defaultDepthConstraint: ClosedRange<Float> = 0.001 ... Float.infinity

    static let defaultXAxisConstraint: ClosedRange<Float> = -Float.infinity ... Float.infinity
    static let defaultZAxisConstraint: ClosedRange<Float> = -Float.infinity ... Float.infinity

    static let defaultRotationConstraint: ClosedRange<Float> = -Float.infinity ... Float.infinity
    static let defaultRadiusConstraint: ClosedRange<Float> = 0.001 ... Float.infinity

    public var heightConstraint: ClosedRange<Float>
    public var depthConstraint: ClosedRange<Float>
    public var xAxisConstraint: ClosedRange<Float>
    public var zAxisConstraint: ClosedRange<Float>
    public var rotationConstraint: ClosedRange<Float>
    public var radiusConstraint: ClosedRange<Float>

    var rotationStart: Float = 0
    var radiusStart: Float = 0

    /// The target for the camera when in lens mode.
    public var target: SIMD3<Float>

    private var _xAxis: Float
    public var xAxis: Float {
        get {
            _xAxis
        }
        set {
            _xAxis = newValue.clamped(to: xAxisConstraint)
        }
    }

    private var _zAxis: Float
    public var zAxis: Float {
        get {
            _zAxis
        }
        set {
            _zAxis = newValue.clamped(to: zAxisConstraint)
        }
    }

    public var radius: Float {
        sqrt(pow(xAxis, 2) + pow(zAxis, 2))
    }

    public var rotation: Float {
        asin(zAxis / radius)
    }

    private var _height: Float
    public var height: Float {
        get {
            _height
        }
        set {
            _height = newValue.clamped(to: heightConstraint)
        }
    }

    private var _depth: Float
    public var depth: Float {
        get {
            _depth
        }
        set {
            _depth = newValue.clamped(to: depthConstraint)
        }
    }

    public var lensFocalPoint: SIMD3<Float> {
        SIMD3<Float>(target.x, target.y - depth, target.z)
    }

    init(target: SIMD3<Float> = SIMD3<Float>(0, 0, 0),
         height: Float = 0,
         depth: Float = 2,
         x: Float = 0,
         z: Float = 0,
         heightConstraint: ClosedRange<Float> = Self.defaultHeightConstraint,
         depthConstraint: ClosedRange<Float> = Self.defaultDepthConstraint,
         xAxisConstraint: ClosedRange<Float> = Self.defaultXAxisConstraint,
         zAxisConstraint: ClosedRange<Float> = Self.defaultZAxisConstraint,
         rotationConstraint: ClosedRange<Float> = Self.defaultRotationConstraint,
         radiusConstraint: ClosedRange<Float> = Self.defaultRadiusConstraint)
    {
        self.heightConstraint = heightConstraint
        self.depthConstraint = depthConstraint
        self.rotationConstraint = rotationConstraint
        self.radiusConstraint = radiusConstraint
        self.xAxisConstraint = xAxisConstraint
        self.zAxisConstraint = zAxisConstraint

        _xAxis = x.clamped(to: xAxisConstraint)
        _zAxis = z.clamped(to: zAxisConstraint)
        _height = height.clamped(to: heightConstraint)
        _depth = depth.clamped(to: depthConstraint)

        self.target = target
    }

    public func cameraTransform() -> Transform {
        let x: Float = xAxis
        let z: Float = zAxis
        let y = target.y + height

        let position = Transform(scale: .one,
                                 rotation: simd_quatf(),
                                 translation: SIMD3(x, y, z)).translation
        let lookRotation = Rotation3D(position: Point3D(position), target: Point3D(lensFocalPoint))
        return Transform(scale: .one, rotation: simd_quatf(lookRotation), translation: position)
    }
}

extension BirdsEyeState: CustomDebugStringConvertible {
    public var debugDescription: String {
        "radius: \(radius), rotation: \(rotation) ([\(xAxis), \(zAxis)]) to target \(lensFocalPoint)"
    }
}
