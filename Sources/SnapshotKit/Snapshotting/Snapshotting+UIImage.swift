#if os(iOS) || os(tvOS)
import UIKit
import XCTest

public extension Diffing where Value == UIImage {
    /// A pixel-diffing strategy for UIImage's which requires a 100% match.
    static let image = Diffing.image(precision: 1, subpixelThreshold: 0, scale: nil)

    /// A pixel-diffing strategy for UIImage that allows customizing how precise the matching must be.
    ///
    /// - Parameter precision: A value between 0 and 1, where 1 means 100% of the pixels must be within `subpixelThreshold`.
    /// - Parameter subpixelThreshold: If any component (RGB) of a pixel has a greater difference than this value, it is considered different.
    /// - Parameter scale: Scale to use when loading the reference image from disk. If `nil` or the `UITraitCollection`s default value of `0.0`, the screens scale is used.
    /// - Returns: A new diffing strategy.
    static func image(precision: Float, subpixelThreshold: UInt8, scale: CGFloat?) -> Diffing {
        let imageScale: CGFloat
        if let scale = scale, scale != 0 {
            imageScale = scale
        } else {
            imageScale = UIScreen.main.scale
        }

        return Diffing(
            toData: { $0.pngData() ?? .fallback! }, // swiftlint:disable:this force_unwrapping
            fromData: { UIImage(data: $0, scale: imageScale)! }, // swiftlint:disable:this force_unwrapping
            diff: { old, new in
                func attachments(_ old: UIImage, _ new: UIImage) -> [XCTAttachment] {
                    [
                        XCTAttachment(name: "expected", image: old),
                        XCTAttachment(name: "actual", image: new),
                        XCTAttachment(name: "difference", image: old.diff(to: new))
                    ]
                }

                let result = old.compare(to: new, precision: precision, subpixelThreshold: subpixelThreshold)
                switch result {
                case .cgContextFailure, .cgContextDataFailure, .cgImageFailure:
                    return ("Core Graphics failure", [])
                case .isEqual, .isSimilar:
                    return nil
                case .isUnequal:
                    return ("Snapshot is unequal", attachments(old, new))
                case .isNotSimilar:
                    return ("Snapshot is not similar", attachments(old, new))
                case let .unequalWidth(lhs, rhs):
                    return ("Snapshot width of \(rhs) is unequal to expected \(lhs)", attachments(old, new))
                case let .unequalHeight(lhs, rhs):
                    return ("Snapshot height of \(rhs) is unequal to expected \(lhs)", attachments(old, new))
                }
            }
        )
    }
}

private extension Data {
    static var fallback: Data? {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 80))
        label.backgroundColor = .red
        label.text = "Error: No image could be generated for this view as its size was zero. Please set an explicit size in the test."
        label.textAlignment = .center
        label.numberOfLines = 3
        return label.asImage().pngData()
    }
}

private extension XCTAttachment {
    convenience init(name: String, image: UIImage) {
        self.init(image: image)
        self.name = name
    }
}

public extension Snapshotting where Value == UIImage, Format == UIImage {
    /// A snapshot strategy for comparing images based on pixel equality.
    static var image: Snapshotting {
        .image(precision: 1, subpixelThreshold: 0, scale: nil)
    }

    /// A snapshot strategy for comparing images based on pixel equality.
    ///
    /// - Parameter precision: The percentage of pixels that must match.
    /// - Parameter subpixelThreshold: The byte-value threshold at which two subpixels are considered different.
    /// - Parameter scale: The scale of the reference image stored on disk.
    static func image(precision: Float, subpixelThreshold: UInt8, scale: CGFloat?) -> Snapshotting {
        .init(
            pathExtension: "png",
            diffing: .image(precision: precision, subpixelThreshold: subpixelThreshold, scale: scale)
        )
    }
}

// remap snapshot & reference to same colorspace
let imageContextColorSpace = CGColorSpace(name: CGColorSpace.sRGB)
let imageContextBitsPerComponent = 8
let imageContextBytesPerPixel = 4

private enum ImageComparisonResult {
    case cgContextDataFailure
    case cgContextFailure
    case cgImageFailure
    case isEqual
    case isNotSimilar
    case isSimilar
    case isUnequal
    case unequalWidth(Int, Int)
    case unequalHeight(Int, Int)
}

private extension UIImage {
    // swiftlint:disable:next cyclomatic_complexity
    func compare(to other: UIImage, precision: Float, subpixelThreshold: UInt8) -> ImageComparisonResult {
        guard let oldCgImage = cgImage, let newCgImage = other.cgImage else { return .cgImageFailure }

        guard oldCgImage.width == newCgImage.width else {
            return .unequalWidth(oldCgImage.width, newCgImage.width)
        }

        guard oldCgImage.height == newCgImage.height else {
            return .unequalHeight(oldCgImage.height, newCgImage.height)
        }

        let byteCount = imageContextBytesPerPixel * oldCgImage.width * oldCgImage.height
        var oldBytes = [UInt8](repeating: 0, count: byteCount)
        guard let oldContext = oldCgImage.cgContext(data: &oldBytes),
              let newContext = newCgImage.cgContext()
        else { return .cgContextFailure }

        guard let oldData = oldContext.data, let newData = newContext.data else {
            return .cgContextDataFailure
        }

        if memcmp(oldData, newData, byteCount) == 0 { return .isEqual }

        let newer = UIImage(data: other.pngData()!)! // swiftlint:disable:this force_unwrapping

        guard let newerCgImage = newer.cgImage else { return .cgImageFailure }
        var newerBytes = [UInt8](repeating: 0, count: byteCount)
        guard let newerContext = newerCgImage.cgContext(data: &newerBytes) else { return .cgContextFailure }
        guard let newerData = newerContext.data else { return .cgContextDataFailure }

        if memcmp(oldData, newerData, byteCount) == 0 { return .isEqual }
        if precision >= 1, subpixelThreshold == 0 { return .isUnequal }

        var differentPixelCount = 0
        let threshold = Int(round((1.0 - precision) * Float(byteCount)))

        var byte = 0
        while byte < byteCount {
            if oldBytes[byte].diff(between: newerBytes[byte]) > subpixelThreshold {
                differentPixelCount += 1
                if differentPixelCount >= threshold {
                    return .isNotSimilar
                }
            }
            byte += 1
        }
        return .isSimilar
    }

    func diff(to other: UIImage) -> UIImage {
        let width = max(size.width, size.width)
        let height = max(size.height, size.height)
        let scale = max(scale, scale)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), true, scale)
        other.draw(at: .zero)
        draw(at: .zero, blendMode: .difference, alpha: 1)
        let differenceImage = UIGraphicsGetImageFromCurrentImageContext()! // swiftlint:disable:this force_unwrapping
        UIGraphicsEndImageContext()
        return differenceImage
    }
}

private extension CGImage {
    func cgContext(data: UnsafeMutableRawPointer? = nil) -> CGContext? {
        let bytesPerRow = width * imageContextBytesPerPixel
        guard
            let colorSpace = imageContextColorSpace,
            let context = CGContext(
                data: data,
                width: width,
                height: height,
                bitsPerComponent: imageContextBitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        else { return nil }

        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context
    }
}
#endif
