import XCTest
@testable import SnapshotKit
extension InlineSnapshotsValidityTests {
    func testUpdateSnapshotWithShorterExtendedDelimiter2() {
        let diffable = #######"""
        \"""#
        """#######

        _assertInlineSnapshot(matching: diffable, as: .lines, with: ##"""
        \"""#
        """##)
    }
}
