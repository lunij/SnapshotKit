#if os(watchOS)
import SwiftUI
import WatchKit
#endif

#if os(watchOS)
extension View {
    func snapshot(
        config: ViewImageConfig,
        drawHierarchyInKeyWindow: Bool,
        interfaceController: WKInterfaceController
    ) -> Async<UIImage> {
        Async { callback in
            // TODO: implement
            callback(UIImage())
        }
    }
}
#endif
