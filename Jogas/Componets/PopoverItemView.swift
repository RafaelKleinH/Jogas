//
//  PopoverItem.swift
//  Jogas
//
//  Created by Rafael Hartmann on 12/08/25.
//

import SwiftUI

struct PopoverItemView: View {
    
    @Binding var isShowingPopover: Bool
    @Binding var filterType: FilterTypes
    
    let text: String
    let imageName: String
    let filterId: FilterTypes
    
    var body: some View {
        Button {
            withAnimation {
                isShowingPopover = false
            }
            filterType = filterId
        } label: {
            HStack {
                Image(systemName: imageName)
                
                Text(text)
            }
            .padding()
        }
    }
}
