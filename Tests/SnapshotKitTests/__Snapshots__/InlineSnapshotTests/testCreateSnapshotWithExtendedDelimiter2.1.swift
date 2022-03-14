import XCTest
@testable import SnapshotKit
extension InlineSnapshotsValidityTests {
    func testCreateSnapshotWithExtendedDelimiter2() {
        let diffable = #######"""
        \"""#
        """#######

        _assertInlineSnapshot(matching: diffable, as: .lines, with: ##"""
        \"""#
        """##)
    }
}
