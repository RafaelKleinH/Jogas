//
//  ButtonGlass.swift
//  Jogas
//
//  Created by Rafael Hartmann on 11/08/25.
//

import SwiftUI

// MARK: - Basic SwiftUI View Structure

struct BottomButtonStack: View {
    // MARK: - Properties
     
    @State private var expanded = false
    @State private var isShowingPopover = false
    
    @Binding var filterType: FilterTypes
    @Binding var search: String
    @Binding var searching: Bool
    
    @FocusState private var hasFocus: Bool
    
    @Namespace private var namespace
    
    private let iconSize: CGFloat = 20
    private let spacing: CGFloat = 20
    private let buttonFrame: CGFloat = 56
    
    // MARK: - Body
    var body: some View {
        
        GlassEffectContainer(spacing: spacing) {
            HStack(spacing: 0) {
                
                if !searching {
                    Button {
                        withAnimation {
                            expanded.toggle()
                        }
                    } label: {
                        Image(systemName: expanded ? "xmark" : "ellipsis")
                            .contentTransition(.symbolEffect(.replace))
                            .tint(.accentColor)
                            .frame(width: buttonFrame, height: buttonFrame)
                            .font(.system(size: iconSize))
                    }
                    .glassEffect()
                    .glassEffectID("ellipsis", in: namespace)
                    .padding(.trailing, spacing)
                    
                    if expanded {
                        
                        Button {
                            withAnimation {
                                isShowingPopover.toggle()
                            }
                        } label: {
                            Image(systemName: "list.bullet")
                                .contentTransition(.symbolEffect(.replace))
                                .tint(.accentColor)
                                .frame(width: buttonFrame, height: buttonFrame)
                                .font(.system(size: iconSize))
                        }
                        .glassEffect()
                        .glassEffectID("filter", in: namespace)
                        .padding(.trailing, spacing)
                        .popover(isPresented: $isShowingPopover, attachmentAnchor: .point(.top)) {
                            PopoverView(isShowingPopover: $isShowingPopover, filterType: $filterType)
                                .presentationCompactAdaptation(.popover)
                                .padding()
                        }
                    }
                }
                
                if expanded {
                    if searching {
                        
                        TextField("Search", text: $search)
                            .padding()
                            .frame(height: buttonFrame)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .foregroundColor(searching ? .primary : .clear)
                            .focused($hasFocus)
                            .glassEffect()
                            .glassEffectID("gameTFHome", in: namespace)
                    }
                    
                    Button {
                        withAnimation {
                            if hasFocus && searching {
                                hasFocus = false
                            } else {
                                searching.toggle()
                            }
                        }
                    } label: {
                        Image(systemName: searching ? "checkmark" : "magnifyingglass")
                            .tint(.accentColor)
                            .frame(width: buttonFrame, height: buttonFrame)
                            .font(.system(size: iconSize))
                    }
                    .glassEffect()
                    .glassEffectID("magnifyingglass", in: namespace)   
                }
            }
        }
    }
}
