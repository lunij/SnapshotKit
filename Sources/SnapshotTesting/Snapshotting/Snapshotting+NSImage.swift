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
            toData: { NSImagePNGRepresentation($0)! }, // swiftlint:disable:this force_unwrapping
            fromData: { NSImage(data: $0)! }, // swiftlint:disable:this force_unwrapping
            diff: { old, new in
                guard !compare(old, new, precision: precision, subpixelThreshold: subpixelThreshold) else { return nil }
                let difference = SnapshotTesting.diff(old, new)
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

private func NSImagePNGRepresentation(_ image: NSImage) -> Data? {
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
    let rep = NSBitmapImageRep(cgImage: cgImage)
    rep.size = image.size
    return rep.representation(using: .png, properties: [:])
}

// swiftlint:disable:next cyclomatic_complexity
private func compare(_ old: NSImage, _ new: NSImage, precision: Float, subpixelThreshold: UInt8) -> Bool {
    guard let oldCgImage = old.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
    guard let newCgImage = new.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
    guard oldCgImage.width != 0 else { return false }
    guard newCgImage.width != 0 else { return false }
    guard oldCgImage.width == newCgImage.width else { return false }
    guard oldCgImage.height != 0 else { return false }
    guard newCgImage.height != 0 else { return false }
    guard oldCgImage.height == newCgImage.height else { return false }
    guard let oldContext = context(for: oldCgImage) else { return false }
    guard let newContext = context(for: newCgImage) else { return false }
    guard let oldData = oldContext.data else { return false }
    guard let newData = newContext.data else { return false }
    let byteCount = oldContext.height * oldContext.bytesPerRow
    if memcmp(oldData, newData, byteCount) == 0 { return true }
    let newer = NSImage(data: NSImagePNGRepresentation(new)!)! // swiftlint:disable:this force_unwrapping
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

private func diff(_ old: NSImage, _ new: NSImage) -> NSImage {
    let oldCiImage = CIImage(cgImage: old.cgImage(forProposedRect: nil, context: nil, hints: nil)!) // swiftlint:disable:this force_unwrapping
    let newCiImage = CIImage(cgImage: new.cgImage(forProposedRect: nil, context: nil, hints: nil)!) // swiftlint:disable:this force_unwrapping
    let differenceFilter = CIFilter(name: "CIDifferenceBlendMode")! // swiftlint:disable:this force_unwrapping
    differenceFilter.setValue(oldCiImage, forKey: kCIInputImageKey)
    differenceFilter.setValue(newCiImage, forKey: kCIInputBackgroundImageKey)
    let maxSize = CGSize(
        width: max(old.size.width, new.size.width),
        height: max(old.size.height, new.size.height)
    )
    let rep = NSCIImageRep(ciImage: differenceFilter.outputImage!) // swiftlint:disable:this force_unwrapping
    let difference = NSImage(size: maxSize)
    difference.addRepresentation(rep)
    return difference
}
#endif
