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
                guard !old.compare(to: new, precision: precision, subpixelThreshold: subpixelThreshold) else { return nil }
                let difference = old.diff(to: new)
                let message = new.size == old.size
                    ? "Newly-taken snapshot does not match reference."
                    : "Newly-taken snapshot@\(new.size) does not match reference@\(old.size)."
                return (
                    message,
                    [XCTAttachment(image: old), XCTAttachment(image: new), XCTAttachment(image: difference)]
                )
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

private extension NSImage {
    var pngRepresentation: Data? {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let imageRep = NSBitmapImageRep(cgImage: cgImage)
        imageRep.size = size
        return imageRep.representation(using: .png, properties: [:])
    }

    // swiftlint:disable:next cyclomatic_complexity
    func compare(to other: NSImage, precision: Float, subpixelThreshold: UInt8) -> Bool {
        guard let oldCgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
        guard let newCgImage = other.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }

        guard oldCgImage.width == newCgImage.width else { return false }
        guard oldCgImage.height == newCgImage.height else { return false }

        guard let oldContext = context(for: oldCgImage) else { return false }
        guard let newContext = context(for: newCgImage) else { return false }

        guard let oldData = oldContext.data else { return false }
        guard let newData = newContext.data else { return false }

        let byteCount = oldContext.height * oldContext.bytesPerRow
        if memcmp(oldData, newData, byteCount) == 0 { return true }

        let newer = NSImage(data: other.pngRepresentation!)! // swiftlint:disable:this force_unwrapping

        guard let newerCgImage = newer.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
        guard let newerContext = context(for: newerCgImage) else { return false }
        guard let newerData = newerContext.data else { return false }

        if memcmp(oldData, newerData, byteCount) == 0 { return true }
        if precision >= 1 { return false }

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
                    return false
                }
            }
            offset += 1
        }
        return true
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

private func context(for cgImage: CGImage) -> CGContext? {
    guard
        let space = cgImage.colorSpace,
        let context = CGContext(
            data: nil,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: cgImage.bytesPerRow,
            space: space,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    else { return nil }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
    return context
}
#endif
