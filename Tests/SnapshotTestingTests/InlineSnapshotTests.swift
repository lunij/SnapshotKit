import XCTest
@testable import SnapshotTesting

class InlineSnapshotTests: XCTestCase {
    func testCreateSnapshotSingleLine() throws {
        let diffable = "NEW_SNAPSHOT"
        let source = """
        _assertInlineSnapshot(matching: diffable, as: .lines, with: "")
        """

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testCreateSnapshotMultiLine() throws {
        let diffable = "NEW_SNAPSHOT"
        let source = #"""
        _assertInlineSnapshot(matching: diffable, as: .lines, with: """
        """)
        """#

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testUpdateSnapshot() throws {
        let diffable = "NEW_SNAPSHOT"
        let source = #"""
        _assertInlineSnapshot(matching: diffable, as: .lines, with: """
        OLD_SNAPSHOT
        """)
        """#

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testUpdateSnapshotWithMoreLines() throws {
        let diffable = "NEW_SNAPSHOT\nNEW_SNAPSHOT"
        let source = #"""
        _assertInlineSnapshot(matching: diffable, as: .lines, with: """
        OLD_SNAPSHOT
        """)
        """#

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testUpdateSnapshotWithLessLines() throws {
        let diffable = "NEW_SNAPSHOT"
        let source = #"""
        _assertInlineSnapshot(matching: diffable, as: .lines, with: """
        OLD_SNAPSHOT
        OLD_SNAPSHOT
        """)
        """#

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testCreateSnapshotWithExtendedDelimiterSingleLine1() throws {
        let diffable = #"\""#
        let source = """
        _assertInlineSnapshot(matching: diffable, as: .lines, with: "")
        """

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testCreateSnapshotEscapedNewlineLastLine() throws {
        let diffable = #"""
        abc \
        cde \
        """#
        let source = """
        _assertInlineSnapshot(matching: diffable, as: .lines, with: "")
        """

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testCreateSnapshotWithExtendedDelimiterSingleLine2() throws {
        let diffable = ##"\"""#"##
        let source = ##"""
        _assertInlineSnapshot(matching: diffable, as: .lines, with: "")
        """##

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testCreateSnapshotWithExtendedDelimiter1() throws {
        let diffable = #"\""#
        let source = ##"""
        _assertInlineSnapshot(matching: diffable, as: .lines, with: #"""
        """#)
        """##

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testCreateSnapshotWithExtendedDelimiter2() throws {
        let diffable = ##"\"""#"##
        let source = ###"""
        _assertInlineSnapshot(matching: diffable, as: .lines, with: ##"""
        """##)
        """###

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testCreateSnapshotWithLongerExtendedDelimiter1() throws {
        let diffable = #"\""#
        let source = ###"""
        _assertInlineSnapshot(matching: diffable, as: .lines, with: ##"""
        """##)
        """###

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testCreateSnapshotWithLongerExtendedDelimiter2() throws {
        let diffable = ##"\"""#"##
        let source = ####"""
        _assertInlineSnapshot(matching: diffable, as: .lines, with: ###"""
        """###)
        """####

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testCreateSnapshotWithShorterExtendedDelimiter1() throws {
        let diffable = #"\""#
        let source = #"""
        _assertInlineSnapshot(matching: diffable, as: .lines, with: """
        """)
        """#

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testCreateSnapshotWithShorterExtendedDelimiter2() throws {
        let diffable = ##"\"""#"##
        let source = ##"""
        _assertInlineSnapshot(matching: diffable, as: .lines, with: #"""
        """#)
        """##

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testUpdateSnapshotWithExtendedDelimiter1() throws {
        let diffable = #"\""#
        let source = ##"""
        _assertInlineSnapshot(matching: diffable, as: .lines, with: #"""
        \"
        """#)
        """##

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testUpdateSnapshotWithExtendedDelimiter2() throws {
        let diffable = ##"\"""#"##
        let source = ###"""
        _assertInlineSnapshot(matching: diffable, as: .lines, with: ##"""
        "#
        """##)
        """###

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testUpdateSnapshotWithLongerExtendedDelimiter1() throws {
        let diffable = #"\""#
        let source = #"""
        _assertInlineSnapshot(matching: diffable, as: .lines, with: """
        \"
        """)
        """#

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testUpdateSnapshotWithLongerExtendedDelimiter2() throws {
        let diffable = ##"\"""#"##
        let source = ##"""
        _assertInlineSnapshot(matching: diffable, as: .lines, with: #"""
        "#
        """#)
        """##

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testUpdateSnapshotWithShorterExtendedDelimiter1() throws {
        let diffable = #"\""#
        let source = ###"""
        _assertInlineSnapshot(matching: diffable, as: .lines, with: ##"""
        \"
        """##)
        """###

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testUpdateSnapshotWithShorterExtendedDelimiter2() throws {
        let diffable = ##"\"""#"##
        let source = ####"""
        _assertInlineSnapshot(matching: diffable, as: .lines, with: ###"""
        "#
        """###)
        """####

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }

    func testUpdateSeveralSnapshotsWithMoreLines() throws {
        let diffable1 = """
        NEW_SNAPSHOT
        with two lines
        """

        let diffable2 = "NEW_SNAPSHOT"

        let source = """
        _assertInlineSnapshot(matching: diffable, as: .lines, with: \"""
        OLD_SNAPSHOT
        \""")

        _assertInlineSnapshot(matching: diffable2, as: .lines, with: \"""
        OLD_SNAPSHOT
        \""")
        """

        var recordings: Recordings = [:]
        let sourceAfterFirstSnapshot = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable1, fileName: "filename", lineIndex: 1)
        ).sourceCode

        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: sourceAfterFirstSnapshot, diffable: diffable2, fileName: "filename", lineIndex: 5)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable1, diffable2: diffable2)
    }

    func testUpdateSeveralSnapshotsWithLessLines() throws {
        let diffable1 = """
        NEW_SNAPSHOT
        """

        let diffable2 = "NEW_SNAPSHOT"

        let source = """
        _assertInlineSnapshot(matching: diffable, as: .lines, with: \"""
        OLD_SNAPSHOT
        with two lines
        \""")

        _assertInlineSnapshot(matching: diffable2, as: .lines, with: \"""
        OLD_SNAPSHOT
        \""")
        """

        var recordings: Recordings = [:]
        let sourceAfterFirstSnapshot = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable1, fileName: "filename", lineIndex: 1)
        ).sourceCode

        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: sourceAfterFirstSnapshot, diffable: diffable2, fileName: "filename", lineIndex: 6)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable1, diffable2: diffable2)
    }

    func testUpdateSeveralSnapshotsSwapingLines1() throws {
        let diffable1 = """
        NEW_SNAPSHOT
        with two lines
        """

        let diffable2 = """
        NEW_SNAPSHOT
        """

        let source = """
        _assertInlineSnapshot(matching: diffable, as: .lines, with: \"""
        OLD_SNAPSHOT
        \""")

        _assertInlineSnapshot(matching: diffable2, as: .lines, with: \"""
        OLD_SNAPSHOT
        with two lines
        \""")
        """

        var recordings: Recordings = [:]
        let sourceAfterFirstSnapshot = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable1, fileName: "filename", lineIndex: 1)
        ).sourceCode

        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: sourceAfterFirstSnapshot, diffable: diffable2, fileName: "filename", lineIndex: 5)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable1, diffable2: diffable2)
    }

    func testUpdateSeveralSnapshotsSwapingLines2() throws {
        let diffable1 = """
        NEW_SNAPSHOT
        """

        let diffable2 = """
        NEW_SNAPSHOT
        with two lines
        """

        let source = """
        _assertInlineSnapshot(matching: diffable, as: .lines, with: \"""
        OLD_SNAPSHOT
        with two lines
        \""")

        _assertInlineSnapshot(matching: diffable2, as: .lines, with: \"""
        OLD_SNAPSHOT
        \""")
        """

        var recordings: Recordings = [:]
        let sourceAfterFirstSnapshot = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable1, fileName: "filename", lineIndex: 1)
        ).sourceCode

        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: sourceAfterFirstSnapshot, diffable: diffable2, fileName: "filename", lineIndex: 6)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable1, diffable2: diffable2)
    }

    func testUpdateSnapshotCombined1() throws {
        let diffable = ##"""
        ▿ User
          - bio: "Blobbed around the world."
          - id: 1
          - name: "Bl#\"\"#obby"
        """##

        let source = ######"""
        _assertInlineSnapshot(matching: diffable, as: .lines, with: #####"""
        """#####)
        """######

        var recordings: Recordings = [:]
        let newSource = try writeInlineSnapshot(
            &recordings,
            Context(sourceCode: source, diffable: diffable, fileName: "filename", lineIndex: 1)
        ).sourceCode

        assertSnapshot(source: newSource, diffable: diffable)
    }
}

func assertSnapshot(source: String, diffable: String, record: Bool = false, file: StaticString = #file, testName: String = #function, line: UInt = #line) {
    let decoratedCode = ########"""
    import XCTest
    @testable import SnapshotTesting
    extension InlineSnapshotsValidityTests {
        func \########(testName) {
            let diffable = #######"""
    \########(diffable.indented(by: 8))
            """#######

    \########(source.indented(by: 8))
        }
    }

    """########
    assertSnapshot(matching: decoratedCode, as: .swift, record: record, file: file, testName: testName, line: line)
}

func assertSnapshot(source: String, diffable: String, diffable2: String, record: Bool = false, file: StaticString = #file, testName: String = #function, line: UInt = #line) {
    let decoratedCode = ########"""
    import XCTest
    @testable import SnapshotTesting
    extension InlineSnapshotsValidityTests {
        func \########(testName) {
            let diffable = #######"""
    \########(diffable.indented(by: 8))
            """#######

            let diffable2 = #######"""
    \########(diffable2.indented(by: 8))
            """#######

    \########(source.indented(by: 8))
        }
    }

    """########
    assertSnapshot(matching: decoratedCode, as: .swift, record: record, file: file, testName: testName, line: line)
}

public extension Snapshotting where Value == String, Format == String {
    static var swift: Snapshotting {
        var snapshotting = Snapshotting(pathExtension: "txt", diffing: .lines)
        snapshotting.pathExtension = "swift"
        return snapshotting
    }
}

// Class that is extended with the generated code to check that it builds.
// Besides that, the generated code is a test itself, which tests that the
// snapshotted value is equal to the original value.
// With this test we check that we escaped correctly
// e.g. if we enclose \" in """ """ instead of #""" """#,
// the character sequence will be interpreted as " instead of \"
// The generated tests check this issues.
class InlineSnapshotsValidityTests: XCTestCase {}

private extension String {
    func indented(by numberOfSpaces: Int) -> String {
        let spaces = Array(repeating: " ", count: numberOfSpaces).joined()
        return split(separator: "\n").map { spaces + $0 }.joined(separator: "\n")
    }
}
