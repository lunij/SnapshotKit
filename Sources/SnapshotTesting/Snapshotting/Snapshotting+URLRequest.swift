import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension Snapshotting where Value == URLRequest, Format == String {
    /// A snapshot strategy for comparing requests based on raw equality.
    static let raw = Snapshotting.raw(pretty: false)

    /// A snapshot strategy for comparing requests based on raw equality.
    ///
    /// - Parameter pretty: Attempts to pretty print the body of the request (supports JSON).
    static func raw(pretty: Bool) -> Snapshotting {
        SimplySnapshotting.lines.pullback { (request: URLRequest) in
            let method = "\(request.httpMethod ?? "GET") \(request.url?.sortingQueryItems()?.absoluteString ?? "(null)")"

            let headers = (request.allHTTPHeaderFields ?? [:])
                .map { key, value in "\(key): \(value)" }
                .sorted()

            let body: [String]
            do {
                if pretty {
                    body = try request.httpBody
                        .map { try JSONSerialization.jsonObject(with: $0, options: []) }
                        .map { try JSONSerialization.data(withJSONObject: $0, options: [.prettyPrinted, .sortedKeys]) }
                        .map { ["\n\(String(decoding: $0, as: UTF8.self))"] }
                        ?? []
                } else {
                    throw NSError(domain: "co.pointfree.Never", code: 1, userInfo: nil)
                }
            } catch {
                body = request.httpBody
                    .map { ["\n\(String(decoding: $0, as: UTF8.self))"] }
                    ?? []
            }

            return ([method] + headers + body).joined(separator: "\n")
        }
    }

    /// A snapshot strategy for comparing requests based on a cURL representation.
    static let curl = SimplySnapshotting.lines.pullback { (request: URLRequest) in

        var components = ["curl"]

        // HTTP Method
        let httpMethod = request.httpMethod! // swiftlint:disable:this force_unwrapping
        switch httpMethod {
        case "GET": break
        case "HEAD": components.append("--head")
        default: components.append("--request \(httpMethod)")
        }

        // Headers
        if let headers = request.allHTTPHeaderFields {
            for field in headers.keys.sorted() where field != "Cookie" {
                let escapedValue = headers[field]!.replacingOccurrences(of: "\"", with: "\\\"") // swiftlint:disable:this force_unwrapping
                components.append("--header \"\(field): \(escapedValue)\"")
            }
        }

        // Body
        if let httpBodyData = request.httpBody, let httpBody = String(data: httpBodyData, encoding: .utf8) {
            var escapedBody = httpBody.replacingOccurrences(of: "\\\"", with: "\\\\\"")
            escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"")

            components.append("--data \"\(escapedBody)\"")
        }

        // Cookies
        if let cookie = request.allHTTPHeaderFields?["Cookie"] {
            let escapedValue = cookie.replacingOccurrences(of: "\"", with: "\\\"")
            components.append("--cookie \"\(escapedValue)\"")
        }

        // URL
        components.append("\"\(request.url!.sortingQueryItems()!.absoluteString)\"") // swiftlint:disable:this force_unwrapping

        return components.joined(separator: " \\\n\t")
    }
}

private extension URL {
    func sortingQueryItems() -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        let sortedQueryItems = components?.queryItems?.sorted { $0.name < $1.name }
        components?.queryItems = sortedQueryItems

        return components?.url
    }
}
