import XCTest
@testable import SnapshotKit
extension InlineSnapshotsValidityTests {
    func testCreateSnapshotWithShorterExtendedDelimiter2() {
        let diffable = #######"""
        \"""#
        """#######

        _assertInlineSnapshot(matching: diffable, as: .lines, with: ##"""
        \"""#
        """##)
    }
}
