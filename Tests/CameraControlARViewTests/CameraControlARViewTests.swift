@testable import CameraControlARView
import XCTest

final class CameraControlARViewTests: XCTestCase {
    func testExample() throws {
        #if os(macOS)
            XCTAssertNotNil(CameraControlledARView())
        #endif
    }
}
