#if os(macOS)
import Cocoa
import XCTest

public extension Diffing where Value == NSImage {
    /// A pixel-diffing strategy for NSImage's which requires a 100% match.
    static let image: Diffing = Diffing.image(precision: 1, subpixelThreshold: 0)

    /// A pixel-diffing strategy for NSImage that allows customizing how precise the matching must be.
    ///
    /// - Parameter precision: A value between 0 and 1, where 1 means the images must match 100% of their pixels.
    /// - Parameter subpixelThreshold: The byte-value threshold at which two subpixels are considered different.
    /// - Returns: A new diffing strategy.
    static func image(precision: Float, subpixelThreshold: UInt8) -> Diffing {
        .init(
            toData: { $0.pngRepresentation! }, // swiftlint:disable:this force_unwrapping
            fromData: { NSImage(data: $0)! }, // swiftlint:disable:this force_unwrapping
            diff: { old, new in
                func attachments(_ old: NSImage, _ new: NSImage) -> [XCTAttachment] {
                    [
                        XCTAttachment(image: old),
                        XCTAttachment(image: new),
                        XCTAttachment(image: old.diff(to: new))
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

public extension Snapshotting where Value == NSImage, Format == NSImage {
    /// A snapshot strategy for comparing images based on pixel equality.
    static var image: Snapshotting {
        .image(precision: 1, subpixelThreshold: 0)
    }

    /// A snapshot strategy for comparing images based on pixel equality.
    ///
    /// - Parameter precision: The percentage of pixels that must match.
    /// - Parameter subpixelThreshold: The byte-value threshold at which two subpixels are considered different.
    static func image(precision: Float, subpixelThreshold: UInt8) -> Snapshotting {
        .init(
            pathExtension: "png",
            diffing: .image(precision: precision, subpixelThreshold: subpixelThreshold)
        )
    }
}

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

private extension NSImage {
    var pngRepresentation: Data? {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let imageRep = NSBitmapImageRep(cgImage: cgImage)
        imageRep.size = size
        return imageRep.representation(using: .png, properties: [:])
    }

    // swiftlint:disable:next cyclomatic_complexity
    func compare(to other: NSImage, precision: Float, subpixelThreshold: UInt8) -> ImageComparisonResult {
        guard let oldCgImage = cgImage(forProposedRect: nil, context: nil, hints: nil),
              let newCgImage = other.cgImage(forProposedRect: nil, context: nil, hints: nil)
        else { return .cgImageFailure }

        guard oldCgImage.width == newCgImage.width else {
            return .unequalWidth(oldCgImage.width, newCgImage.width)
        }

        guard oldCgImage.height == newCgImage.height else {
            return .unequalHeight(oldCgImage.height, oldCgImage.height)
        }

        guard let oldContext = oldCgImage.cgContext, let newContext = newCgImage.cgContext else {
            return .cgContextFailure
        }

        guard let oldData = oldContext.data, let newData = newContext.data else {
            return .cgContextDataFailure
        }

        let byteCount = oldContext.height * oldContext.bytesPerRow
        if memcmp(oldData, newData, byteCount) == 0 { return .isEqual }

        let newer = NSImage(data: other.pngRepresentation!)! // swiftlint:disable:this force_unwrapping

        guard let newerCgImage = newer.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return .cgImageFailure }
        guard let newerContext = newerCgImage.cgContext else { return .cgContextFailure }
        guard let newerData = newerContext.data else { return .cgContextDataFailure }

        if memcmp(oldData, newerData, byteCount) == 0 { return .isEqual }
        if precision >= 1 { return .isUnequal }

        let oldRep = NSBitmapImageRep(cgImage: oldCgImage)
        let newRep = NSBitmapImageRep(cgImage: newerCgImage)

        var differentPixelCount = 0
        let pixelCount = oldRep.pixelsWide * oldRep.pixelsHigh
        let threshold = Int((1 - precision) * Float(pixelCount))

        let oldBitmapData: UnsafeMutablePointer<UInt8> = oldRep.bitmapData! // swiftlint:disable:this force_unwrapping
        let newBitmapData: UnsafeMutablePointer<UInt8> = newRep.bitmapData! // swiftlint:disable:this force_unwrapping

        var offset = 0
        while offset < pixelCount * 4 {
            if oldBitmapData[offset].diff(between: newBitmapData[offset]) > subpixelThreshold {
                differentPixelCount += 1
                if differentPixelCount > threshold {
                    return .isNotSimilar
                }
            }
            offset += 1
        }
        return .isSimilar
    }

    func diff(to other: NSImage) -> NSImage {
        let oldCiImage = CIImage(cgImage: cgImage(forProposedRect: nil, context: nil, hints: nil)!) // swiftlint:disable:this force_unwrapping
        let newCiImage = CIImage(cgImage: other.cgImage(forProposedRect: nil, context: nil, hints: nil)!) // swiftlint:disable:this force_unwrapping
        let differenceFilter = CIFilter(name: "CIDifferenceBlendMode")! // swiftlint:disable:this force_unwrapping
        differenceFilter.setValue(oldCiImage, forKey: kCIInputImageKey)
        differenceFilter.setValue(newCiImage, forKey: kCIInputBackgroundImageKey)
        let maxSize = CGSize(
            width: max(size.width, other.size.width),
            height: max(size.height, other.size.height)
        )
        let imageRep = NSCIImageRep(ciImage: differenceFilter.outputImage!) // swiftlint:disable:this force_unwrapping
        let difference = NSImage(size: maxSize)
        difference.addRepresentation(imageRep)
        return difference
    }
}

private extension CGImage {
    var cgContext: CGContext? {
        guard
            let space = colorSpace,
            let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: space,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        else { return nil }

        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context
    }
}
#endif
