//
//  LastPlayedView.swift
//  Jogas
//
//  Created by Rafael Hartmann on 09/08/25.
//

import SwiftUI
import SwiftData

struct LastPlayedView: View {
    
    let games: [SteamGamesResumed]
    @State private var highlightedIndex: Int = 0
    
    private let peekAmount: CGFloat = 40 // How much of the adjacent games show
    private let spacing: CGFloat = 16
    
    var body: some View {
        GeometryReader { geometry in
            let gameCount = min(games.count, 10)
            let highlightedWidth = geometry.size.width - (peekAmount * 2)
            let nonHighlightedWidth = highlightedWidth * 0.8
            
            // Calculate offset to center the highlighted card
            let centerOffset = calculateCenterOffset(
                highlightedIndex: highlightedIndex,
                gameCount: gameCount,
                containerWidth: geometry.size.width,
                highlightedWidth: highlightedWidth,
                nonHighlightedWidth: nonHighlightedWidth
            )
            
            HStack(spacing: spacing) {
                ForEach(Array(games.prefix(10).enumerated()), id: \.offset) { index, game in
                    GameView(game: game)
                        .frame(width: index == highlightedIndex ? highlightedWidth : nonHighlightedWidth)
                        .scaleEffect(index == highlightedIndex ? 1.0 : 0.9)
                        .opacity(index == highlightedIndex ? 1.0 : 0.6)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: highlightedIndex)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                highlightedIndex = index
                            }
                        }
                }
            }
            .offset(x: centerOffset)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: highlightedIndex)
            .animation(.easeInOut(duration: 0.3), value: games.count) // Animate when games count changes
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width > 50 && highlightedIndex > 0 {
                            // Swiped right - go to previous
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                highlightedIndex -= 1
                            }
                        } else if value.translation.width < -50 && highlightedIndex < gameCount - 1 {
                            // Swiped left - go to next
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                highlightedIndex += 1
                            }
                        }
                    }
            )
        }
        .scaledToFit()
        .onChange(of: games) { _, newGames in
            // Reset to first game when data changes, and ensure index is valid
            let maxIndex = min(newGames.count - 1, 9)
            highlightedIndex = max(0, min(highlightedIndex, maxIndex))
        }
    }
    
    private func calculateCenterOffset(highlightedIndex: Int, gameCount: Int, containerWidth: CGFloat, highlightedWidth: CGFloat, nonHighlightedWidth: CGFloat) -> CGFloat {
        let centerX = containerWidth / 2
        
        // Calculate the position of the highlighted card
        var cardCenterX: CGFloat = 0
        
        for i in 0..<highlightedIndex {
            let cardWidth = i == highlightedIndex ? highlightedWidth : nonHighlightedWidth
            cardCenterX += cardWidth + spacing
        }
        
        // Add half of the highlighted card width
        cardCenterX += highlightedWidth / 2
        
        // Calculate offset to center the highlighted card
        return centerX - cardCenterX
    }
}

