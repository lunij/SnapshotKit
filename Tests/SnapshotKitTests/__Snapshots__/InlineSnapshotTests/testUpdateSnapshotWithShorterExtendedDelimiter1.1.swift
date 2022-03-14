import XCTest
@testable import SnapshotKit
extension InlineSnapshotsValidityTests {
    func testUpdateSnapshotWithShorterExtendedDelimiter1() {
        let diffable = #######"""
        \"
        """#######

        _assertInlineSnapshot(matching: diffable, as: .lines, with: #"""
        \"
        """#)
    }
}
