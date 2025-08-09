import SwiftUI

extension View {
    func headerButtonStyle() -> some View {
        self.frame(width: 72, height: 32)
            .background(Capsule().fill(.white.opacity(0.2)))
            .clipShape(Capsule())
            .glassEffect()
    }
}
