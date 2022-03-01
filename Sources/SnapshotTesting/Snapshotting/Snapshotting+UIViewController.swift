#if os(iOS) || os(tvOS)
import UIKit

public extension Snapshotting where Value == UIViewController, Format == UIImage {
    /// A snapshot strategy for comparing view controller views based on pixel equality.
    static var image: Snapshotting {
        .image()
    }

    /// A snapshot strategy for comparing view controller views based on pixel equality.
    ///
    /// - Parameters:
    ///   - config: A set of device configuration settings.
    ///   - precision: The percentage of pixels that must match.
    ///   - subpixelThreshold: The byte-value threshold at which two subpixels are considered different.
    ///   - size: A view size override.
    ///   - traits: A trait collection override.
    static func image(
        on config: ViewImageConfig,
        precision: Float = 1,
        subpixelThreshold: UInt8 = 0,
        size: CGSize? = nil,
        traits: UITraitCollection = .init()
    ) -> Snapshotting {
        SimplySnapshotting.image(precision: precision, subpixelThreshold: subpixelThreshold, scale: traits.displayScale).asyncPullback { viewController in
            snapshotView(
                config: size.map { .init(safeArea: config.safeArea, size: $0, traits: config.traits) } ?? config,
                drawHierarchyInKeyWindow: false,
                traits: traits,
                view: viewController.view,
                viewController: viewController
            )
        }
    }

    /// A snapshot strategy for comparing view controller views based on pixel equality.
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
        size: CGSize? = nil,
        traits: UITraitCollection = .init()
    ) -> Snapshotting {
        SimplySnapshotting.image(precision: precision, subpixelThreshold: subpixelThreshold, scale: traits.displayScale).asyncPullback { viewController in
            snapshotView(
                config: .init(safeArea: .zero, size: size, traits: traits),
                drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
                traits: traits,
                view: viewController.view,
                viewController: viewController
            )
        }
    }
}

public extension Snapshotting where Value == UIViewController, Format == String {
    /// A snapshot strategy for comparing view controllers based on their embedded controller hierarchy.
    static var hierarchy: Snapshotting {
        Snapshotting<String, String>.lines.pullback { viewController in
            let dispose = prepareView(
                config: .init(),
                drawHierarchyInKeyWindow: false,
                traits: .init(),
                view: viewController.view,
                viewController: viewController
            )
            defer { dispose() }
            return purgePointers(
                viewController.perform(Selector(("_printHierarchy"))).retain().takeUnretainedValue() as! String // swiftlint:disable:this force_cast
            )
        }
    }

    /// A snapshot strategy for comparing view controller views based on a recursive description of their properties and hierarchies.
    static var recursiveDescription: Snapshotting {
        Snapshotting.recursiveDescription()
    }

    /// A snapshot strategy for comparing view controller views based on a recursive description of their properties and hierarchies.
    ///
    /// - Parameters:
    ///   - config: A set of device configuration settings.
    ///   - size: A view size override.
    ///   - traits: A trait collection override.
    static func recursiveDescription(
        on config: ViewImageConfig = .init(),
        size: CGSize? = nil,
        traits: UITraitCollection = .init()
    ) -> Snapshotting<UIViewController, String> {
        SimplySnapshotting.lines.pullback { viewController in
            let dispose = prepareView(
                config: .init(safeArea: config.safeArea, size: size ?? config.size, traits: config.traits),
                drawHierarchyInKeyWindow: false,
                traits: traits,
                view: viewController.view,
                viewController: viewController
            )
            defer { dispose() }
            return purgePointers(
                viewController.view.perform(Selector(("recursiveDescription"))).retain().takeUnretainedValue() as! String // swiftlint:disable:this force_cast
            )
        }
    }
}
#endif
