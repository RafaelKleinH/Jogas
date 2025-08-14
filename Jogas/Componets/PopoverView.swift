//
//  PopoverView.swift
//  Jogas
//
//  Created by Rafael Hartmann on 13/08/25.
//

import SwiftUI

struct PopoverView: View {
    
    @Binding var isShowingPopover: Bool
    @Binding var filterType: FilterTypes
    
    var body: some View {
        
        VStack {
            PopoverItemView(isShowingPopover: $isShowingPopover, filterType: $filterType, text: FilterTypes.alphabetical.getName(), imageName: FilterTypes.alphabetical.getImage(), filterId: FilterTypes.alphabetical)
            PopoverItemView(isShowingPopover: $isShowingPopover, filterType: $filterType, text: FilterTypes.most_played.getName(), imageName: FilterTypes.most_played.getImage(), filterId: FilterTypes.most_played)
            PopoverItemView(isShowingPopover: $isShowingPopover, filterType: $filterType, text: FilterTypes.least_played.getName(), imageName: FilterTypes.least_played.getImage(), filterId: FilterTypes.least_played)
            PopoverItemView(isShowingPopover: $isShowingPopover, filterType: $filterType, text: FilterTypes.recent_played.getName(), imageName: FilterTypes.recent_played.getImage(), filterId: FilterTypes.recent_played)
        }
    }
}
