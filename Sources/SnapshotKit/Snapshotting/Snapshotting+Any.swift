import Foundation

public extension Snapshotting where Format == String {
    /// A snapshot strategy for comparing any structure based on a sanitized text dump.
    static var dump: Snapshotting {
        SimplySnapshotting.lines.pullback { snap($0) }
    }
}

public extension Snapshotting where Format == String {
    /// A snapshot strategy for comparing any structure based on their JSON representation.
    static var json: Snapshotting {
        let options: JSONSerialization.WritingOptions = [
            .prettyPrinted,
            .sortedKeys
        ]

        var snapshotting = SimplySnapshotting.lines.pullback { (data: Value) in
            try! String(decoding: JSONSerialization.data(withJSONObject: data, options: options), as: UTF8.self) // swiftlint:disable:this force_try
        }
        snapshotting.pathExtension = "json"
        return snapshotting
    }
}

// swiftlint:disable:next cyclomatic_complexity
private func snap<T>(_ value: T, name: String? = nil, indent: Int = 0) -> String {
    let indentation = String(repeating: " ", count: indent)
    let mirror = Mirror(reflecting: value)
    var children = mirror.children
    let count = children.count
    let bullet = count == 0 ? "-" : "▿"

    let description: String
    switch (value, mirror.displayStyle) {
    case (_, .collection?):
        description = count == 1 ? "1 element" : "\(count) elements"
    case (_, .dictionary?):
        description = count == 1 ? "1 key/value pair" : "\(count) key/value pairs"
        children = sort(children)
    case (_, .set?):
        description = count == 1 ? "1 member" : "\(count) members"
        children = sort(children)
    case (_, .tuple?):
        description = count == 1 ? "(1 element)" : "(\(count) elements)"
    case (_, .optional?):
        let subjectType = String(describing: mirror.subjectType)
            .replacingOccurrences(of: " #\\d+", with: "", options: .regularExpression)
        description = count == 0 ? "\(subjectType).none" : "\(subjectType)"
    case let (value as AnySnapshotStringConvertible, _) where type(of: value).renderChildren:
        description = value.snapshotDescription
    case let (value as AnySnapshotStringConvertible, _):
        return "\(indentation)- \(name.map { "\($0): " } ?? "")\(value.snapshotDescription)\n"
    case let (value as CustomStringConvertible, _):
        description = value.description
    case (_, .class?), (_, .struct?):
        description = String(describing: mirror.subjectType)
            .replacingOccurrences(of: " #\\d+", with: "", options: .regularExpression)
        children = sort(children)
    case (_, .enum?):
        let subjectType = String(describing: mirror.subjectType)
            .replacingOccurrences(of: " #\\d+", with: "", options: .regularExpression)
        description = count == 0 ? "\(subjectType).\(value)" : "\(subjectType)"
    case let (value, _):
        description = String(describing: value)
    }

    let lines = ["\(indentation)\(bullet) \(name.map { "\($0): " } ?? "")\(description)\n"]
        + children.map { snap($1, name: $0, indent: indent + 2) }

    return lines.joined()
}

private func sort(_ children: Mirror.Children) -> Mirror.Children {
    .init(
        children
            .map { (child: $0, snap: snap($0)) }
            .sorted(by: { $0.snap < $1.snap })
            .map(\.child)
    )
}

/// A type with a customized snapshot dump representation.
///
/// Types that conform to the `AnySnapshotStringConvertible` protocol can provide their own representation to be used when converting an instance to a `dump`-based snapshot.
public protocol AnySnapshotStringConvertible {
    /// Whether or not to dump child nodes (defaults to `false`).
    static var renderChildren: Bool { get }

    /// A textual snapshot dump representation of this instance.
    var snapshotDescription: String { get }
}

public extension AnySnapshotStringConvertible {
    static var renderChildren: Bool {
        false
    }
}

extension Character: AnySnapshotStringConvertible {
    public var snapshotDescription: String {
        debugDescription
    }
}

extension Data: AnySnapshotStringConvertible {
    public var snapshotDescription: String {
        debugDescription
    }
}

extension Date: AnySnapshotStringConvertible {
    public var snapshotDescription: String {
        snapshotDateFormatter.string(from: self)
    }
}

extension NSObject: AnySnapshotStringConvertible {
    #if canImport(ObjectiveC)
    @objc open var snapshotDescription: String {
        purgePointers(self.debugDescription)
    }
    #else
    open var snapshotDescription: String {
        purgePointers(debugDescription)
    }
    #endif
}

extension String: AnySnapshotStringConvertible {
    public var snapshotDescription: String {
        debugDescription
    }
}

extension Substring: AnySnapshotStringConvertible {
    public var snapshotDescription: String {
        debugDescription
    }
}

extension URL: AnySnapshotStringConvertible {
    public var snapshotDescription: String {
        debugDescription
    }
}

private let snapshotDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    return formatter
}()

func purgePointers(_ string: String) -> String {
    string.replacingOccurrences(of: ":?\\s*0x[\\da-f]+(\\s*)", with: "$1", options: .regularExpression)
}
