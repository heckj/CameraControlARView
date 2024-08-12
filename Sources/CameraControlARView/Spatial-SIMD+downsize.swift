import simd

extension simd_quatd {
    /// Downsizes a SIMD Quaternion from Double to Float values.
    @inlinable
    @inline(__always)
    func downsize() -> simd_quatf {
        return simd_quatf(ix: Float(imag.x), iy: Float(imag.y), iz: Float(imag.z), r: Float(real))
    }
}
