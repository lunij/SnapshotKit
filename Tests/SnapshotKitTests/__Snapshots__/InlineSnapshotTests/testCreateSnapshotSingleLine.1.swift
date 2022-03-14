import XCTest
@testable import SnapshotKit
extension InlineSnapshotsValidityTests {
    func testCreateSnapshotSingleLine() {
        let diffable = #######"""
        NEW_SNAPSHOT
        """#######

        _assertInlineSnapshot(matching: diffable, as: .lines, with: """
        NEW_SNAPSHOT
        """)
    }
}
