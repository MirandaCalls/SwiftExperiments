import SwiftUI
import PlaygroundSupport

struct ContentView: View {
    @State private var percentage: Double = 0
    
    var body: some View {
        VStack {
            PercentageSlider(percentage: self.$percentage)
                .padding()
            Text("\(self.percentage * 100, specifier: "%.2f") %")
        }
        .frame(width: 300, height: 300)
    }
}

struct PercentageSlider: View {
    @Binding var percentage: Double
    
    @State private var draggerScale: CGFloat = 1
    @State private var draggerPosition = CGSize.zero
    @State private var draggerOffset = CGSize.zero
    @State private var progressLength: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geo.size.width, height: 5)
                    .background(.white.opacity(0.5))
                
                Rectangle()
                    .fill(.blue)
                    .frame(width: self.progressLength, height: 5)
                
                Circle()
                    .frame(width: 15, height: 15)
                    .scaleEffect(self.draggerScale)
                    .onHover { hovering in
                        withAnimation(.easeIn(duration: 0.1)) {
                            if hovering {
                                self.draggerScale = 1.4
                            } else {
                                self.draggerScale = 1
                            }
                        }
                    }
                    .offset(x: self.draggerPosition.width + self.draggerOffset.width, y: 0)
                    .gesture (
                        DragGesture()
                            .onChanged {
                                withAnimation(.easeIn(duration: 0.1)) {
                                    self.draggerScale = 1.4
                                }
                                
                                self.draggerOffset.width = self.handleOffsetBounds(
                                    newOffset: $0.translation.width,
                                    totalWidth: geo.size.width
                                )
                                
                                self.progressLength = self.draggerPosition.width + self.draggerOffset.width
                                self.percentage = (self.draggerOffset.width + self.draggerPosition.width) / (geo.size.width - 15)
                            }
                            .onEnded {
                                self.draggerPosition.width += self.handleOffsetBounds(
                                    newOffset: $0.translation.width,
                                    totalWidth: geo.size.width
                                )
                                self.draggerOffset = CGSize.zero
                                self.progressLength = self.draggerPosition.width
                                withAnimation {
                                    self.draggerScale = 1
                                }
                            }
                    )
            }
        }
        .frame(height: 15)
    }
    
    // For ensuring that the dragger never goes off the screen
    func handleOffsetBounds(newOffset: CGFloat, totalWidth: CGFloat) -> CGFloat {
        var final_offset = newOffset
        if self.draggerPosition.width + newOffset < 0 {
            final_offset += abs(newOffset) - self.draggerPosition.width
        }
        
        let final_offset_and_dragger = self.draggerPosition.width + newOffset + 15
        if final_offset_and_dragger > totalWidth {
            final_offset -= final_offset_and_dragger - totalWidth
        }
        
        return final_offset
    }
}

PlaygroundPage.current.setLiveView(ContentView())
