import XCTest
@testable import SnapshotKit
extension InlineSnapshotsValidityTests {
    func testCreateSnapshotWithLongerExtendedDelimiter1() {
        let diffable = #######"""
        \"
        """#######

        _assertInlineSnapshot(matching: diffable, as: .lines, with: #"""
        \"
        """#)
    }
}
