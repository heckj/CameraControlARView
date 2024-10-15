import RealityGeometries
import RealityKit
import Spatial
#if os(iOS)
    import UIKit

    public typealias PlatformColor = UIColor
#elseif os(macOS)
    import AppKit

    public typealias PlatformColor = NSColor
#endif

@MainActor
public enum ProcEntities {
    public static func measuringSpheres(maxX: Float, maxY: Float, maxZ: Float, minStep: Float, middleStep: Float, largeStep: Float) -> ModelEntity {
        var red = PhysicallyBasedMaterial()
        red.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .red)
        red.metallic = 0.0
        var green = PhysicallyBasedMaterial()
        green.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .green)
        green.metallic = 0.0
        var blue = PhysicallyBasedMaterial()
        blue.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .blue)
        blue.metallic = 0.0
        var black = PhysicallyBasedMaterial()
        black.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .black)
        black.metallic = 0.0

        let sphere_1_0 = MeshResource.generateSphere(radius: 1)
        let sphere_0_5 = MeshResource.generateSphere(radius: 0.5)
        let sphere_0_1 = MeshResource.generateSphere(radius: 0.1)

        let baseEntity = ModelEntity(mesh: sphere_1_0, materials: [black])
        baseEntity.position = SIMD3<Float>(0, 0, 0)

        // RED: x
        for xValue in stride(from: minStep, to: maxX, by: minStep) {
            let markerEntity = if xValue.truncatingRemainder(dividingBy: largeStep) < 1.0 {
                ModelEntity(mesh: sphere_1_0, materials: [red])
            } else if xValue.truncatingRemainder(dividingBy: middleStep) < 1.0 {
                ModelEntity(mesh: sphere_0_5, materials: [red])
            } else {
                ModelEntity(mesh: sphere_0_1, materials: [red])
            }
            markerEntity.position = SIMD3<Float>(xValue, 0, 0)
            baseEntity.addChild(markerEntity)
        }
        // GREEN: y
        for yValue in stride<Float>(from: minStep, to: maxY, by: minStep) {
            let markerEntity = if yValue.truncatingRemainder(dividingBy: largeStep) < 1.0 {
                ModelEntity(mesh: sphere_1_0, materials: [green])
            } else if yValue.truncatingRemainder(dividingBy: middleStep) < 1.0 {
                ModelEntity(mesh: sphere_0_5, materials: [green])
            } else {
                ModelEntity(mesh: sphere_0_1, materials: [green])
            }
            markerEntity.position = SIMD3<Float>(0, yValue, 0)
            baseEntity.addChild(markerEntity)
        }
        // BLUE: z
        for zValue in stride<Float>(from: minStep, to: maxZ, by: minStep) {
            let markerEntity = if zValue.truncatingRemainder(dividingBy: largeStep) < 1.0 {
                ModelEntity(mesh: sphere_1_0, materials: [blue])
            } else if zValue.truncatingRemainder(dividingBy: middleStep) < 1.0 {
                ModelEntity(mesh: sphere_0_5, materials: [blue])
            } else {
                ModelEntity(mesh: sphere_0_1, materials: [blue])
            }
            markerEntity.position = SIMD3<Float>(0, 0, zValue)
            baseEntity.addChild(markerEntity)
        }
        baseEntity.name = "measuringSpheres"
        return baseEntity
    }

    public static func axisGizmo(size: Float) -> ModelEntity {
        var red = PhysicallyBasedMaterial()
        red.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .red)
        red.metallic = 0.0

        var green = PhysicallyBasedMaterial()
        green.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .green)
        green.metallic = 0.0

        var blue = PhysicallyBasedMaterial()
        blue.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .blue)
        blue.metallic = 0.0

        var black = PhysicallyBasedMaterial()
        black.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .black)
        black.metallic = 0.0

        let sphere_0_1 = MeshResource.generateSphere(radius: size / 10)
        let baseEntity = ModelEntity(mesh: sphere_0_1, materials: [black])
        baseEntity.position = SIMD3<Float>(0, 0, 0)

        let coneMesh = try! RealityGeometry.generateCone(radius: size / 6, height: size / 2)
        let stemMesh = try! RealityGeometry.generateCylinder(radius: size / 10, height: size / 2, sides: 6)

        // X: RED
        let xRotation = Rotation3D(angle: .radians(-.pi / 2), axis: RotationAxis3D.z)

        let coneX = ModelEntity(mesh: coneMesh, materials: [red])
        coneX.transform = Transform(rotation: simd_quatf(xRotation))
        coneX.position = SIMD3<Float>(size / 2, 0, 0)

        let stemX = ModelEntity(mesh: stemMesh, materials: [red])
        stemX.transform = Transform(rotation: simd_quatf(xRotation))
        stemX.position = SIMD3<Float>(size / 4, 0, 0)

        baseEntity.addChild(stemX)
        baseEntity.addChild(coneX)

        // Y: GREEN
        let coneY = ModelEntity(mesh: coneMesh, materials: [green])
        coneY.position = SIMD3<Float>(0, size / 2, 0)

        let stemY = ModelEntity(mesh: stemMesh, materials: [green])
        stemY.position = SIMD3<Float>(0, size / 4, 0)

        baseEntity.addChild(stemY)
        baseEntity.addChild(coneY)

        // Z: BLUE
        let zRotation = Rotation3D(angle: .radians(.pi / 2), axis: RotationAxis3D.x)

        let coneZ = ModelEntity(mesh: coneMesh, materials: [blue])
        coneZ.transform = Transform(rotation: simd_quatf(zRotation))
        coneZ.position = SIMD3<Float>(0, 0, size / 2)

        let stemZ = ModelEntity(mesh: stemMesh, materials: [blue])
        stemZ.transform = Transform(rotation: simd_quatf(zRotation))
        stemZ.position = SIMD3<Float>(0, 0, size / 4)

        baseEntity.addChild(stemZ)
        baseEntity.addChild(coneZ)

        baseEntity.name = "gizmo"
        return baseEntity
    }

    public static func sphere(radius: Float, color: PlatformColor, position: simd_float3? = nil) -> ModelEntity {
        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: color)
        material.metallic = 0.0
        let entity = ModelEntity(mesh: .generateSphere(radius: radius), materials: [material])
        if let position {
            entity.position = position
        }
        return entity
    }

    public static func floorPlane(color: PlatformColor, width: Int, depth: Int, position: simd_float3? = nil) -> ModelEntity {
        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: color)
        material.metallic = 0.0
        let entity = ModelEntity(
            mesh: .generatePlane(width: Float(width), depth: Float(depth)),
            materials: [material]
        )
        if let position {
            entity.position = position
        }
        return entity
    }

    public static func cube(color: PlatformColor, size: Float,
                            glowColor: PlatformColor? = nil, intensity: Float = 0.0,
                            name: String? = nil, opacity: Float = 1.0,
                            position: simd_float3? = nil) -> ModelEntity
    {
        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: color)
        material.metallic = 0.0
        material.blending = .transparent(opacity: .init(floatLiteral: opacity))

        if let glowColor, intensity > 0.0 {
            material.emissiveColor = PhysicallyBasedMaterial.EmissiveColor(color: glowColor)
            material.emissiveIntensity = intensity
        }

        let entity = ModelEntity(
            mesh: .generateBox(size: size),
            materials: [material]
        )
        if let name {
            entity.name = name
        }
        if let position {
            entity.position = position
        }
        return entity
    }
}
