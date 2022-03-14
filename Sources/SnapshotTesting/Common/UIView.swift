#if os(iOS) || os(tvOS)
import UIKit

extension UIView {
    func prepare(
        config: ViewImageConfig,
        drawHierarchyInKeyWindow: Bool,
        traits: UITraitCollection,
        viewController: UIViewController
    ) -> () -> Void {
        let size = config.size ?? viewController.view.frame.size
        frame.size = size
        if self != viewController.view {
            viewController.view.bounds = bounds
            viewController.view.addSubview(self)
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
            sizeToFit()
            setNeedsLayout()
            layoutIfNeeded()
        }

        return dispose
    }

    func snapshot(
        config: ViewImageConfig,
        drawHierarchyInKeyWindow: Bool,
        traits: UITraitCollection,
        viewController: UIViewController
    ) -> Async<UIImage> {
        let initialFrame = frame
        let dispose = prepare(
            config: config,
            drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
            traits: traits,
            viewController: viewController
        )
        // NB: Avoid safe area influence.
        if config.safeArea == .zero { frame.origin = .init(x: offscreen, y: offscreen) }

        return (snapshot ?? Async { [self] callback in
            addImagesForRenderedViews().sequence().run { views in
                callback(
                    renderer(bounds: bounds, for: traits).image { ctx in
                        if drawHierarchyInKeyWindow {
                            drawHierarchy(in: bounds, afterScreenUpdates: true)
                        } else {
                            layer.render(in: ctx.cgContext)
                        }
                    }
                )
                views.forEach { $0.removeFromSuperview() }
                frame = initialFrame
            }
        }).map { dispose(); return $0 }
    }
}

private let offscreen: CGFloat = 10000

func renderer(bounds: CGRect, for traits: UITraitCollection) -> UIGraphicsImageRenderer {
    .init(bounds: bounds, format: .init(for: traits))
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

private extension UIApplication {
    static var sharedIfAvailable: UIApplication? {
        let sharedSelector = NSSelectorFromString("sharedApplication")
        guard UIApplication.responds(to: sharedSelector) else {
            return nil
        }

        let shared = UIApplication.perform(sharedSelector)
        return shared?.takeUnretainedValue() as? UIApplication
    }
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
