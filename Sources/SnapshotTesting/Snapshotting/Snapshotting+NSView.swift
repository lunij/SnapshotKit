#if os(macOS)
import Cocoa

public extension Snapshotting where Value == NSView, Format == NSImage {
    /// A snapshot strategy for comparing views based on pixel equality.
    static var image: Snapshotting {
        .image()
    }

    /// A snapshot strategy for comparing views based on pixel equality.
    ///
    /// - Parameters:
    ///   - precision: The percentage of pixels that must match.
    ///   - subpixelThreshold: The byte-value threshold at which two subpixels are considered different.
    ///   - size: A view size override.
    static func image(precision: Float = 1, subpixelThreshold: UInt8 = 0, size: CGSize? = nil) -> Snapshotting {
        SimplySnapshotting.image(precision: precision, subpixelThreshold: subpixelThreshold).asyncPullback { view in
            let initialSize = view.frame.size
            if let size = size { view.frame.size = size }
            return view.snapshot ?? Async { callback in
                view.addImagesForRenderedViews().sequence().run { views in
                    guard let bitmapRep = NSBitmapImageRep(
                        bitmapDataPlanes: nil,
                        pixelsWide: Int(view.bounds.width),
                        pixelsHigh: Int(view.bounds.height),
                        bitsPerSample: 8,
                        samplesPerPixel: 4,
                        hasAlpha: true,
                        isPlanar: false,
                        colorSpaceName: .deviceRGB,
                        bytesPerRow: 4 * Int(view.bounds.width),
                        bitsPerPixel: 32
                    ) else { return callback(NSImage()) }

                    view.cacheDisplay(in: view.bounds, to: bitmapRep)
                    let image = NSImage(size: view.bounds.size)
                    image.addRepresentation(bitmapRep)
                    callback(image)
                    views.forEach { $0.removeFromSuperview() }
                    view.frame.size = initialSize
                }
            }
        }
    }
}

public extension Snapshotting where Value == NSView, Format == String {
    /// A snapshot strategy for comparing views based on a recursive description of their properties and hierarchies.
    static var recursiveDescription: Snapshotting<NSView, String> {
        SimplySnapshotting.lines.pullback { view in
            purgePointers(
                view.perform(Selector(("_subtreeDescription"))).retain().takeUnretainedValue() as! String // swiftlint:disable:this force_cast
            )
        }
    }
}
#endif
