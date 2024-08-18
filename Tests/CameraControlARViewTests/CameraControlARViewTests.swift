@testable import CameraControlARView
import RealityKit
import Spatial
import XCTest

final class CameraControlARViewTests: XCTestCase {
    func testInitialArcBallStateTransform() throws {
        let initial = ArcBallState()

        let result: Transform = initial.cameraTransform()

//        print(result)
        XCTAssertEqual(result.translation.x, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.translation.y, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.translation.z, 2.0, accuracy: 0.01)

//        print(result.eulerAngles)
        XCTAssertEqual(result.eulerAngles.x, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.eulerAngles.y, Float.pi, accuracy: 0.01)
        XCTAssertEqual(result.eulerAngles.z, 0, accuracy: 0.01)

        let heading = headingVector(result)
//        print(heading)
        XCTAssertEqual(heading.x, 0, accuracy: 0.01)
        XCTAssertEqual(heading.y, 0, accuracy: 0.01)
        XCTAssertEqual(heading.z, 1.0, accuracy: 0.01)
    }

    func testRotatedArcBallStateTransform() throws {
        let initial = ArcBallState(rotationAngle: Float.pi / 2)

        let result: Transform = initial.cameraTransform()

//        print(result)
        XCTAssertEqual(result.translation.x, 2.0, accuracy: 0.01)
        XCTAssertEqual(result.translation.y, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.translation.z, 0.0, accuracy: 0.01)

//        print(result.eulerAngles)
        XCTAssertEqual(result.eulerAngles.x, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.eulerAngles.y, -Float.pi / 2.0, accuracy: 0.01)
        XCTAssertEqual(result.eulerAngles.z, 0, accuracy: 0.01)

        let expectedHeading = Vector3D(x: 0, y: 0, z: 0) - Vector3D(result.translation)
        let normalized = expectedHeading.normalized
//        print(expectedHeading)
        // print("normalized vector aiming at target: \(normalized)")

        // default rotation
        // print("empty/default rotation \(Rotation3D().eulerAngles(order: __SPEulerAngleOrder.pitchYawRoll))")

//        let expectedDefaultCameraRotation = Rotation3D(angle: Angle2D(degrees: 0),
//                                        axis: .init(x: 0, y: 0, z: -1))
        // print("expected default camera rotation: \(expectedDefaultCameraRotation.eulerAngles(order: __SPEulerAngleOrder.pitchYawRoll))")
//        XCTAssertEqual(Rotation3D(), expectedDefaultCameraRotation)

        // print("trying the forward rotation creation")
        // let fwdRotation = Rotation3D(forward: normalized, up: Vector3D(x: 0, y: 1, z: 0))
        // print(fwdRotation.eulerAngles(order: __SPEulerAngleOrder.pitchYawRoll))

//        print("And this rotation - looking from [2,0,0] to [0,0,0]...")
//        let lookRotation = Rotation3D(position: Point3D(result.translation),
//                                      target: Point3D(x: 0, y: 0, z: 0),
//                                      up: Vector3D(x: 0, y: 1, z: 0))
//        print(lookRotation.eulerAngles(order: __SPEulerAngleOrder.pitchYawRoll))
//
//        let initialHeading = Vector3D(x: 0, y: 0, z: 1) /// 0,0,0 -> 0,0,1
//        let rotatedHeading = initialHeading.rotated(by: lookRotation)
//        print("rotated heading (w/ Spatial) \(rotatedHeading)")
//        print("vector from origin: \(Vector3D(x: 0,y: 0,z: 0)) to \(rotatedHeading)") // [1,0,0]

        let heading = headingVector(result)
//        print(heading)
        XCTAssertEqual(heading.x, -1.0, accuracy: 0.01)
        XCTAssertEqual(heading.y, 0, accuracy: 0.01)
        XCTAssertEqual(heading.z, 0, accuracy: 0.01)
    }
}
