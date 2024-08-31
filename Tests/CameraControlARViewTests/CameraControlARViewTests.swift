import RealityKit
@testable import RenderExamples
import Spatial
import XCTest

final class CameraControlARViewTests: XCTestCase {
    func testInitialArcBallStateTransform() throws {
        let initial = ArcBallState()

        let result: Transform = initial.cameraTransform()

        XCTAssertEqual(result.translation.x, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.translation.y, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.translation.z, 2.0, accuracy: 0.01)

        XCTAssertEqual(result.eulerAngles.x, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.eulerAngles.y, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.eulerAngles.z, 0.0, accuracy: 0.01)

        let heading = headingVector(result)
        XCTAssertEqual(heading.x, 0, accuracy: 0.01)
        XCTAssertEqual(heading.y, 0, accuracy: 0.01)
        XCTAssertEqual(heading.z, -1.0, accuracy: 0.01)
    }

    func testRotatedArcBallStateTransform() throws {
        let initial = ArcBallState(rotationAngle: Float.pi / 2)

        let result: Transform = initial.cameraTransform()

        XCTAssertEqual(result.translation.x, 2.0, accuracy: 0.01)
        XCTAssertEqual(result.translation.y, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.translation.z, 0.0, accuracy: 0.01)

        XCTAssertEqual(result.eulerAngles.x, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.eulerAngles.y, Float.pi / 2.0, accuracy: 0.01)
        XCTAssertEqual(result.eulerAngles.z, 0, accuracy: 0.01)

        let heading = headingVector(result)
        XCTAssertEqual(heading.x, -1.0, accuracy: 0.01)
        XCTAssertEqual(heading.y, 0, accuracy: 0.01)
        XCTAssertEqual(heading.z, 0, accuracy: 0.01)
    }

    func testTranslationViaMatrixMult() throws {
        let initialTranslation = Transform(scale: .one,
                                           rotation: simd_quatf(),
                                           translation: SIMD3<Float>(10, 5, 10))
        let rotate_to_move: Transform = .init(
            pitch: 0.0,
            yaw: 0.0,
            roll: 0
        )
        let translationAfterRotationTransform = Transform(scale: .one,
                                                          rotation: simd_quatf(),
                                                          translation: SIMD3<Float>(0, 0, 5))

        // ORDER of operations is critical here to getting the correct transform:
        // - identity -> rotation -> translation

        // and NOTABLY - you can't multiply two translation matrices together to get
        // them to add in sequence - it's addition for that!
        let computed_transform = initialTranslation.matrix + rotate_to_move.matrix * translationAfterRotationTransform.matrix
        let computedAsTranform = Transform(matrix: computed_transform)
        XCTAssertEqual(computedAsTranform.translation, SIMD3<Float>(10, 5, 15))
    }

    func testTranslationViaMatrixMultRotated() throws {
        let initialTranslation = Transform(scale: .one,
                                           rotation: simd_quatf(),
                                           translation: SIMD3<Float>(10, 5, 10))
        let rotate_to_move: Transform = .init(
            pitch: -Float.pi / 2.0,
            yaw: 0.0,
            roll: 0
        )
        let translationAfterRotationTransform = Transform(scale: .one,
                                                          rotation: simd_quatf(),
                                                          translation: SIMD3<Float>(0, 0, 5))

        // ORDER of operations is critical here to getting the correct transform:
        // - identity -> rotation -> translation

        // and NOTABLY - you can't multiply two translation matrices together to get
        // them to add in sequence - it's addition for that!
        let computed_transform = initialTranslation.matrix + rotate_to_move.matrix * translationAfterRotationTransform.matrix
        let computedAsTranform = Transform(matrix: computed_transform)
        XCTAssertEqual(computedAsTranform.translation.x, 10, accuracy: 0.01)
        XCTAssertEqual(computedAsTranform.translation.y, 10, accuracy: 0.01)
        XCTAssertEqual(computedAsTranform.translation.z, 10, accuracy: 0.01)
    }
}
