#if os(iOS)
import UIKit

public extension ViewImageConfig {
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

    static let iPhoneXr = ViewImageConfig.iPhoneXr(.portrait)

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
}
#endif
