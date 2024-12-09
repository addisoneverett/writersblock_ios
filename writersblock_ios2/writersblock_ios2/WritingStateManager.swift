import SwiftUI

class WritingStateManager: ObservableObject {
    @Published var content: NSAttributedString = NSAttributedString(string: "")
    @Published var title: String = ""
    @Published var showTitle: Bool = false
    @Published var wordCount: Int = 0
    
    func updateWordCount() {
        let words = content.string.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ")
        wordCount = words.isEmpty ? 0 : words.count
    }
    
    func clearContent() {
        content = NSAttributedString(string: "")
        title = ""
        showTitle = false
        wordCount = 0
    }
}