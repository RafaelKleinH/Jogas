//
//  RatingView.swift
//  Jogas
//
//  Created by Rafael Hartmann on 21/08/25.
//

import SwiftUI

enum SliderType {
    case firstNumber
    case lastNumber
}

struct RatingView: View {
    
    @Binding var firstSliderValue: Int
    @Binding var lastSliderValue: Int
    @Binding var firstDragValue: Int
    @Binding var lastDragValue: Int
    @Binding var isPresenting: Bool
    
    let action: () -> Void
    
    var body: some View {
        getContentView()
    }
    
    @ViewBuilder
    private func getContentView() -> some View {
        
        VStack(alignment: .leading) {
            
            Text("Rate Game")
                .font(.title)
                .bold()
                .padding(.bottom)
            
            mainText()
            
            Button {
                action()
                isPresenting = false
            } label: {
                HStack(alignment: .center) {
                    Spacer()
                    Text("Confirm")
                    Spacer()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(.ultraThinMaterial))
            }
            .padding(.top)
        }
        .padding()
        
    }
    
    private func mainText() -> some View {
        HStack(spacing: 0) {
            
            setupFirstSliderGesture()
            
            Text(".")
            
            setupSecondSliderGesture()
            
        }
        .font(.system(size: 124, weight: .bold, design: .rounded))
    }
    
    private func setupFirstSliderGesture() -> some View {
        HStack {
            Spacer()
            Text(firstSliderValue.formatted())
                .contentTransition(.numericText(value: Double(firstSliderValue)))
                .padding(.horizontal)
            Spacer()
         
        }
        .background(RoundedRectangle(cornerRadius: 8).fill(.ultraThinMaterial))
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        let dragDistance = -value.translation.height
                        let sensitivity: CGFloat = 30 // Adjust this to control sensitivity
                        let increment = Int(dragDistance / sensitivity)
                        let newValue = max(0, min(10, firstDragValue + increment))
                        
                        if newValue != firstSliderValue {
                            withAnimation(.linear) {
                                firstSliderValue = newValue
                            }
                            // Trigger haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    })
                    .onEnded({ _ in
                        firstDragValue = firstSliderValue
                        
                        if firstDragValue == 10 {
                            lastSliderValue = 0
                            lastDragValue = 0
                        }
                    })
            )
    }
    
    private func setupSecondSliderGesture() -> some View {
        HStack {
            Spacer()
            Text(lastSliderValue.formatted())
                .contentTransition(.numericText(value: Double(lastSliderValue)))
                .padding(.horizontal)
            Spacer()
           
        }
        .background(RoundedRectangle(cornerRadius: 8).fill(.ultraThinMaterial))
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        guard firstSliderValue < 10 else { return }
                        
                        let dragDistance = -value.translation.height
                        let sensitivity: CGFloat = 30 // Adjust this to control sensitivity
                        let increment = Int(dragDistance / sensitivity)
                        let newValue = max(0, min(9, lastDragValue + increment))
                        
                        if newValue != lastSliderValue {
                            withAnimation(.linear) {
                                lastSliderValue = newValue
                            }
                            // Trigger haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    })
                    .onEnded({ _ in
                        lastDragValue = lastSliderValue
                        
                    })
            )
    }
}


#Preview {
    @Previewable @State var firstSliderValue: Int = 0
    @Previewable @State var lastSliderValue: Int = 0
    @Previewable @State var firstDragValue: Int = 0
    @Previewable @State var lastDragValue: Int = 0
    @Previewable @State var isPresenting: Bool = true
    RatingView(
        firstSliderValue: $firstSliderValue,
        lastSliderValue: $lastSliderValue,
        firstDragValue: $firstDragValue,
        lastDragValue: $lastDragValue,
        isPresenting: $isPresenting,
        action: {}
    )
}
