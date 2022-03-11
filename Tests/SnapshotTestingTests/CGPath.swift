import XCTest
@testable import SnapshotTesting

#if os(iOS)
let platform = "ios"
#elseif os(tvOS)
let platform = "tvos"
#elseif os(macOS)
let platform = "macos"
extension NSTextField {
    var text: String {
        get { stringValue }
        set { stringValue = newValue }
    }
}
#endif

#if os(macOS) || os(iOS) || os(tvOS)
extension CGPath {
    /// Creates an approximation of a heart at a 45º angle with a circle above, using all available element types:
    static var heart: CGPath {
        let scale: CGFloat = 30
        let path = CGMutablePath()

        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: 2).scaled(by: scale))
        path.addQuadCurve(
            to: CGPoint(x: 1, y: 3).scaled(by: scale),
            control: CGPoint(x: 0.125, y: 2.875).scaled(by: scale)
        )
        path.addQuadCurve(
            to: CGPoint(x: 2, y: 2).scaled(by: scale),
            control: CGPoint(x: 1.875, y: 2.875).scaled(by: scale)
        )
        path.addCurve(
            to: CGPoint(x: 3, y: 1).scaled(by: scale),
            control1: CGPoint(x: 2.5, y: 2).scaled(by: scale),
            control2: CGPoint(x: 3, y: 1.5).scaled(by: scale)
        )
        path.addCurve(
            to: CGPoint(x: 2, y: 0).scaled(by: scale),
            control1: CGPoint(x: 3, y: 0.5).scaled(by: scale),
            control2: CGPoint(x: 2.5, y: 0).scaled(by: scale)
        )
        path.addLine(to: .zero)
        path.closeSubpath()

        path.addEllipse(in: CGRect(
            origin: CGPoint(x: 2, y: 2).scaled(by: scale),
            size: CGSize(width: scale, height: scale)
        ))

        return path
    }
}

private extension CGPoint {
    func scaled(by value: CGFloat) -> CGPoint {
        .init(x: x * value, y: y * value)
    }
}
#endif

#if os(iOS) || os(tvOS)
extension UIBezierPath {
    /// Creates an approximation of a heart at a 45º angle with a circle above, using all available element types:
    static var heart: UIBezierPath {
        UIBezierPath(cgPath: .heart)
    }
}
#elseif os(macOS)
extension NSBezierPath {
    /// Creates an approximation of a heart at a 45º angle with a circle above, using all available element types:
    static var heart: NSBezierPath {
        let scale: CGFloat = 30
        let path = NSBezierPath()

        path.move(to: .zero)
        path.line(to: CGPoint(x: 0, y: 2).scaled(by: scale))
        path.curve(
            to: CGPoint(x: 1, y: 3).scaled(by: scale),
            controlPoint1: CGPoint(x: 0, y: 2.5).scaled(by: scale),
            controlPoint2: CGPoint(x: 0.5, y: 3).scaled(by: scale)
        )
        path.curve(
            to: CGPoint(x: 2, y: 2).scaled(by: scale),
            controlPoint1: CGPoint(x: 1.5, y: 3).scaled(by: scale),
            controlPoint2: CGPoint(x: 2, y: 2.5).scaled(by: scale)
        )
        path.curve(
            to: CGPoint(x: 3, y: 1).scaled(by: scale),
            controlPoint1: CGPoint(x: 2.5, y: 2).scaled(by: scale),
            controlPoint2: CGPoint(x: 3, y: 1.5).scaled(by: scale)
        )
        path.curve(
            to: CGPoint(x: 2, y: 0).scaled(by: scale),
            controlPoint1: CGPoint(x: 3, y: 0.5).scaled(by: scale),
            controlPoint2: CGPoint(x: 2.5, y: 0).scaled(by: scale)
        )
        path.line(to: CGPoint(x: 0, y: 0).scaled(by: scale))
        path.close()

        path.appendOval(in: CGRect(
            origin: CGPoint(x: 2, y: 2).scaled(by: scale),
            size: CGSize(width: scale, height: scale)
        ))

        let origin = path.bounds.origin
        let transform = AffineTransform(translationByX: -origin.x, byY: -origin.y)
        path.transform(using: transform)

        return path
    }
}
#endif
