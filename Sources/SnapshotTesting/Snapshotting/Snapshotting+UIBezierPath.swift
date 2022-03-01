#if os(iOS) || os(tvOS)
import UIKit

public extension Snapshotting where Value == UIBezierPath, Format == UIImage {
    /// A snapshot strategy for comparing bezier paths based on pixel equality.
    static var image: Snapshotting {
        .image()
    }

    /// A snapshot strategy for comparing bezier paths based on pixel equality.
    ///
    /// - Parameter precision: The percentage of pixels that must match.
    /// - Parameter subpixelThreshold: The byte-value threshold at which two subpixels are considered different.
    static func image(precision: Float = 1, subpixelThreshold: UInt8 = 0, scale: CGFloat = 1) -> Snapshotting {
        SimplySnapshotting.image(precision: precision, subpixelThreshold: subpixelThreshold, scale: scale).pullback { path in
            let bounds = path.bounds
            let format: UIGraphicsImageRendererFormat
            if #available(iOS 11.0, tvOS 11.0, *) {
                format = UIGraphicsImageRendererFormat.preferred()
            } else {
                format = UIGraphicsImageRendererFormat.default()
            }
            format.scale = scale
            return UIGraphicsImageRenderer(bounds: bounds, format: format).image { _ in
                path.fill()
            }
        }
    }
}

@available(iOS 11.0, tvOS 11.0, *)
public extension Snapshotting where Value == UIBezierPath, Format == String {
    /// A snapshot strategy for comparing bezier paths based on pixel equality.
    static var elementsDescription: Snapshotting {
        Snapshotting<CGPath, String>.elementsDescription.pullback { path in path.cgPath }
    }

    /// A snapshot strategy for comparing bezier paths based on pixel equality.
    ///
    /// - Parameter numberFormatter: The number formatter used for formatting points.
    static func elementsDescription(numberFormatter: NumberFormatter) -> Snapshotting {
        Snapshotting<CGPath, String>.elementsDescription(
            numberFormatter: numberFormatter
        ).pullback { path in path.cgPath }
    }
}
#endif
