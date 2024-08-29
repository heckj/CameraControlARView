//  Originally created by Volodymyr Boichentsov on 11/10/2022.
//  Copyright © 2022 3D4Medical, LLC. All rights reserved.
//  Copyright © 2023 Joseph Heck

import Combine
import RealityKit
import SwiftUI

@MainActor
enum Global {
    #if os(iOS)
        static let arContainer = ARViewContainer(cameraARView: CameraControlledARView(frame: .zero, cameraMode: .nonAR))
    #elseif os(macOS)
        static let arContainer = ARViewContainer(cameraARView: CameraControlledARView(frame: .zero))
    #endif
}

/// A SwiftUI RealityKit view that optionally connects a closure you provide to scene events.
///
/// This uses a global variable to create and provide an instance of ``CameraControlledARView``, with the RealityKit scene customizable through the struct ``RealityKitView/Context``.
/// If provided, the instance calls the optional update closure provided to ``init(_:update:)`` when the associated RealityKit scene provides scene events.
///
/// The example below shows creating a view that contains a box:
/// ```swift
/// RealityKitView({ context in
///     let entity = ModelEntity(
///         mesh: .generateBox(
///             size: SIMD3<Float>.init(repeating: 1)
///         )
///     )
///     context.add(entity)
/// }, update: {
///     print("update")
/// })
/// ```
@MainActor
public struct RealityKitView: View {
    /// The context for the RealityKit view.
    @MainActor public struct Context {
        /// A reference to an ARView subclass that you can configure.
        public var arView: CameraControlledARView

        /// The RealityKit scene for this view
        @MainActor public var base: RealityKit.Scene {
            arView.scene
        }

        /// Applies the set of view debugging options that you provide to the RealityKit view.
        /// - Parameter options: The debugging option set for an ARView to apply.
        @MainActor public func applyDebugOptions(_ options: ARView.DebugOptions) {
            arView.debugOptions = options
        }

        /// Adds the entity that you provide at the center of the scene.
        /// - Parameter entity: The entity to add to the scene.
        @MainActor public func add(_ entity: Entity) {
            let originAnchor = AnchorEntity(world: .zero)
            originAnchor.addChild(entity)
            Global.arContainer.cameraARView.scene.anchors.append(originAnchor)
        }
    }

    let context = Context(arView: Global.arContainer.cameraARView)
    var update: (() -> Void)?
    var updateCancellable: (any Cancellable)?

    /// Creates a new RealityKit SwiftUI View using the context you provide.
    /// - Parameters:
    ///   - content: A closure that provides ``Context`` for constructing your scene.
    ///   - update: An optional closure that RealityKit calls when Scene events are triggered.
    @MainActor
    public init(_ content: @escaping (_ context: Context) -> Void, update: (() -> Void)? = nil) {
        content(context)
        self.update = update
        context.arView.updateViewFromState()

        if let update = self.update {
            updateCancellable = Global.arContainer.cameraARView.scene.subscribe(to: SceneEvents.Update.self) { _ in
                update()
            }
        }
    }

    /// The body of the view.
    public var body: some View {
        Global.arContainer
    }
}

struct RealityView_Previews: PreviewProvider {
    static var previews: some View {
        RealityKitView({ context in
            context.arView.motionMode = .arcball_direct(keys: true)

            var sphereMaterial = SimpleMaterial()
            sphereMaterial.roughness = .float(0.0)
            sphereMaterial.metallic = .float(0.3)

            let sphereEntity = ModelEntity(mesh: .generateSphere(radius: 0.5),
                                           materials: [sphereMaterial])

            let sphereAnchor = AnchorEntity(world: .zero)
            sphereAnchor.addChild(sphereEntity)
            context.arView.scene.anchors.append(sphereAnchor)

            let pointLight = PointLight()
            pointLight.light.intensity = 50000
            pointLight.light.color = .red
            pointLight.position.z = 2.0
            sphereAnchor.addChild(pointLight)
        }, update: {
//            print("update")
        }).padding()
        // .frame(width: 300, height: 300)
    }
}
