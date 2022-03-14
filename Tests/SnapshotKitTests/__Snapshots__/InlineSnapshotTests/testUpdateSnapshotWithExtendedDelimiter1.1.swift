import XCTest
@testable import SnapshotKit
extension InlineSnapshotsValidityTests {
    func testUpdateSnapshotWithExtendedDelimiter1() {
        let diffable = #######"""
        \"
        """#######

        _assertInlineSnapshot(matching: diffable, as: .lines, with: #"""
        \"
        """#)
    }
}
