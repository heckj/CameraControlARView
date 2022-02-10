//
//  ARViewContainer.swift
//
//
//  Created by Joseph Heck on 2/9/22.
//

import Cocoa
import RealityKit
import SwiftUI

/// A SwiftUI representable view that wraps an underlying augmented reality view with camera controls instance.
public struct ARViewContainer: NSViewRepresentable {
    public typealias NSViewType = RealityKit.ARView

    /// The wrapped ARView with camera controls enabled.
    public var cameraARView: CameraControlARView

    public func makeCoordinator() -> ARViewContainer.ARViewCoordinator {
        ARViewCoordinator(self)
    }

    public func makeNSView(context _: Context) -> ARView {
        // Creates the view object and configures its initial state.
        //
        // Context includes:
        // - coordinator
        // - transaction
        // - environment

        let arView = cameraARView
        return arView
    }

    public func updateNSView(_: ARView, context _: Context) {
        // Updates the state of the specified view with new information from SwiftUI.
    }

    public init(cameraARView: CameraControlARView) {
        self.cameraARView = cameraARView
    }

    public class ARViewCoordinator: NSObject {
        /*
         When you want your view controller to coordinate with other SwiftUI views,
         you must provide a Coordinator object to facilitate those interactions.
         For example, you use a coordinator to forward target-action and
         delegate messages from your view controller to any SwiftUI views.
         */
        public var representableContainer: ARViewContainer

        public init(_ representableContainer: ARViewContainer) {
            self.representableContainer = representableContainer
        }
    }
}
