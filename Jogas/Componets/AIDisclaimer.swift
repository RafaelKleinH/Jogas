//
//  AIDisclaimer.swift
//  Jogas
//
//  Created by Rafael Hartmann on 18/08/25.
//

import SwiftUI

struct AIDisclaimer: View {
    var body: some View {
        HStack(alignment: .center) {
            Text("Generated with AI")
                .font(.caption2)
            
            Image(systemName: "sparkles")
                .resizable()
                .frame(width: 12, height: 12)
            
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}
