import CameraControlARView
import RealityKit
import SwiftUI

@MainActor
struct ARContentView: View {
    @State private var arcballState: ArcBallState

    init() {
        let side: Float = 10.0
        let height: Float = 5.0
        arcballState = ArcBallState(arcballTarget: SIMD3<Float>(side / 2.0, height / 2.0, side / 2.0),
                                    radius: side * 1.2,
                                    inclinationAngle: -Float.pi / 8.0, // around X, slightly "up"
                                    rotationAngle: 0.0, // around Y
                                    inclinationConstraint: -Float.pi / 2 ... 0, // 0 ... 90° 'up'
                                    radiusConstraint: 0.1 ... side * 2.0)
    }

    var body: some View {
        VStack {
            RealityKitView { content in
                // set the motion controls to use scrolling gestures, and allow keyboard support
                content.arView.motionMode = .arcball(keys: true)
                content.arView.arcball_state = arcballState

                // print("camera anchor position: \(content.arView.cameraAnchor.position)")
                let floor = ProcEntities.floorPlane(color: .gray, width: 10, depth: 10)
                floor.position = .init(x: 5.0, y: 0.0, z: 5.0)
                content.add(floor)

                let measuringSpheres = ProcEntities.measuringSpheres(maxX: 50, maxY: 10, maxZ: 50, minStep: 1, middleStep: 10, largeStep: 50)
                content.add(measuringSpheres)

//                let cube = ProcEntities.cube(color: .red, size: 2.0,
//                                             //glowColor: .red, intensity: 2.8,
//                                             opacity: 1.0)
//                cube.position = .init(x: 1, y: 1, z: 1)
//                content.add(cube)

                let gizmo = ProcEntities.axisGizmo(size: 2)
                gizmo.position = .init(x: -2, y: -2, z: -2)
                content.add(gizmo)
            }
            Text("CameraControl Example")
        }
        .padding()
    }
}

#Preview {
    ARContentView()
}
