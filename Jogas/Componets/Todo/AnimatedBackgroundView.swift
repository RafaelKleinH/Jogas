//
//  AnimatedBackgroundView.swift
//  Jogas
//
//  Created by Rafael Hartmann on 10/08/25.
//

import SwiftUI

struct AnimatedBackgroundView: View {
    @State private var animationProgress: Double = 0
    @State private var secondaryAnimation: Double = 0
    @State private var tertiaryAnimation: Double = 0
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("useAnimatedBackground") private var useAnimatedBackground: Bool = true
    
    // New parameter to control animation
    let isAnimated: Bool?
    
    // Computed property to determine if animation should be active
    private var shouldAnimate: Bool {
        isAnimated ?? useAnimatedBackground
    }
    
    // Initializer
    init(isAnimated: Bool? = nil) {
        self.isAnimated = isAnimated
    }
    
    // Accurate colors matching the image - dusty rose to deep purple
    let warmGradientColors = [
        Color(red: 0.73, green: 0.55, blue: 0.62), // Top dusty rose
        Color(red: 0.70, green: 0.48, blue: 0.58), // Mid-light rose
        Color(red: 0.65, green: 0.40, blue: 0.55), // Mid rose-purple
        Color(red: 0.58, green: 0.32, blue: 0.52), // Deeper purple-rose
        Color(red: 0.50, green: 0.25, blue: 0.48), // Dark purple
        Color(red: 0.42, green: 0.20, blue: 0.42)  // Bottom deep purple
    ]
    
    // Light mode version - soft blue variants
    let lightGradientColors = [
        Color(red: 0.85, green: 0.90, blue: 0.95), // Very light sky blue
        Color(red: 0.80, green: 0.85, blue: 0.92), // Light powder blue
        Color(red: 0.75, green: 0.80, blue: 0.90), // Soft blue
        Color(red: 0.68, green: 0.75, blue: 0.85), // Light steel blue
        Color(red: 0.60, green: 0.70, blue: 0.82), // Medium blue
        Color(red: 0.55, green: 0.65, blue: 0.80)  // Deeper blue
    ]
    
    private var gradientColors: [Color] {
        colorScheme == .dark ? warmGradientColors : lightGradientColors
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                baseGradientLayer
                primarySCurvesLayer(geometry: geometry)
                secondarySCurvesLayer(geometry: geometry)
                flowingShapesLayer(geometry: geometry)
                organicSpotsLayer(geometry: geometry)
                smoothingOverlayLayer
            }
        }
        .onAppear {
            if shouldAnimate {
                startAnimations()
            }
        }
        .onChange(of: useAnimatedBackground) { _, newValue in
            // Only respond to AppStorage changes if isAnimated is not explicitly set
            if isAnimated == nil {
                if newValue {
                    startAnimations()
                } else {
                    stopAnimations()
                }
            }
        }
    }
    
    // MARK: - Layer Components
    
    private var baseGradientLayer: some View {
        LinearGradient(
            colors: [gradientColors[0], gradientColors[5]],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func primarySCurvesLayer(geometry: GeometryProxy) -> some View {
        ForEach(0..<4, id: \.self) { index in
            primarySCurveShape(index: index, geometry: geometry)
        }
    }
    
    private func primarySCurveShape(index: Int, geometry: GeometryProxy) -> some View {
        let colors = [
            gradientColors[index % gradientColors.count],
            gradientColors[(index + 2) % gradientColors.count],
            gradientColors[(index + 3) % gradientColors.count]
        ]
        
        return Path { path in
            createSCurvePath(path: &path, index: index, geometry: geometry)
        }
        .stroke(
            createDynamicGradient(colors: colors, index: index),
            style: StrokeStyle(
                lineWidth: 100 + CGFloat(index) * 15 + sin(tertiaryAnimation * 0.4 + Double(index)) * 30,
                lineCap: .round
            )
        )
        .rotationEffect(.degrees(Double(index) * 12 + animationProgress * 15 + sin(secondaryAnimation * 0.2 + Double(index)) * 20))
        .offset(
            x: sin(animationProgress * 0.25 + Double(index)) * 80 + cos(tertiaryAnimation * 0.3 + Double(index)) * 40,
            y: cos(secondaryAnimation * 0.2 + Double(index)) * 100 + sin(animationProgress * 0.35 + Double(index)) * 60
        )
        .blur(radius: 35 + CGFloat(index) * 12 + sin(tertiaryAnimation * 0.5 + Double(index)) * 15)
        .opacity(0.8 + sin(animationProgress * 0.3 + Double(index)) * 0.15)
        .blendMode(.multiply)
        .scaleEffect(0.9 + sin(secondaryAnimation * 0.4 + Double(index)) * 0.2)
    }
    
    private func secondarySCurvesLayer(geometry: GeometryProxy) -> some View {
        ForEach(0..<3, id: \.self) { index in
            secondarySCurveShape(index: index, geometry: geometry)
        }
    }
    
    private func secondarySCurveShape(index: Int, geometry: GeometryProxy) -> some View {
        Path { path in
            createReverseSCurvePath(path: &path, index: index, geometry: geometry)
        }
        .stroke(
            LinearGradient(
                colors: [
                    gradientColors[(index + 1) % gradientColors.count].opacity(0.5),
                    gradientColors[(index + 3) % gradientColors.count].opacity(0.6)
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            ),
            style: StrokeStyle(lineWidth: 80 + CGFloat(index) * 15, lineCap: .round)
        )
        .rotationEffect(.degrees(Double(index) * -20 + secondaryAnimation * 8))
        .offset(
            x: cos(secondaryAnimation * 0.25 + Double(index)) * 60,
            y: sin(tertiaryAnimation * 0.18 + Double(index)) * 100
        )
        .blur(radius: 50)
        .opacity(0.8)
        .blendMode(.overlay)
    }
    
    private func flowingShapesLayer(geometry: GeometryProxy) -> some View {
        ForEach(0..<6, id: \.self) { index in
            RoundedRectangle(cornerRadius: 50)
                .fill(createAngularGradient(index: index))
                .frame(width: 300, height: 500)
                .rotationEffect(.degrees(secondaryAnimation * 45 + Double(index) * 60))
                .position(
                    x: geometry.size.width * (0.2 + Double(index) * 0.13) + 
                       cos(animationProgress * 0.4 + Double(index)) * 120,
                    y: geometry.size.height * (0.3 + Double(index) * 0.1) + 
                       sin(tertiaryAnimation * 0.35 + Double(index)) * 180
                )
                .blur(radius: 80)
                .opacity(0.7)
                .blendMode(.overlay)
        }
    }
    
    private func organicSpotsLayer(geometry: GeometryProxy) -> some View {
        ForEach(0..<12, id: \.self) { index in
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            gradientColors[index % gradientColors.count].opacity(0.8),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 40
                    )
                )
                .frame(width: CGFloat.random(in: 80...180))
                .position(
                    x: geometry.size.width * (0.05 + Double(index) * 0.08) + 
                       sin(tertiaryAnimation * 0.6 + Double(index)) * 80,
                    y: geometry.size.height * (0.15 + Double(index) * 0.07) + 
                       cos(animationProgress * 0.5 + Double(index)) * 120
                )
                .blur(radius: 30)
                .opacity(0.5)
                .blendMode(.softLight)
        }
    }
    
    private var smoothingOverlayLayer: some View {
        LinearGradient(
            colors: [
                gradientColors[1].opacity(0.1),
                Color.clear,
                gradientColors[4].opacity(0.15)
            ],
            startPoint: UnitPoint(
                x: 0.2 + cos(animationProgress * 0.1) * 0.3,
                y: 0.1 + sin(secondaryAnimation * 0.08) * 0.4
            ),
            endPoint: UnitPoint(
                x: 0.8 + cos(secondaryAnimation * 0.12) * 0.2,
                y: 0.9 + sin(animationProgress * 0.15) * 0.3
            )
        )
        .blur(radius: 100)
        .blendMode(.softLight)
    }
    
    // MARK: - Helper Methods
    
    private func createSCurvePath(path: inout Path, index: Int, geometry: GeometryProxy) {
        let width = geometry.size.width * (0.5 + sin(animationProgress * 0.3 + Double(index)) * 0.2)
        let height = geometry.size.height * (0.7 + cos(secondaryAnimation * 0.25 + Double(index)) * 0.2)
        let startX = geometry.size.width * (0.15 + sin(tertiaryAnimation * 0.2 + Double(index)) * 0.1)
        let startY = geometry.size.height * (0.05 + cos(animationProgress * 0.18 + Double(index)) * 0.1)
        
        let curve1Intensity = 0.6 + sin(animationProgress * 0.4 + Double(index)) * 0.3
        let curve2Intensity = 0.3 + cos(secondaryAnimation * 0.35 + Double(index)) * 0.2
        let curve3Intensity = 0.7 + sin(tertiaryAnimation * 0.3 + Double(index)) * 0.2
        
        path.move(to: CGPoint(x: startX, y: startY))
        
        // First curve
        path.addCurve(
            to: CGPoint(x: startX + width * curve1Intensity, y: startY + height * 0.3),
            control1: CGPoint(
                x: startX + width * (curve1Intensity + sin(animationProgress * 0.5 + Double(index)) * 0.2),
                y: startY + sin(secondaryAnimation * 0.4 + Double(index)) * 50
            ),
            control2: CGPoint(
                x: startX + width * curve1Intensity,
                y: startY + height * (0.15 + cos(tertiaryAnimation * 0.3 + Double(index)) * 0.1)
            )
        )
        
        // Middle curve
        let middlePoint = CGPoint(
            x: startX + width * (curve2Intensity + sin(secondaryAnimation * 0.6 + Double(index)) * 0.3),
            y: startY + height * (0.7 + cos(animationProgress * 0.4 + Double(index)) * 0.1)
        )
        path.addCurve(
            to: middlePoint,
            control1: CGPoint(
                x: startX + width * curve1Intensity + cos(tertiaryAnimation * 0.5 + Double(index)) * 80,
                y: startY + height * (0.45 + sin(animationProgress * 0.35 + Double(index)) * 0.1)
            ),
            control2: CGPoint(
                x: middlePoint.x + sin(secondaryAnimation * 0.45 + Double(index)) * 60,
                y: startY + height * (0.55 + cos(tertiaryAnimation * 0.4 + Double(index)) * 0.1)
            )
        )
        
        // Bottom curve
        path.addCurve(
            to: CGPoint(
                x: startX + width * (1.0 + sin(tertiaryAnimation * 0.3 + Double(index)) * 0.1),
                y: startY + height * (1.0 + cos(animationProgress * 0.2 + Double(index)) * 0.05)
            ),
            control1: CGPoint(
                x: middlePoint.x + cos(animationProgress * 0.6 + Double(index)) * 70,
                y: startY + height * (0.85 + sin(secondaryAnimation * 0.3 + Double(index)) * 0.1)
            ),
            control2: CGPoint(
                x: startX + width * (curve3Intensity + cos(tertiaryAnimation * 0.4 + Double(index)) * 0.2),
                y: startY + height * (1.0 + sin(animationProgress * 0.25 + Double(index)) * 0.05)
            )
        )
    }
    
    private func createReverseSCurvePath(path: inout Path, index: Int, geometry: GeometryProxy) {
        let width = geometry.size.width * 0.4
        let height = geometry.size.height * 0.6
        let startX = geometry.size.width * (0.4 + Double(index) * 0.15)
        let startY = geometry.size.height * 0.2
        
        path.move(to: CGPoint(x: startX + width, y: startY))
        
        path.addCurve(
            to: CGPoint(x: startX + width * 0.3, y: startY + height * 0.3),
            control1: CGPoint(x: startX + width * 0.4, y: startY),
            control2: CGPoint(x: startX + width * 0.3, y: startY + height * 0.15)
        )
        
        path.addCurve(
            to: CGPoint(x: startX + width * 0.7, y: startY + height * 0.7),
            control1: CGPoint(x: startX + width * 0.3, y: startY + height * 0.45),
            control2: CGPoint(x: startX + width * 0.7, y: startY + height * 0.55)
        )
        
        path.addCurve(
            to: CGPoint(x: startX, y: startY + height),
            control1: CGPoint(x: startX + width * 0.7, y: startY + height * 0.85),
            control2: CGPoint(x: startX + width * 0.6, y: startY + height)
        )
    }
    
    private func createDynamicGradient(colors: [Color], index: Int) -> LinearGradient {
        LinearGradient(
            colors: colors.map { $0.opacity(0.6 + sin(animationProgress * 0.5 + Double(index)) * 0.2) },
            startPoint: UnitPoint(
                x: 0.0 + cos(secondaryAnimation * 0.3 + Double(index)) * 0.3,
                y: 0.0 + sin(tertiaryAnimation * 0.25 + Double(index)) * 0.3
            ),
            endPoint: UnitPoint(
                x: 1.0 + cos(animationProgress * 0.4 + Double(index)) * 0.2,
                y: 1.0 + sin(secondaryAnimation * 0.35 + Double(index)) * 0.2
            )
        )
    }
    
    private func createAngularGradient(index: Int) -> AngularGradient {
        AngularGradient(
            colors: [
                gradientColors[(index * 2) % gradientColors.count].opacity(0.4),
                gradientColors[(index * 2 + 1) % gradientColors.count].opacity(0.5),
                gradientColors[(index * 2 + 3) % gradientColors.count].opacity(0.3)
            ],
            center: .center,
            startAngle: .degrees(Double(index) * 60),
            endAngle: .degrees(360 + Double(index) * 60)
        )
    }
    
    private func startAnimations() {
        withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
            animationProgress = 1
        }
        withAnimation(.linear(duration: 40).repeatForever(autoreverses: true)) {
            secondaryAnimation = 1
        }
        withAnimation(.linear(duration: 50).repeatForever(autoreverses: false)) {
            tertiaryAnimation = 1
        }
    }
    
    private func stopAnimations() {
        // Stop all ongoing animations by removing them and keeping current values
        withAnimation(.linear(duration: 0)) {
            animationProgress = animationProgress
            secondaryAnimation = secondaryAnimation
            tertiaryAnimation = tertiaryAnimation
        }
    }
}

#Preview("Animated Background") {
    AnimatedBackgroundView(isAnimated: true)
}

#Preview("Static Background") {
    AnimatedBackgroundView(isAnimated: false)
}

