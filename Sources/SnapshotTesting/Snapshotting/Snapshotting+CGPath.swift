#if os(macOS)
import Cocoa

public extension Snapshotting where Value == CGPath, Format == NSImage {
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
            let size = path.boundingBox.size
            guard let context = CGContext(
                data: nil,
                width: Int(size.width),
                height: Int(size.height),
                bitsPerComponent: 8,
                bytesPerRow: 4 * Int(size.height),
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
            ) else { return NSImage() }
            context.addPath(path)
            context.drawPath(using: drawingMode)
            guard let cgImage = context.makeImage() else { return NSImage() }
            return NSImage(cgImage: cgImage, size: size)
        }
    }
}

#elseif os(iOS) || os(tvOS)
import UIKit

public extension Snapshotting where Value == CGPath, Format == UIImage {
    /// A snapshot strategy for comparing bezier paths based on pixel equality.
    static var image: Snapshotting {
        .image()
    }

    /// A snapshot strategy for comparing bezier paths based on pixel equality.
    ///
    /// - Parameter precision: The percentage of pixels that must match.
    /// - Parameter subpixelThreshold: The byte-value threshold at which two subpixels are considered different.

    static func image(precision: Float = 1, subpixelThreshold: UInt8 = 0, scale: CGFloat = 1, drawingMode: CGPathDrawingMode = .eoFill) -> Snapshotting {
        SimplySnapshotting.image(precision: precision, subpixelThreshold: subpixelThreshold, scale: scale).pullback { path in
            let bounds = path.boundingBoxOfPath
            let format: UIGraphicsImageRendererFormat
            if #available(iOS 11.0, tvOS 11.0, *) {
                format = UIGraphicsImageRendererFormat.preferred()
            } else {
                format = UIGraphicsImageRendererFormat.default()
            }
            format.scale = scale
            return UIGraphicsImageRenderer(bounds: bounds, format: format).image { ctx in
                let cgContext = ctx.cgContext
                cgContext.addPath(path)
                cgContext.drawPath(using: drawingMode)
            }
        }
    }
}
#endif

#if os(macOS) || os(iOS) || os(tvOS)
@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
public extension Snapshotting where Value == CGPath, Format == String {
    /// A snapshot strategy for comparing bezier paths based on element descriptions.
    static var elementsDescription: Snapshotting {
        .elementsDescription(numberFormatter: defaultNumberFormatter)
    }

    /// A snapshot strategy for comparing bezier paths based on element descriptions.
    ///
    /// - Parameter numberFormatter: The number formatter used for formatting points.
    static func elementsDescription(numberFormatter: NumberFormatter) -> Snapshotting {
        let namesByType: [CGPathElementType: String] = [
            .moveToPoint: "MoveTo",
            .addLineToPoint: "LineTo",
            .addQuadCurveToPoint: "QuadCurveTo",
            .addCurveToPoint: "CurveTo",
            .closeSubpath: "Close"
        ]

        let numberOfPointsByType: [CGPathElementType: Int] = [
            .moveToPoint: 1,
            .addLineToPoint: 1,
            .addQuadCurveToPoint: 2,
            .addCurveToPoint: 3,
            .closeSubpath: 0
        ]

        return SimplySnapshotting.lines.pullback { path in
            var string = ""

            path.applyWithBlock { elementPointer in
                let element = elementPointer.pointee
                let name = namesByType[element.type] ?? "Unknown"

                if element.type == .moveToPoint, !string.isEmpty {
                    string += "\n"
                }

                string += name

                if let numberOfPoints = numberOfPointsByType[element.type] {
                    let points = UnsafeBufferPointer(start: element.points, count: numberOfPoints)
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
#endif
