//
//  ExampleARContentView.swift
//  
//
//  Created by Joseph Heck on 2/10/22.
//

import SwiftUI
import RealityKit
import Combine
import XCTest
import CameraControlARView

struct ExampleARContentView : View {
    @StateObject var arview: CameraControlARView = {
        let arView = CameraControlARView(frame: .zero)
        
        // Set ARView debug options
        arView.debugOptions = [
            //.showPhysics,
            .showStatistics,
            //.none
        ]
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        return arView
    }()
        
    var body: some View {
        ARViewContainer(cameraARView: arview)
    }
}


struct ExampleARContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleARContentView()
    }
}
