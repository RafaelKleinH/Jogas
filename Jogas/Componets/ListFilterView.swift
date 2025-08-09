//
//  ListFilterView.swift
//  HeaderView
//
//  Created by Swift AI Assistant on 17/06/25.
//

import SwiftUI

struct ListFilterView: View {
    var placeholder: String = "Filter..."
    var onFilter: (() -> Void)? = nil
    var onReverse: (() -> Void)? = nil
    
    @State var revertClicked: Bool = false
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                onFilter?()
            } label: {
                Image(systemName: "list.bullet")
                    .foregroundColor(.accentColor)
               
            }
            .headerButtonStyle()
            
            Button {
                revertClicked.toggle()
                onReverse?()
            } label: {
                Image(systemName: revertClicked ? "arrow.up" : "arrow.down")
                    .foregroundColor(.accentColor)
            }
            .headerButtonStyle()
            
        }
        .padding(.horizontal)
    }
}

#Preview {
    return ListFilterView()
}
