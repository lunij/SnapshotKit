#if canImport(SwiftUI)
import Foundation
import SwiftUI

/// The size constraint for a snapshot (similar to `PreviewLayout`).
public enum SwiftUISnapshotLayout {
    #if os(iOS) || os(tvOS)
    /// Center the view in a device container described by`config`.
    case device(config: ViewImageConfig)
    #endif
    /// Center the view in a fixed size container.
    case fixed(width: CGFloat, height: CGFloat)
    /// Fit the view to the ideal size that fits its content.
    case sizeThatFits
}

#if os(iOS) || os(tvOS)
@available(iOS 13.0, tvOS 13.0, *)
public extension Snapshotting where Value: SwiftUI.View, Format == UIImage {
    /// A snapshot strategy for comparing SwiftUI Views based on pixel equality.
    static var image: Snapshotting {
        .image()
    }

    /// A snapshot strategy for comparing SwiftUI Views based on pixel equality.
    ///
    /// - Parameters:
    ///   - drawHierarchyInKeyWindow: Utilize the simulator's key window in order to render `UIAppearance` and `UIVisualEffect`s.
    ///                               This option requires a host application for your tests and will _not_ work for framework test targets.
    ///   - precision: The percentage of pixels that must match.
    ///   - subpixelThreshold: The byte-value threshold at which two subpixels are considered different.
    ///   - size: A view size override.
    ///   - traits: A trait collection override.
    static func image(
        drawHierarchyInKeyWindow: Bool = false,
        precision: Float = 1,
        subpixelThreshold: UInt8 = 0,
        layout: SwiftUISnapshotLayout = .sizeThatFits,
        traits: UITraitCollection = .init()
    ) -> Snapshotting {
        let config: ViewImageConfig

        switch layout {
        #if os(iOS) || os(tvOS)
        case let .device(config: deviceConfig):
            config = deviceConfig
        #endif
        case .sizeThatFits:
            config = .init(safeArea: .zero, size: nil, traits: traits)
        case let .fixed(width: width, height: height):
            let size = CGSize(width: width, height: height)
            config = .init(safeArea: .zero, size: size, traits: traits)
        }

        return SimplySnapshotting.image(precision: precision, subpixelThreshold: subpixelThreshold, scale: traits.displayScale).asyncPullback { view in
            var config = config

            let controller: UIViewController

            if config.size != nil {
                controller = UIHostingController(rootView: view)
            } else {
                let hostingController = UIHostingController(rootView: view)
                config.size = hostingController.sizeThatFits(in: .zero)
                controller = hostingController
            }

            return controller.view.snapshot(
                config: config,
                drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
                traits: traits,
                viewController: controller
            )
        }
    }
}
#elseif os(macOS)
@available(macOS 11.0, *)
public extension Snapshotting where Value: SwiftUI.View, Format == NSImage {
    /// A snapshot strategy for comparing SwiftUI Views based on pixel equality.
    ///
    /// - Parameters:
    ///   - size: The size of the view.
    ///   - precision: The percentage of pixels that must match.
    ///   - subpixelThreshold: The byte-value threshold at which two subpixels are considered different.
    static func image(
        size: CGSize,
        precision: Float = 1,
        subpixelThreshold: UInt8 = 0
    ) -> Snapshotting {
        return SimplySnapshotting.image(precision: precision, subpixelThreshold: subpixelThreshold).asyncPullback { view in
            let hostingView = NSHostingView(rootView: view)
            hostingView.frame.size = size

            return Async { callback in
                guard let bitmapRep = NSBitmapImageRep(
                    bitmapDataPlanes: nil,
                    pixelsWide: Int(hostingView.bounds.width),
                    pixelsHigh: Int(hostingView.bounds.height),
                    bitsPerSample: 8,
                    samplesPerPixel: 4,
                    hasAlpha: true,
                    isPlanar: false,
                    colorSpaceName: .deviceRGB,
                    bytesPerRow: 4 * Int(hostingView.bounds.width),
                    bitsPerPixel: 32
                ) else { return callback(NSImage()) }

                hostingView.cacheDisplay(in: hostingView.bounds, to: bitmapRep)
                let image = NSImage(size: hostingView.bounds.size)
                image.addRepresentation(bitmapRep)
                callback(image)
            }
        }
    }
}
#endif
#endif
