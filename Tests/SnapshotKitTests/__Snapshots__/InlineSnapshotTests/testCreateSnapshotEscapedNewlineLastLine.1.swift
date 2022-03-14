import XCTest
@testable import SnapshotKit
extension InlineSnapshotsValidityTests {
    func testCreateSnapshotEscapedNewlineLastLine() {
        let diffable = #######"""
        abc \
        cde \
        """#######

        _assertInlineSnapshot(matching: diffable, as: .lines, with: #"""
        abc \
        cde \
        """#)
    }
}
