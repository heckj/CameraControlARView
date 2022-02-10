//
//  ExampleARContentView.swift
//
//
//  Created by Joseph Heck on 2/10/22.
//

import CameraControlARView
import Combine
import RealityKit
import SwiftUI
import XCTest

struct ExampleARContentView: View {
    @StateObject var arview: CameraControlARView = {
        let arView = CameraControlARView(frame: .zero)

        // Set ARView debug options
        arView.debugOptions = [
            // .showPhysics,
            .showStatistics,
            // .none
        ]

        // Additional configuration of the scene here.
        // let boxAnchor = try! Experience.loadBox()
        // Add the box anchor to the scene
        // arView.scene.anchors.append(boxAnchor)

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
