import XCTest
@testable import SnapshotKit
extension InlineSnapshotsValidityTests {
    func testCreateSnapshotWithShorterExtendedDelimiter1() {
        let diffable = #######"""
        \"
        """#######

        _assertInlineSnapshot(matching: diffable, as: .lines, with: #"""
        \"
        """#)
    }
}
