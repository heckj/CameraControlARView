//
//  ARViewContainer.swift
//
//
//  Created by Joseph Heck on 2/9/22.
//

import RealityKit
import Cocoa
import SwiftUI

struct ARViewContainer: NSViewRepresentable {
    typealias NSViewType = RealityKit.ARView
    
    var cameraARView: CameraControlARView
    
    class ARViewCoordinator: NSObject {
        /*
         When you want your view controller to coordinate with other SwiftUI views,
         you must provide a Coordinator object to facilitate those interactions.
         For example, you use a coordinator to forward target-action and
         delegate messages from your view controller to any SwiftUI views.
         */
        var representableContainer: ARViewContainer
        
        init(_ representableContainer: ARViewContainer) {
            self.representableContainer = representableContainer
        }
    }
    
    func makeCoordinator() -> ARViewContainer.ARViewCoordinator {
        ARViewCoordinator(self)
    }
    
    func makeNSView(context: Context) -> ARView {
        // Creates the view object and configures its initial state.
        //
        // Context includes:
        // - coordinator
        // - transaction
        // - environment
        
        let arView = cameraARView
        return arView
    }
    
    func updateNSView(_ uiView: ARView, context: Context) {
        // Updates the state of the specified view with new information from SwiftUI.
    }
    
}
