import SwiftUI

class WritingStateManager: ObservableObject {
    @Published var currentWordCount: Int = 0
    @Published var dailyGoal: Int = 500
    @Published var title: String = ""
    @Published var content: NSAttributedString = NSAttributedString(string: "")
    @Published var showTitle: Bool = false

    func updateWordCount() {
        let words = content.string.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        currentWordCount = words.count
    }

    func clearContent() {
        content = NSAttributedString(string: "")
        title = ""
        updateWordCount()
    }
}