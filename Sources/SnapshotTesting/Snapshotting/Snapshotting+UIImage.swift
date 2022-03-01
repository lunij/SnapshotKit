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
        if let scale = scale, scale != 0.0 {
            imageScale = scale
        } else {
            imageScale = UIScreen.main.scale
        }

        return Diffing(
            toData: { $0.pngData() ?? emptyImage().pngData()! }, // swiftlint:disable:this force_unwrapping
            fromData: { UIImage(data: $0, scale: imageScale)! }, // swiftlint:disable:this force_unwrapping
            diff: { old, new in
                guard !compare(old, new, precision: precision, subpixelThreshold: subpixelThreshold) else { return nil }
                let difference = SnapshotTesting.diff(old, new)
                let message = new.size == old.size
                    ? "Newly-taken snapshot does not match reference."
                    : "Newly-taken snapshot@\(new.size) does not match reference@\(old.size)."
                let oldAttachment = XCTAttachment(image: old)
                oldAttachment.name = "reference"
                let newAttachment = XCTAttachment(image: new)
                newAttachment.name = "failure"
                let differenceAttachment = XCTAttachment(image: difference)
                differenceAttachment.name = "difference"
                return (
                    message,
                    [oldAttachment, newAttachment, differenceAttachment]
                )
            }
        )
    }

    /// Used when the image size has no width or no height to generated the default empty image
    private static func emptyImage() -> UIImage {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 80))
        label.backgroundColor = .red
        label.text = "Error: No image could be generated for this view as its size was zero. Please set an explicit size in the test."
        label.textAlignment = .center
        label.numberOfLines = 3
        return label.asImage()
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

// swiftlint:disable:next cyclomatic_complexity
private func compare(_ old: UIImage, _ new: UIImage, precision: Float, subpixelThreshold: UInt8) -> Bool {
    guard let oldCgImage = old.cgImage else { return false }
    guard let newCgImage = new.cgImage else { return false }
    guard oldCgImage.width != 0 else { return false }
    guard newCgImage.width != 0 else { return false }
    guard oldCgImage.width == newCgImage.width else { return false }
    guard oldCgImage.height != 0 else { return false }
    guard newCgImage.height != 0 else { return false }
    guard oldCgImage.height == newCgImage.height else { return false }

    let byteCount = imageContextBytesPerPixel * oldCgImage.width * oldCgImage.height
    var oldBytes = [UInt8](repeating: 0, count: byteCount)
    guard let oldContext = context(for: oldCgImage, data: &oldBytes) else { return false }
    guard let oldData = oldContext.data else { return false }
    if let newContext = context(for: newCgImage), let newData = newContext.data {
        if memcmp(oldData, newData, byteCount) == 0 { return true }
    }
    let newer = UIImage(data: new.pngData()!)! // swiftlint:disable:this force_unwrapping
    guard let newerCgImage = newer.cgImage else { return false }
    var newerBytes = [UInt8](repeating: 0, count: byteCount)
    guard let newerContext = context(for: newerCgImage, data: &newerBytes) else { return false }
    guard let newerData = newerContext.data else { return false }
    if memcmp(oldData, newerData, byteCount) == 0 { return true }
    if precision >= 1, subpixelThreshold == 0 { return false }
    var differentPixelCount = 0
    let threshold = Int(round((1.0 - precision) * Float(byteCount)))

    var byte = 0
    while byte < byteCount {
        if oldBytes[byte].diff(between: newerBytes[byte]) > subpixelThreshold {
            differentPixelCount += 1
            if differentPixelCount >= threshold {
                return false
            }
        }
        byte += 1
    }
    return true
}

private func context(for cgImage: CGImage, data: UnsafeMutableRawPointer? = nil) -> CGContext? {
    let bytesPerRow = cgImage.width * imageContextBytesPerPixel
    guard
        let colorSpace = imageContextColorSpace,
        let context = CGContext(
            data: data,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: imageContextBitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    else { return nil }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
    return context
}

private func diff(_ old: UIImage, _ new: UIImage) -> UIImage {
    let width = max(old.size.width, new.size.width)
    let height = max(old.size.height, new.size.height)
    let scale = max(old.scale, new.scale)
    UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), true, scale)
    new.draw(at: .zero)
    old.draw(at: .zero, blendMode: .difference, alpha: 1)
    let differenceImage = UIGraphicsGetImageFromCurrentImageContext()! // swiftlint:disable:this force_unwrapping
    UIGraphicsEndImageContext()
    return differenceImage
}
#endif
