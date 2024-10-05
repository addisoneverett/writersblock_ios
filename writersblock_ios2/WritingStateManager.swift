import SwiftUI

class WritingStateManager: ObservableObject {
    @Published var currentWordCount: Int = 0
    @Published var dailyGoal: Int = UserDefaults.standard.integer(forKey: "dailyGoal") {
        didSet {
            UserDefaults.standard.set(dailyGoal, forKey: "dailyGoal")
        }
    }
    @Published var title: String = ""
    @Published var content: NSAttributedString = NSAttributedString(string: "")
    @Published var showTitle: Bool = false
    @Published var goalHistory: [Date: Bool] = [:]

    init() {
        loadGoalHistory()
        if dailyGoal == 0 {
            dailyGoal = 500 // Set default goal if not set
        }
    }

    func updateWordCount() {
        let words = content.string.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        currentWordCount = words.count
    }

    func clearContent() {
        content = NSAttributedString(string: "")
        title = ""
        updateWordCount()
    }

    func updateGoalHistory(date: Date, achieved: Bool) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        goalHistory[startOfDay] = achieved
        saveGoalHistory()
    }

    private func loadGoalHistory() {
        if let savedHistory = UserDefaults.standard.dictionary(forKey: "goalHistory") as? [String: Bool] {
            let dateFormatter = ISO8601DateFormatter()
            goalHistory = savedHistory.reduce(into: [:]) { result, entry in
                if let date = dateFormatter.date(from: entry.key) {
                    result[date] = entry.value
                }
            }
        }
    }

    private func saveGoalHistory() {
        let dateFormatter = ISO8601DateFormatter()
        let historyToSave = goalHistory.reduce(into: [:]) { result, entry in
            result[dateFormatter.string(from: entry.key)] = entry.value
        }
        UserDefaults.standard.set(historyToSave, forKey: "goalHistory")
    }
}