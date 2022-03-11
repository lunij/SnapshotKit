#if os(macOS)
import Cocoa

public extension Snapshotting where Value == NSBezierPath, Format == NSImage {
    /// A snapshot strategy for comparing bezier paths based on pixel equality.
    static var image: Snapshotting {
        .image()
    }

    /// A snapshot strategy for comparing bezier paths based on pixel equality.
    ///
    /// - Parameter precision: The percentage of pixels that must match.
    /// - Parameter subpixelThreshold: The byte-value threshold at which two subpixels are considered different.
    static func image(precision: Float = 1, subpixelThreshold: UInt8 = 0, drawingMode: CGPathDrawingMode = .eoFill) -> Snapshotting {
        SimplySnapshotting.image(precision: precision, subpixelThreshold: subpixelThreshold).pullback { path in
            let size = path.bounds.size

            guard let context = CGContext(
                data: nil,
                width: Int(size.width),
                height: Int(size.height),
                bitsPerComponent: 8,
                bytesPerRow: 4 * Int(size.height),
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
            ) else { return NSImage() }

            context.addPath(path.cgPath)
            context.drawPath(using: drawingMode)

            guard let cgImage = context.makeImage() else { return NSImage() }
            return NSImage(cgImage: cgImage, size: size)
        }
    }
}

public extension Snapshotting where Value == NSBezierPath, Format == String {
    /// A snapshot strategy for comparing bezier paths based on pixel equality.
    @available(iOS 11.0, *)
    static var elementsDescription: Snapshotting {
        .elementsDescription(numberFormatter: defaultNumberFormatter)
    }

    /// A snapshot strategy for comparing bezier paths based on pixel equality.
    ///
    /// - Parameter numberFormatter: The number formatter used for formatting points.
    @available(iOS 11.0, *)
    static func elementsDescription(numberFormatter: NumberFormatter) -> Snapshotting {
        let namesByType: [NSBezierPath.ElementType: String] = [
            .moveTo: "MoveTo",
            .lineTo: "LineTo",
            .curveTo: "CurveTo",
            .closePath: "Close"
        ]

        let numberOfPointsByType: [NSBezierPath.ElementType: Int] = [
            .moveTo: 1,
            .lineTo: 1,
            .curveTo: 3,
            .closePath: 0
        ]

        return SimplySnapshotting.lines.pullback { path in
            var string = ""

            var elementPoints = [CGPoint](repeating: .zero, count: 3)
            for elementIndex in 0 ..< path.elementCount {
                let elementType = path.element(at: elementIndex, associatedPoints: &elementPoints)
                let name = namesByType[elementType] ?? "Unknown"

                if elementType == .moveTo, !string.isEmpty {
                    string += "\n"
                }

                string += name

                if let numberOfPoints = numberOfPointsByType[elementType] {
                    let points = elementPoints[0 ..< numberOfPoints]
                    string += " " + points.map { point in
                        let x = numberFormatter.string(from: point.x as NSNumber)! // swiftlint:disable:this force_unwrapping
                        let y = numberFormatter.string(from: point.y as NSNumber)! // swiftlint:disable:this force_unwrapping
                        return "(\(x), \(y))"
                    }.joined(separator: " ")
                }

                string += "\n"
            }

            return string
        }
    }
}

private let defaultNumberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.minimumFractionDigits = 1
    numberFormatter.maximumFractionDigits = 3
    numberFormatter.locale = Locale(identifier: "en_US_POSIX")
    return numberFormatter
}()

private extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)

        for index in 0 ..< elementCount {
            let type = element(at: index, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            @unknown default:
                continue
            }
        }

        return path
    }
}
#endif
