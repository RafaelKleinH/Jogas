//
//  HeaderView.swift
//  HeaderView
//
//  Created by Rafael Hartmann on 17/06/25.
//

import SwiftUI

struct HeaderView: View {
    @State private var isStarFilled: Bool = false

    var body: some View {
        HStack {
            Image(systemName: isStarFilled ? "star.fill" : "star")
                .foregroundColor(.accentColor)
                .onTapGesture {
                    isStarFilled.toggle()
                }
            Spacer()
            Text("Header Title")
                .font(.headline)
            Spacer()
            Button(action: {
                // Action here
            }) {
                Image(systemName: "bell")
                    .foregroundColor(.accentColor)
            }
            .glassEffect()
        }
        .padding()
    }
}

#Preview {
    HeaderView()
}
