#if os(iOS) || os(tvOS)
import UIKit

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
