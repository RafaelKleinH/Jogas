//
//  MainBackground.swift
//  Jogas
//
//  Created by Rafael Hartmann on 10/08/25.
//

import SwiftUI

struct MainBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("useAnimatedBackground") private var useAnimatedBackground: Bool = false
    
    let warmGradientColors = [
        Color(red: 0.73, green: 0.55, blue: 0.62), // Top dusty rose
        Color(red: 0.42, green: 0.20, blue: 0.42)  // Bottom deep purple
    ]
    
    let lightGradientColors = [
        Color(red: 0.85, green: 0.90, blue: 0.95), // Very light sky blue
        Color(red: 0.55, green: 0.65, blue: 0.80)  // Deeper blue
    ]
    
    private var gradientColors: [Color] {
        colorScheme == .dark ? warmGradientColors : lightGradientColors
    }
    
    var body: some View {
        //if useAnimatedBackground {
        //    AnimatedBackgroundView()
        //        .ignoresSafeArea()
        //} else {
            // Simple gradient background as fallback
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
       // }
    }
}
