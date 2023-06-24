import XCTest
import SnapshotTesting
@testable import TrackerApp

final class TrackerAppTests: XCTestCase {

    func testHomeViewController() {
        let homeVC = HomeViewController(onboarding: nil)
        assertSnapshot(matching: homeVC, as: .image)
    }
}
