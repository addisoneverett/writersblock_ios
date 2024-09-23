import SwiftUI

struct TabBarView<Content: View>: View {
    @Binding var selectedTab: Int
    let content: Content
    @State private var keyboardHeight: CGFloat = 0
    
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
                .frame(height: geometry.size.height - 70 - keyboardHeight) // Adjust for keyboard
                
                HStack {
                    ForEach(0..<4) { index in
                        Spacer()
                        TabBarButton(imageName: tabBarImageName(for: index), isSelected: selectedTab == index) {
                            selectedTab = index
                        }
                        Spacer()
                    }
                }
                .frame(height: 70)
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
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardRectangle = keyboardFrame.cgRectValue
                    keyboardHeight = keyboardRectangle.height
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardHeight = 0
            }
        }
    }
    
    private func tabBarImageName(for index: Int) -> String {
        switch index {
        case 0: return "square.and.pencil"
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
                .font(.typewriter(size: 32))
                .foregroundColor(isSelected ? .black : .gray)
                .frame(width: 80, height: 80)
        }
    }
}