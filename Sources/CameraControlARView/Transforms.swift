public import RealityKit
import simd

// MARK: - rotational transforms

/// Creates a 3D rotation transform that rotates around the Z axis by the angle that you provide
/// - Parameter radians: The amount (in radians) to rotate around the Z axis.
/// - Returns: A Z-axis rotation transform.
func rotationAroundZAxisTransform(radians: Float) -> simd_float4x4 {
    simd_float4x4(
        SIMD4<Float>(cos(radians), sin(radians), 0, 0),
        SIMD4<Float>(-sin(radians), cos(radians), 0, 0),
        SIMD4<Float>(0, 0, 1, 0),
        SIMD4<Float>(0, 0, 0, 1)
    )
}

/// Creates a 3D rotation transform that rotates around the X axis by the angle that you provide
/// - Parameter radians: The amount (in radians) to rotate around the X axis.
/// - Returns: A X-axis rotation transform.
func rotationAroundXAxisTransform(radians: Float) -> simd_float4x4 {
    simd_float4x4(
        SIMD4<Float>(1, 0, 0, 0),
        SIMD4<Float>(0, cos(radians), sin(radians), 0),
        SIMD4<Float>(0, -sin(radians), cos(radians), 0),
        SIMD4<Float>(0, 0, 0, 1)
    )
}

/// Creates a 3D rotation transform that rotates around the Y axis by the angle that you provide
/// - Parameter radians: The amount (in radians) to rotate around the Y axis.
/// - Returns: A Y-axis rotation transform.
func rotationAroundYAxisTransform(radians: Float) -> simd_float4x4 {
    simd_float4x4(
        SIMD4<Float>(cos(radians), 0, -sin(radians), 0),
        SIMD4<Float>(0, 1, 0, 0),
        SIMD4<Float>(sin(radians), 0, cos(radians), 0),
        SIMD4<Float>(0, 0, 0, 1)
    )
}

/// Returns the rotational transform component from a homogeneous matrix.
/// - Parameter matrix: The homogeneous transform matrix.
/// - Returns: The 3x3 rotation matrix.
func rotationTransform(_ matrix: matrix_float4x4) -> matrix_float3x3 {
    // Extract the rotational component from the transform matrix
    let (col1, col2, col3, _) = matrix.columns
    let rotationTransform = matrix_float3x3(
        simd_float3(x: col1.x, y: col1.y, z: col1.z),
        simd_float3(x: col2.x, y: col2.y, z: col2.z),
        simd_float3(x: col3.x, y: col3.y, z: col3.z)
    )
    return rotationTransform
}

public extension Transform {
    // From: https://stackoverflow.com/questions/50236214/arkit-eulerangles-of-transform-matrix-4x4
    var eulerAngles: SIMD3<Float> {
        let matrix = matrix
        return .init(
            x: asin(-matrix[2][1]),
            y: atan2(matrix[2][0], matrix[2][2]),
            z: atan2(matrix[0][1], matrix[1][1])
        )
    }
}

// MARK: - heading vectors

/// Returns the unit-vector that represents the current heading for the camera.
func headingVector(_ t: Transform) -> simd_float3 {
    // Original heading is assumed to be the camera started out pointing in -Z direction.
    let short_heading_vector = simd_float3(x: 0, y: 0, z: 1)
    let rotated_heading = matrix_multiply(
        rotationTransform(t.matrix),
        short_heading_vector
    )
    return rotated_heading
}

/// Returns the unit-vector that represents the heading 90° to the right of forward for the camera.
func rightVector(_ t: Transform) -> simd_float3 {
    // Original heading is assumed to be the camera started out pointing in -Z direction.
    let short_heading_vector = simd_float3(x: 1, y: 0, z: 0)
    let rotated_heading = matrix_multiply(
        rotationTransform(t.matrix),
        short_heading_vector
    )
    return rotated_heading
}
