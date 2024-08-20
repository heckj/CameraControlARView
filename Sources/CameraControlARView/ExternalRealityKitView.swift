//
//  ExternalRealityKitView.swift
//
//
//  Created by Joseph Heck on 2/10/22.
//

// import CameraControlARView
import Combine
import RealityKit
public import SwiftUI

/// A SwiftUI RealityKit view that uses a instance of CameraControlledARView that you provide.
///
/// Use this view when you want to own the lifetime of the CameraControlledARView instance associated with the view.
/// Configure the view's debugOptions or scene using your own reference to the instance.
///
/// ```swift
/// let arView = CameraControlledARView(frame: .zero)
/// arView.scene = ...
/// arView.debugOptions = [.showStatistics]
///
/// ExternalRealityKitView(realityKitView: arView)
/// ```
///
/// Use ``RealityKitView`` to take advantage of a singleton instance instead, configurable on view initialization.
@available(macOS 11.0, *)
public struct ExternalRealityKitView: View {
    @ObservedObject
    var realityKitView: CameraControlledARView

    public var body: some View {
        ARViewContainer(cameraARView: realityKitView)
    }
}

@available(macOS 11.0, *)
struct ExternalRealityKitView_Previews: PreviewProvider {
    static var previews: some View {
        ExternalRealityKitView(realityKitView: CameraControlledARView(frame: .zero))
    }
}
