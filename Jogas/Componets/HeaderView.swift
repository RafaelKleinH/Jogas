//
//  HeaderView.swift
//  HeaderView
//
//  Created by Rafael Hartmann on 17/06/25.
//

import SwiftUI
import SwiftData

struct HeaderView: View {
    @ObservedObject var viewModel: GamesListViewModel
    
    // UserDefaults property to control animated background
    @AppStorage("useAnimatedBackground") private var useAnimatedBackground: Bool = true

    var body: some View {
        HStack {
            // TODO: - Crash
            
            Spacer()
            
            // Animated Background Toggle Button
            Button(action: {
                useAnimatedBackground.toggle()
            }) {
                Image(systemName: useAnimatedBackground ? "sparkles" : "sparkles.rectangle.stack.fill")
                    .foregroundColor(.accentColor)
            }
            .headerButtonStyle()
            
            Button(action: {
                
            }) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.accentColor)
            }
            .headerButtonStyle()
            
 
        }
        .padding()
    }
}

#Preview {
    HeaderView(viewModel: GamesListViewModel())
}
