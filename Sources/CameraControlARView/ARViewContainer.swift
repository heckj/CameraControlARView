//
//  ARViewContainer.swift
//
//
//  Created by Joseph Heck on 2/9/22.
//

#if os(iOS)
import UIKit
typealias PlatformViewRepresentable = UIViewRepresentable
#elseif os(macOS)
import Cocoa
typealias PlatformViewRepresentable = NSViewRepresentable
#endif
import RealityKit
import SwiftUI

/// A SwiftUI representable view that wraps an underlying augmented reality view with camera controls instance.
///
/// Create an ``CameraControlARView`` externally and hand it into the container so that you can interact with the
/// view controls, or the underlying scene, from within SwiftUI.
public struct ARViewContainer: PlatformViewRepresentable {
    /// The type of view this container wraps.
    public typealias NSViewType = RealityKit.ARView

    /// The wrapped ARView with camera controls enabled.
    public var cameraARView: CameraControlARView

    /// Creates a coordinator to establish the view and to pass updates to and from the SwiftUI context hosting the view.
    public func makeCoordinator() -> ARViewContainer.ARViewCoordinator {
        ARViewCoordinator(self)
    }

    /// Creates a new SwiftUI view.
#if os(iOS)
    public func makeUIView(context _: Context) -> ARView {
        let arView = cameraARView
        return arView
    }
#elseif os(macOS)
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
#endif
    
#if os(iOS)
    /// Updates the wrapped AR view with state information from SwiftUI.
    public func updateUIView(_: ARView, context _: Context) {
        // Updates the state of the specified view with new information from SwiftUI.
    }
#elseif os(macOS)
    /// Updates the wrapped AR view with state information from SwiftUI.
    public func updateNSView(_: ARView, context _: Context) {
        // Updates the state of the specified view with new information from SwiftUI.
    }
#endif

    /// Creates a new SwiftUI view that wraps and displays an augmented reality view.
    /// - Parameter cameraARView: An instance of the camera-controlled AR View.
    public init(cameraARView: CameraControlARView) {
        self.cameraARView = cameraARView
    }

    /// The coordinator object that facilitates to and from the wrapped view.
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
