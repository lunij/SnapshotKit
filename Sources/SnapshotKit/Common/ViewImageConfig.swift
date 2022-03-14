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
#endif

extension View {
    func addImagesForRenderedViews() -> [Async<View>] {
        snapshot.map { async in
            [
                Async { callback in
                    async.run { image in
                        let imageView = ImageView()
                        imageView.image = image
                        imageView.frame = self.frame
                        #if os(macOS)
                        self.superview?.addSubview(imageView, positioned: .above, relativeTo: self)
                        #elseif os(iOS) || os(tvOS)
                        self.superview?.insertSubview(imageView, aboveSubview: self)
                        #endif
                        callback(imageView)
                    }
                }
            ]
        } ?? subviews.flatMap { $0.addImagesForRenderedViews() }
    }

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
            let cgImage = inWindow { skView.texture(from: skView.scene!)!.cgImage() } // swiftlint:disable:this force_unwrapping
            #if os(macOS)
            let image = Image(cgImage: cgImage, size: skView.bounds.size)
            #elseif os(iOS) || os(tvOS)
            let image = Image(cgImage: cgImage)
            #endif
            return Async(value: image)
        }
        #if os(iOS) || os(macOS)
        if let wkWebView = self as? WKWebView {
            return Async<Image> { callback in
                let work = {
                    inWindow {
                        guard wkWebView.frame.width != 0, wkWebView.frame.height != 0 else {
                            callback(Image())
                            return
                        }
                        wkWebView.takeSnapshot(with: nil) { image, _ in
                            callback(image!) // swiftlint:disable:this force_unwrapping
                        }
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
