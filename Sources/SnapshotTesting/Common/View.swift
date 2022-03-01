// swiftlint:disable file_length

#if os(iOS) || os(macOS) || os(tvOS)
#if os(macOS)
import Cocoa
#endif
import SceneKit
import SpriteKit
#if os(iOS) || os(tvOS)
import UIKit
#endif
#if os(iOS) || os(macOS)
import WebKit
#endif

#if os(iOS) || os(tvOS)
public struct ViewImageConfig {
    public enum Orientation {
        case landscape
        case portrait
    }

    public enum TabletOrientation {
        public enum PortraitSplits {
            case oneThird
            case twoThirds
            case full
        }

        public enum LandscapeSplits {
            case oneThird
            case oneHalf
            case twoThirds
            case full
        }

        case landscape(splitView: LandscapeSplits)
        case portrait(splitView: PortraitSplits)
    }

    public var safeArea: UIEdgeInsets
    public var size: CGSize?
    public var traits: UITraitCollection

    public init(
        safeArea: UIEdgeInsets = .zero,
        size: CGSize? = nil,
        traits: UITraitCollection = .init()
    ) {
        self.safeArea = safeArea
        self.size = size
        self.traits = traits
    }
}

public extension ViewImageConfig {
    #if os(iOS)
    static let iPhoneSe = ViewImageConfig.iPhoneSe(.portrait)

    static func iPhoneSe(_ orientation: Orientation) -> ViewImageConfig {
        let safeArea: UIEdgeInsets
        let size: CGSize
        switch orientation {
        case .landscape:
            safeArea = .zero
            size = .init(width: 568, height: 320)
        case .portrait:
            safeArea = .init(top: 20, left: 0, bottom: 0, right: 0)
            size = .init(width: 320, height: 568)
        }
        return .init(safeArea: safeArea, size: size, traits: .iPhoneSe(orientation))
    }

    static let iPhone8 = ViewImageConfig.iPhone8(.portrait)

    static func iPhone8(_ orientation: Orientation) -> ViewImageConfig {
        let safeArea: UIEdgeInsets
        let size: CGSize
        switch orientation {
        case .landscape:
            safeArea = .zero
            size = .init(width: 667, height: 375)
        case .portrait:
            safeArea = .init(top: 20, left: 0, bottom: 0, right: 0)
            size = .init(width: 375, height: 667)
        }
        return .init(safeArea: safeArea, size: size, traits: .iPhone8(orientation))
    }

    static let iPhone8Plus = ViewImageConfig.iPhone8Plus(.portrait)

    static func iPhone8Plus(_ orientation: Orientation) -> ViewImageConfig {
        let safeArea: UIEdgeInsets
        let size: CGSize
        switch orientation {
        case .landscape:
            safeArea = .zero
            size = .init(width: 736, height: 414)
        case .portrait:
            safeArea = .init(top: 20, left: 0, bottom: 0, right: 0)
            size = .init(width: 414, height: 736)
        }
        return .init(safeArea: safeArea, size: size, traits: .iPhone8Plus(orientation))
    }

    static let iPhoneX = ViewImageConfig.iPhoneX(.portrait)

    static func iPhoneX(_ orientation: Orientation) -> ViewImageConfig {
        let safeArea: UIEdgeInsets
        let size: CGSize
        switch orientation {
        case .landscape:
            safeArea = .init(top: 0, left: 44, bottom: 24, right: 44)
            size = .init(width: 812, height: 375)
        case .portrait:
            safeArea = .init(top: 44, left: 0, bottom: 34, right: 0)
            size = .init(width: 375, height: 812)
        }
        return .init(safeArea: safeArea, size: size, traits: .iPhoneX(orientation))
    }

    static let iPhoneXsMax = ViewImageConfig.iPhoneXsMax(.portrait)

    static func iPhoneXsMax(_ orientation: Orientation) -> ViewImageConfig {
        let safeArea: UIEdgeInsets
        let size: CGSize
        switch orientation {
        case .landscape:
            safeArea = .init(top: 0, left: 44, bottom: 24, right: 44)
            size = .init(width: 896, height: 414)
        case .portrait:
            safeArea = .init(top: 44, left: 0, bottom: 34, right: 0)
            size = .init(width: 414, height: 896)
        }
        return .init(safeArea: safeArea, size: size, traits: .iPhoneXsMax(orientation))
    }

    @available(iOS 11.0, *)
    static let iPhoneXr = ViewImageConfig.iPhoneXr(.portrait)

    @available(iOS 11.0, *)
    static func iPhoneXr(_ orientation: Orientation) -> ViewImageConfig {
        let safeArea: UIEdgeInsets
        let size: CGSize
        switch orientation {
        case .landscape:
            safeArea = .init(top: 0, left: 44, bottom: 24, right: 44)
            size = .init(width: 896, height: 414)
        case .portrait:
            safeArea = .init(top: 44, left: 0, bottom: 34, right: 0)
            size = .init(width: 414, height: 896)
        }
        return .init(safeArea: safeArea, size: size, traits: .iPhoneXr(orientation))
    }

    static let iPhone12 = ViewImageConfig.iPhone12(.portrait)

    static func iPhone12(_ orientation: Orientation) -> ViewImageConfig {
        let safeArea: UIEdgeInsets
        let size: CGSize
        switch orientation {
        case .landscape:
            safeArea = .init(top: 0, left: 47, bottom: 21, right: 47)
            size = .init(width: 844, height: 390)
        case .portrait:
            safeArea = .init(top: 47, left: 0, bottom: 34, right: 0)
            size = .init(width: 390, height: 844)
        }
        return .init(safeArea: safeArea, size: size, traits: .iPhone12(orientation))
    }

    static let iPhone12ProMax = ViewImageConfig.iPhone12ProMax(.portrait)

    static func iPhone12ProMax(_ orientation: Orientation) -> ViewImageConfig {
        let safeArea: UIEdgeInsets
        let size: CGSize
        switch orientation {
        case .landscape:
            safeArea = .init(top: 0, left: 47, bottom: 21, right: 47)
            size = .init(width: 926, height: 428)
        case .portrait:
            safeArea = .init(top: 47, left: 0, bottom: 34, right: 0)
            size = .init(width: 428, height: 926)
        }
        return .init(safeArea: safeArea, size: size, traits: .iPhone12ProMax(orientation))
    }

    static let iPadMini = ViewImageConfig.iPadMini(.landscape)

    static func iPadMini(_ orientation: Orientation) -> ViewImageConfig {
        switch orientation {
        case .landscape:
            return ViewImageConfig.iPadMini(.landscape(splitView: .full))
        case .portrait:
            return ViewImageConfig.iPadMini(.portrait(splitView: .full))
        }
    }

    static func iPadMini(_ orientation: TabletOrientation) -> ViewImageConfig {
        let size: CGSize
        let traits: UITraitCollection
        switch orientation {
        case let .landscape(splitView):
            switch splitView {
            case .oneThird:
                size = .init(width: 320, height: 768)
                traits = .iPadMini_Compact_SplitView
            case .oneHalf:
                size = .init(width: 507, height: 768)
                traits = .iPadMini_Compact_SplitView
            case .twoThirds:
                size = .init(width: 694, height: 768)
                traits = .iPadMini
            case .full:
                size = .init(width: 1024, height: 768)
                traits = .iPadMini
            }
        case let .portrait(splitView):
            switch splitView {
            case .oneThird:
                size = .init(width: 320, height: 1024)
                traits = .iPadMini_Compact_SplitView
            case .twoThirds:
                size = .init(width: 438, height: 1024)
                traits = .iPadMini_Compact_SplitView
            case .full:
                size = .init(width: 768, height: 1024)
                traits = .iPadMini
            }
        }
        return .init(safeArea: .init(top: 20, left: 0, bottom: 0, right: 0), size: size, traits: traits)
    }

    static let iPad9_7 = iPadMini

    static func iPad9_7(_ orientation: Orientation) -> ViewImageConfig {
        iPadMini(orientation)
    }

    static func iPad9_7(_ orientation: TabletOrientation) -> ViewImageConfig {
        iPadMini(orientation)
    }

    static let iPad10_2 = ViewImageConfig.iPad10_2(.landscape)

    static func iPad10_2(_ orientation: Orientation) -> ViewImageConfig {
        switch orientation {
        case .landscape:
            return ViewImageConfig.iPad10_2(.landscape(splitView: .full))
        case .portrait:
            return ViewImageConfig.iPad10_2(.portrait(splitView: .full))
        }
    }

    static func iPad10_2(_ orientation: TabletOrientation) -> ViewImageConfig {
        let size: CGSize
        let traits: UITraitCollection
        switch orientation {
        case let .landscape(splitView):
            switch splitView {
            case .oneThird:
                size = .init(width: 320, height: 810)
                traits = .iPad10_2_Compact_SplitView
            case .oneHalf:
                size = .init(width: 535, height: 810)
                traits = .iPad10_2_Compact_SplitView
            case .twoThirds:
                size = .init(width: 750, height: 810)
                traits = .iPad10_2
            case .full:
                size = .init(width: 1080, height: 810)
                traits = .iPad10_2
            }
        case let .portrait(splitView):
            switch splitView {
            case .oneThird:
                size = .init(width: 320, height: 1080)
                traits = .iPad10_2_Compact_SplitView
            case .twoThirds:
                size = .init(width: 480, height: 1080)
                traits = .iPad10_2_Compact_SplitView
            case .full:
                size = .init(width: 810, height: 1080)
                traits = .iPad10_2
            }
        }
        return .init(safeArea: .init(top: 20, left: 0, bottom: 0, right: 0), size: size, traits: traits)
    }

    static let iPadPro10_5 = ViewImageConfig.iPadPro10_5(.landscape)

    static func iPadPro10_5(_ orientation: Orientation) -> ViewImageConfig {
        switch orientation {
        case .landscape:
            return ViewImageConfig.iPadPro10_5(.landscape(splitView: .full))
        case .portrait:
            return ViewImageConfig.iPadPro10_5(.portrait(splitView: .full))
        }
    }

    static func iPadPro10_5(_ orientation: TabletOrientation) -> ViewImageConfig {
        let size: CGSize
        let traits: UITraitCollection
        switch orientation {
        case let .landscape(splitView):
            switch splitView {
            case .oneThird:
                size = .init(width: 320, height: 834)
                traits = .iPadPro10_5_Compact_SplitView
            case .oneHalf:
                size = .init(width: 551, height: 834)
                traits = .iPadPro10_5_Compact_SplitView
            case .twoThirds:
                size = .init(width: 782, height: 834)
                traits = .iPadPro10_5
            case .full:
                size = .init(width: 1112, height: 834)
                traits = .iPadPro10_5
            }
        case let .portrait(splitView):
            switch splitView {
            case .oneThird:
                size = .init(width: 320, height: 1112)
                traits = .iPadPro10_5_Compact_SplitView
            case .twoThirds:
                size = .init(width: 504, height: 1112)
                traits = .iPadPro10_5_Compact_SplitView
            case .full:
                size = .init(width: 834, height: 1112)
                traits = .iPadPro10_5
            }
        }
        return .init(safeArea: .init(top: 20, left: 0, bottom: 0, right: 0), size: size, traits: traits)
    }

    static let iPadPro11 = ViewImageConfig.iPadPro11(.landscape)

    static func iPadPro11(_ orientation: Orientation) -> ViewImageConfig {
        switch orientation {
        case .landscape:
            return ViewImageConfig.iPadPro11(.landscape(splitView: .full))
        case .portrait:
            return ViewImageConfig.iPadPro11(.portrait(splitView: .full))
        }
    }

    static func iPadPro11(_ orientation: TabletOrientation) -> ViewImageConfig {
        let size: CGSize
        let traits: UITraitCollection
        switch orientation {
        case let .landscape(splitView):
            switch splitView {
            case .oneThird:
                size = .init(width: 375, height: 834)
                traits = .iPadPro11_Compact_SplitView
            case .oneHalf:
                size = .init(width: 592, height: 834)
                traits = .iPadPro11_Compact_SplitView
            case .twoThirds:
                size = .init(width: 809, height: 834)
                traits = .iPadPro11
            case .full:
                size = .init(width: 1194, height: 834)
                traits = .iPadPro11
            }
        case let .portrait(splitView):
            switch splitView {
            case .oneThird:
                size = .init(width: 320, height: 1194)
                traits = .iPadPro11_Compact_SplitView
            case .twoThirds:
                size = .init(width: 504, height: 1194)
                traits = .iPadPro11_Compact_SplitView
            case .full:
                size = .init(width: 834, height: 1194)
                traits = .iPadPro11
            }
        }
        return .init(safeArea: .init(top: 24, left: 0, bottom: 20, right: 0), size: size, traits: traits)
    }

    static let iPadPro12_9 = ViewImageConfig.iPadPro12_9(.landscape)

    static func iPadPro12_9(_ orientation: Orientation) -> ViewImageConfig {
        switch orientation {
        case .landscape:
            return ViewImageConfig.iPadPro12_9(.landscape(splitView: .full))
        case .portrait:
            return ViewImageConfig.iPadPro12_9(.portrait(splitView: .full))
        }
    }

    static func iPadPro12_9(_ orientation: TabletOrientation) -> ViewImageConfig {
        let size: CGSize
        let traits: UITraitCollection
        switch orientation {
        case let .landscape(splitView):
            switch splitView {
            case .oneThird:
                size = .init(width: 375, height: 1024)
                traits = .iPadPro12_9_Compact_SplitView
            case .oneHalf:
                size = .init(width: 678, height: 1024)
                traits = .iPadPro12_9
            case .twoThirds:
                size = .init(width: 981, height: 1024)
                traits = .iPadPro12_9
            case .full:
                size = .init(width: 1366, height: 1024)
                traits = .iPadPro12_9
            }

        case let .portrait(splitView):
            switch splitView {
            case .oneThird:
                size = .init(width: 375, height: 1366)
                traits = .iPadPro12_9_Compact_SplitView
            case .twoThirds:
                size = .init(width: 639, height: 1366)
                traits = .iPadPro12_9_Compact_SplitView
            case .full:
                size = .init(width: 1024, height: 1366)
                traits = .iPadPro12_9
            }
        }
        return .init(safeArea: .init(top: 20, left: 0, bottom: 0, right: 0), size: size, traits: traits)
    }

    #elseif os(tvOS)
    static let tv = ViewImageConfig(
        safeArea: .init(top: 60, left: 90, bottom: 60, right: 90),
        size: .init(width: 1920, height: 1080),
        traits: .init()
    )
    static let tv4K = ViewImageConfig(
        safeArea: .init(top: 120, left: 180, bottom: 120, right: 180),
        size: .init(width: 3840, height: 2160),
        traits: .init()
    )
    #endif
}

public extension UITraitCollection {
    #if os(iOS)
    static func iPhoneSe(_ orientation: ViewImageConfig.Orientation) -> UITraitCollection {
        let base: [UITraitCollection] = [
            //        .init(displayGamut: .SRGB),
//        .init(displayScale: 2),
            .init(forceTouchCapability: .available),
            .init(layoutDirection: .leftToRight),
            .init(preferredContentSizeCategory: .medium),
            .init(userInterfaceIdiom: .phone)
        ]
        switch orientation {
        case .landscape:
            return .init(
                traitsFrom: base + [
                    .init(horizontalSizeClass: .compact),
                    .init(verticalSizeClass: .compact)
                ]
            )
        case .portrait:
            return .init(
                traitsFrom: base + [
                    .init(horizontalSizeClass: .compact),
                    .init(verticalSizeClass: .regular)
                ]
            )
        }
    }

    static func iPhone8(_ orientation: ViewImageConfig.Orientation) -> UITraitCollection {
        let base: [UITraitCollection] = [
            //        .init(displayGamut: .P3),
//        .init(displayScale: 2),
            .init(forceTouchCapability: .available),
            .init(layoutDirection: .leftToRight),
            .init(preferredContentSizeCategory: .medium),
            .init(userInterfaceIdiom: .phone)
        ]
        switch orientation {
        case .landscape:
            return .init(
                traitsFrom: base + [
                    .init(horizontalSizeClass: .compact),
                    .init(verticalSizeClass: .compact)
                ]
            )
        case .portrait:
            return .init(
                traitsFrom: base + [
                    .init(horizontalSizeClass: .compact),
                    .init(verticalSizeClass: .regular)
                ]
            )
        }
    }

    static func iPhone8Plus(_ orientation: ViewImageConfig.Orientation) -> UITraitCollection {
        let base: [UITraitCollection] = [
            //        .init(displayGamut: .P3),
//        .init(displayScale: 3),
            .init(forceTouchCapability: .available),
            .init(layoutDirection: .leftToRight),
            .init(preferredContentSizeCategory: .medium),
            .init(userInterfaceIdiom: .phone)
        ]
        switch orientation {
        case .landscape:
            return .init(
                traitsFrom: base + [
                    .init(horizontalSizeClass: .regular),
                    .init(verticalSizeClass: .compact)
                ]
            )
        case .portrait:
            return .init(
                traitsFrom: base + [
                    .init(horizontalSizeClass: .compact),
                    .init(verticalSizeClass: .regular)
                ]
            )
        }
    }

    static func iPhoneX(_ orientation: ViewImageConfig.Orientation) -> UITraitCollection {
        let base: [UITraitCollection] = [
            //        .init(displayGamut: .P3),
//        .init(displayScale: 3),
            .init(forceTouchCapability: .available),
            .init(layoutDirection: .leftToRight),
            .init(preferredContentSizeCategory: .medium),
            .init(userInterfaceIdiom: .phone)
        ]
        switch orientation {
        case .landscape:
            return .init(
                traitsFrom: base + [
                    .init(horizontalSizeClass: .compact),
                    .init(verticalSizeClass: .compact)
                ]
            )
        case .portrait:
            return .init(
                traitsFrom: base + [
                    .init(horizontalSizeClass: .compact),
                    .init(verticalSizeClass: .regular)
                ]
            )
        }
    }

    static func iPhoneXr(_ orientation: ViewImageConfig.Orientation) -> UITraitCollection {
        let base: [UITraitCollection] = [
            //        .init(displayGamut: .P3),
//        .init(displayScale: 2),
            .init(forceTouchCapability: .unavailable),
            .init(layoutDirection: .leftToRight),
            .init(preferredContentSizeCategory: .medium),
            .init(userInterfaceIdiom: .phone)
        ]
        switch orientation {
        case .landscape:
            return .init(
                traitsFrom: base + [
                    .init(horizontalSizeClass: .regular),
                    .init(verticalSizeClass: .compact)
                ]
            )
        case .portrait:
            return .init(
                traitsFrom: base + [
                    .init(horizontalSizeClass: .compact),
                    .init(verticalSizeClass: .regular)
                ]
            )
        }
    }

    static func iPhoneXsMax(_ orientation: ViewImageConfig.Orientation) -> UITraitCollection {
        let base: [UITraitCollection] = [
            //        .init(displayGamut: .P3),
//        .init(displayScale: 3),
            .init(forceTouchCapability: .available),
            .init(layoutDirection: .leftToRight),
            .init(preferredContentSizeCategory: .medium),
            .init(userInterfaceIdiom: .phone)
        ]
        switch orientation {
        case .landscape:
            return .init(
                traitsFrom: base + [
                    .init(horizontalSizeClass: .regular),
                    .init(verticalSizeClass: .compact)
                ]
            )
        case .portrait:
            return .init(
                traitsFrom: base + [
                    .init(horizontalSizeClass: .compact),
                    .init(verticalSizeClass: .regular)
                ]
            )
        }
    }

    static func iPhone12(_ orientation: ViewImageConfig.Orientation) -> UITraitCollection {
        let base: [UITraitCollection] = [
            //    .init(displayGamut: .P3),
//    .init(displayScale: 3),
            .init(forceTouchCapability: .available),
            .init(layoutDirection: .leftToRight),
            .init(preferredContentSizeCategory: .medium),
            .init(userInterfaceIdiom: .phone)
        ]
        switch orientation {
        case .landscape:
            return .init(
                traitsFrom: base + [
                    .init(horizontalSizeClass: .compact),
                    .init(verticalSizeClass: .compact)
                ]
            )
        case .portrait:
            return .init(
                traitsFrom: base + [
                    .init(horizontalSizeClass: .compact),
                    .init(verticalSizeClass: .regular)
                ]
            )
        }
    }

    static func iPhone12ProMax(_ orientation: ViewImageConfig.Orientation) -> UITraitCollection {
        let base: [UITraitCollection] = [
            //    .init(displayGamut: .P3),
            //    .init(displayScale: 3),
            .init(forceTouchCapability: .available),
            .init(layoutDirection: .leftToRight),
            .init(preferredContentSizeCategory: .medium),
            .init(userInterfaceIdiom: .phone)
        ]
        switch orientation {
        case .landscape:
            return .init(
                traitsFrom: base + [
                    .init(horizontalSizeClass: .regular),
                    .init(verticalSizeClass: .compact)
                ]
            )
        case .portrait:
            return .init(
                traitsFrom: base + [
                    .init(horizontalSizeClass: .compact),
                    .init(verticalSizeClass: .regular)
                ]
            )
        }
    }

    static let iPadMini = iPad
    static let iPadMini_Compact_SplitView = iPadCompactSplitView
    static let iPad9_7 = iPad
    static let iPad9_7_Compact_SplitView = iPadCompactSplitView
    static let iPad10_2 = iPad
    static let iPad10_2_Compact_SplitView = iPadCompactSplitView
    static let iPadPro10_5 = iPad
    static let iPadPro10_5_Compact_SplitView = iPadCompactSplitView
    static let iPadPro11 = iPad
    static let iPadPro11_Compact_SplitView = iPadCompactSplitView
    static let iPadPro12_9 = iPad
    static let iPadPro12_9_Compact_SplitView = iPadCompactSplitView

    private static let iPad = UITraitCollection(
        traitsFrom: [
            //      .init(displayScale: 2),
            .init(horizontalSizeClass: .regular),
            .init(verticalSizeClass: .regular),
            .init(userInterfaceIdiom: .pad)
        ]
    )

    private static let iPadCompactSplitView = UITraitCollection(
        traitsFrom: [
            .init(horizontalSizeClass: .compact),
            .init(verticalSizeClass: .regular),
            .init(userInterfaceIdiom: .pad)
        ]
    )
    #elseif os(tvOS)
    // to be implemented
    #endif
}
#endif

func addImagesForRenderedViews(_ view: View) -> [Async<View>] {
    view.snapshot
        .map { async in
            [
                Async { callback in
                    async.run { image in
                        let imageView = ImageView()
                        imageView.image = image
                        imageView.frame = view.frame
                        #if os(macOS)
                        view.superview?.addSubview(imageView, positioned: .above, relativeTo: view)
                        #elseif os(iOS) || os(tvOS)
                        view.superview?.insertSubview(imageView, aboveSubview: view)
                        #endif
                        callback(imageView)
                    }
                }
            ]
        }
        ?? view.subviews.flatMap(addImagesForRenderedViews)
}

extension View {
    var snapshot: Async<Image>? {
        func inWindow<T>(_ perform: () -> T) -> T {
            #if os(macOS)
            let superview = superview
            defer { superview?.addSubview(self) }
            let window = ScaledWindow()
            window.contentView = NSView()
            window.contentView?.addSubview(self)
            window.makeKey()
            #endif
            return perform()
        }
        if let scnView = self as? SCNView {
            return Async(value: inWindow { scnView.snapshot() })
        } else if let skView = self as? SKView {
            if #available(macOS 10.11, *) {
                let cgImage = inWindow { skView.texture(from: skView.scene!)!.cgImage() } // swiftlint:disable:this force_unwrapping
                #if os(macOS)
                let image = Image(cgImage: cgImage, size: skView.bounds.size)
                #elseif os(iOS) || os(tvOS)
                let image = Image(cgImage: cgImage)
                #endif
                return Async(value: image)
            } else {
                fatalError("Taking SKView snapshots requires macOS 10.11 or greater")
            }
        }
        #if os(iOS) || os(macOS)
        if let wkWebView = self as? WKWebView {
            return Async<Image> { callback in
                let work = {
                    if #available(iOS 11.0, macOS 10.13, *) {
                        inWindow {
                            guard wkWebView.frame.width != 0, wkWebView.frame.height != 0 else {
                                callback(Image())
                                return
                            }
                            wkWebView.takeSnapshot(with: nil) { image, _ in
                                callback(image!) // swiftlint:disable:this force_unwrapping
                            }
                        }
                    } else {
                        #if os(iOS)
                        fatalError("Taking WKWebView snapshots requires iOS 11.0 or greater")
                        #elseif os(macOS)
                        fatalError("Taking WKWebView snapshots requires macOS 10.13 or greater")
                        #endif
                    }
                }

                if wkWebView.isLoading {
                    var subscription: NSKeyValueObservation?
                    subscription = wkWebView.observe(\.isLoading, options: [.initial, .new]) { _, change in
                        subscription?.invalidate()
                        subscription = nil
                        if change.newValue == false {
                            work()
                        }
                    }
                } else {
                    work()
                }
            }
        }
        #endif
        return nil
    }

    #if os(iOS) || os(tvOS)
    func asImage() -> Image {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    #endif
}

#if os(iOS) || os(tvOS)
extension UIApplication {
    static var sharedIfAvailable: UIApplication? {
        let sharedSelector = NSSelectorFromString("sharedApplication")
        guard UIApplication.responds(to: sharedSelector) else {
            return nil
        }

        let shared = UIApplication.perform(sharedSelector)
        return shared?.takeUnretainedValue() as? UIApplication
    }
}

func prepareView(
    config: ViewImageConfig,
    drawHierarchyInKeyWindow: Bool,
    traits: UITraitCollection,
    view: UIView,
    viewController: UIViewController
) -> () -> Void {
    let size = config.size ?? viewController.view.frame.size
    view.frame.size = size
    if view != viewController.view {
        viewController.view.bounds = view.bounds
        viewController.view.addSubview(view)
    }
    let traits = UITraitCollection(traitsFrom: [config.traits, traits])
    let window: UIWindow
    if drawHierarchyInKeyWindow {
        guard let keyWindow = getKeyWindow() else {
            fatalError("'drawHierarchyInKeyWindow' requires tests to be run in a host application")
        }
        window = keyWindow
        window.frame.size = size
    } else {
        window = Window(
            config: .init(safeArea: config.safeArea, size: config.size ?? size, traits: traits),
            viewController: viewController
        )
    }
    let dispose = add(traits: traits, viewController: viewController, to: window)

    if size.width == 0 || size.height == 0 {
        // Try to call sizeToFit() if the view still has invalid size
        view.sizeToFit()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    return dispose
}

func snapshotView(
    config: ViewImageConfig,
    drawHierarchyInKeyWindow: Bool,
    traits: UITraitCollection,
    view: UIView,
    viewController: UIViewController
) -> Async<UIImage> {
    let initialFrame = view.frame
    let dispose = prepareView(
        config: config,
        drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
        traits: traits,
        view: view,
        viewController: viewController
    )
    // NB: Avoid safe area influence.
    if config.safeArea == .zero { view.frame.origin = .init(x: offscreen, y: offscreen) }

    return (view.snapshot ?? Async { callback in
        addImagesForRenderedViews(view).sequence().run { views in
            callback(
                renderer(bounds: view.bounds, for: traits).image { ctx in
                    if drawHierarchyInKeyWindow {
                        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
                    } else {
                        view.layer.render(in: ctx.cgContext)
                    }
                }
            )
            views.forEach { $0.removeFromSuperview() }
            view.frame = initialFrame
        }
    }).map { dispose(); return $0 }
}

private let offscreen: CGFloat = 10000

func renderer(bounds: CGRect, for traits: UITraitCollection) -> UIGraphicsImageRenderer {
    let renderer: UIGraphicsImageRenderer
    if #available(iOS 11.0, tvOS 11.0, *) {
        renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traits))
    } else {
        renderer = UIGraphicsImageRenderer(bounds: bounds)
    }
    return renderer
}

private func add(traits: UITraitCollection, viewController: UIViewController, to window: UIWindow) -> () -> Void {
    let rootViewController: UIViewController
    if viewController != window.rootViewController {
        rootViewController = RootViewController()
        rootViewController.view.backgroundColor = .clear
        rootViewController.view.frame = window.frame
        rootViewController.view.translatesAutoresizingMaskIntoConstraints = viewController.view.translatesAutoresizingMaskIntoConstraints
        rootViewController.preferredContentSize = rootViewController.view.frame.size
        viewController.view.frame = rootViewController.view.frame
        rootViewController.view.addSubview(viewController.view)

        if viewController.view.translatesAutoresizingMaskIntoConstraints {
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        } else {
            NSLayoutConstraint.activate([
                viewController.view.topAnchor.constraint(equalTo: rootViewController.view.topAnchor),
                viewController.view.bottomAnchor.constraint(equalTo: rootViewController.view.bottomAnchor),
                viewController.view.leadingAnchor.constraint(equalTo: rootViewController.view.leadingAnchor),
                viewController.view.trailingAnchor.constraint(equalTo: rootViewController.view.trailingAnchor)
            ])
        }
        rootViewController.addChild(viewController)
    } else {
        rootViewController = viewController
    }

    rootViewController.setOverrideTraitCollection(traits, forChild: viewController)
    viewController.didMove(toParent: rootViewController)

    window.rootViewController = rootViewController

    viewController.beginAppearanceTransition(true, animated: false)
    viewController.endAppearanceTransition()

    rootViewController.view.setNeedsLayout()
    rootViewController.view.layoutIfNeeded()

    viewController.view.setNeedsLayout()
    viewController.view.layoutIfNeeded()

    return {
        viewController.beginAppearanceTransition(false, animated: false)
        viewController.endAppearanceTransition()
        window.rootViewController = nil
    }
}

private func getKeyWindow() -> UIWindow? {
    var window: UIWindow?
    if #available(iOS 13.0, *) {
        window = UIApplication.sharedIfAvailable?.windows.first { $0.isKeyWindow }
    } else {
        window = UIApplication.sharedIfAvailable?.keyWindow
    }
    return window
}

private final class Window: UIWindow {
    var config: ViewImageConfig

    init(config: ViewImageConfig, viewController: UIViewController) {
        let size = config.size ?? viewController.view.bounds.size
        self.config = config
        super.init(frame: .init(origin: .zero, size: size))

        // NB: Safe area renders inaccurately for UI{Navigation,TabBar}Controller.
        // Fixes welcome!
        if viewController is UINavigationController {
            frame.size.height -= self.config.safeArea.top
            self.config.safeArea.top = 0
        } else if let viewController = viewController as? UITabBarController {
            frame.size.height -= self.config.safeArea.bottom
            self.config.safeArea.bottom = 0
            if viewController.selectedViewController is UINavigationController {
                frame.size.height -= self.config.safeArea.top
                self.config.safeArea.top = 0
            }
        }
        isHidden = false
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(iOS 11.0, *)
    override var safeAreaInsets: UIEdgeInsets {
        #if os(iOS)
        let removeTopInset = config.safeArea == .init(top: 20, left: 0, bottom: 0, right: 0)
            && rootViewController?.prefersStatusBarHidden ?? false
        if removeTopInset { return .zero }
        #endif
        return config.safeArea
    }
}

private final class RootViewController: UIViewController {
    override var shouldAutomaticallyForwardAppearanceMethods: Bool { false }
}
#endif

#if os(macOS)
private final class ScaledWindow: NSWindow {
    override var backingScaleFactor: CGFloat {
        2
    }
}
#endif
#endif

extension Array {
    func sequence<A>() -> Async<[A]> where Element == Async<A> {
        guard !isEmpty else { return Async(value: []) }
        return Async<[A]> { callback in
            var result = [A?](repeating: nil, count: self.count)
            result.reserveCapacity(self.count)
            var count = 0
            zip(self.indices, self).forEach { idx, async in
                async.run {
                    result[idx] = $0
                    count += 1
                    if count == self.count {
                        callback(result as! [A]) // swiftlint:disable:this force_cast
                    }
                }
            }
        }
    }
}
