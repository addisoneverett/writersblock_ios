import SwiftUI

struct TabBarView<Content: View>: View {
    @Binding var selectedTab: Int
    let content: Content
    
    init(selectedTab: Binding<Int>, @ViewBuilder content: () -> Content) {
        self._selectedTab = selectedTab
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ZStack {
                    content
                }
                .frame(height: geometry.size.height - 70) // Adjusted for larger tab bar height
                
                HStack {
                    ForEach(0..<4) { index in
                        Spacer()
                        TabBarButton(imageName: tabBarImageName(for: index), isSelected: selectedTab == index) {
                            selectedTab = index
                        }
                        Spacer()
                    }
                }
                .frame(height: 70) // Increased height
                .background(Color(.systemBackground))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.secondary.opacity(0.2)),
                    alignment: .top
                )
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private func tabBarImageName(for index: Int) -> String {
        switch index {
        case 0: return "square.and.pencil" // Changed from "pencil" to "square.and.pencil"
        case 1: return "book"
        case 2: return "chart.bar"
        case 3: return "gearshape"
        default: return ""
        }
    }
}

struct TabBarButton: View {
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .font(.typewriter(size: 32)) // Increased from 28 to 32
                .foregroundColor(isSelected ? .black : .gray)
                .frame(width: 80, height: 80) // Increased from 70x70 to 80x80
        }
    }
}