//
//  RealityView.swift
//  CompleteAnatomy
//
//  Created by Volodymyr Boichentsov on 11/10/2022.
//  Copyright © 2022 3D4Medical, LLC. All rights reserved.
//

import Combine
import RealityKit
import SwiftUI

private let arContainer = ARViewContainer(cameraARView: CameraControlARView(frame: .zero))

/// A SwiftUI augmented reality view for macOS or iOS that optionally connects a closure you provide to Scene events.
///
/// RealityKitView extends the default ``CameraControlARView/CameraControlARView``.
public struct RealityKitView: View {
    /// The context for the RealityKit view.
    public struct Context {
        /// An optional RealityKit Scene for the view.
        public var base: RealityKit.Scene?

        /// Adds the entity that you provide at the center of the scene.
        /// - Parameter entity: The entity to add to the scene.
        public func add(_ entity: Entity) {
            let originAnchor = AnchorEntity(world: .zero)
            originAnchor.addChild(entity)
            arContainer.cameraARView.scene.anchors.append(originAnchor)
        }
    }

    let context = Context(base: arContainer.cameraARView.scene)
    var update: (() -> Void)?
    var updateCancellable: Cancellable?

    /// Creates a new RealityKit SwiftUI View using the context you provide.
    /// - Parameters:
    ///   - content: A closure that provides ``Context`` for constructing your scene.
    ///   - update: An optional closure that RealityKit calls when Scene events are triggered.
    public init(_ content: @escaping (_ context: Context) -> Void, update: (() -> Void)? = nil) {
        content(context)
        self.update = update

        if let update = self.update {
            updateCancellable = arContainer.cameraARView.scene.subscribe(to: SceneEvents.Update.self) { _ in
                update()
            }
        }
    }

    public var body: some View {
        arContainer
    }
}

struct RealityView_Previews: PreviewProvider {
    static var previews: some View {
        RealityKitView({ context in
            let entity = ModelEntity(mesh: .generateBox(size: SIMD3<Float>.init(repeating: 1)))
            context.add(entity)
        }, update: {
            print("update")
        }).frame(width: 300, height: 300)
    }
}
