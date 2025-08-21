//
//  AppleInteligenceEffect.swift
//  Jogas
//
//  Created by Rafael Hartmann on 17/08/25.
//

import SwiftUI

// MARK: - Apple Intelligence Text Field Effect
struct AppleIntelligenceEffect: ViewModifier {
    @Binding var isActive: Bool
    let cornerRadius: CGFloat
    
    let colors: [Color] = [Color(hex: "BC82F3"),Color(hex: "F5B9EA"), Color(hex: "8D9FFF"), Color(hex: "8D9FFF"), Color(hex: "AA6EEE"), Color(hex: "FF6778"), Color(hex: "FFBA71"), Color(hex: "C686FF")]
    
    init(isActive: Binding<Bool>, cornerRadius: CGFloat = 8) {
        self._isActive = isActive
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        
        ZStack {
            content
            

            if isActive {
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(lineWidth: 4)
                    .phaseAnimator([0, 1, 2, 3]) { view, step in
                        view
                            .foregroundStyle(LinearGradient(colors: colors, startPoint:  animateStartPoint(value: step), endPoint:  animateEndPoint(value: step)))
                    } animation: { step in
                        switch step {
                        case 0:
                            return .linear(duration: 0.5)
                        case 1:
                            return .linear(duration: 4)
                        case 2:
                            return .linear(duration: 0.5)
                        default:
                            return .linear(duration: 4)
                        }
                    }
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(lineWidth: 8)
                    .phaseAnimator([0, 1, 2, 3]) { view, step in
                        view
                            .foregroundStyle(LinearGradient(colors: colors, startPoint:  animateStartPoint(value: step), endPoint:  animateEndPoint(value: step)))
                            .blur(radius: 4)
                            .scaleEffect(step % 2 == 0 ? 0.975 : 1)
                        
                    } animation: { step in
                        switch step {
                        case 0:
                            return .linear(duration: 0.5)
                        case 1:
                            return .linear(duration: 4)
                        case 2:
                            return .linear(duration: 0.5)
                        default:
                            return .linear(duration: 4)
                        }
                    }
                
            }
        
            
        }
    }
    
    private func animateStartPoint(value: Int) -> UnitPoint {
        switch value {
        case 0:
            return .topLeading
        case 1:
            return .topTrailing
        case 2:
            return .bottomTrailing
        default:
            return .bottomLeading
        }
    }
    
    private func animateEndPoint(value: Int) -> UnitPoint {
        switch value {
        case 0:
            return .bottomTrailing
        case 1:
            return .bottomLeading
        case 2:
            return .topLeading
        default:
            return .topTrailing
        }
    }
}

// MARK: - View Extension
extension View {
    func appleIntelligenceEffect(isActive: Binding<Bool>, cornerRadius: CGFloat = 8) -> some View {
        self.modifier(AppleIntelligenceEffect(isActive: isActive, cornerRadius: cornerRadius))
    }
}

#Preview {
    GameInfoView(viewModel: GameInfoViewModel(gameId: "1941540"))
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
