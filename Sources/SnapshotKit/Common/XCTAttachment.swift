#if os(Linux) || os(Windows)
import Foundation

public struct XCTAttachment {
    public init(data _: Data) {}
    public init(data _: Data, uniformTypeIdentifier _: String) {}
}
#endif
