import SwiftUI

struct Rank {
    let name: String
    let minWords: Int
}

let ranks: [Rank] = [
    Rank(name: "Word Dabbler", minWords: 0),
    Rank(name: "Novice Scribe", minWords: 500),
    Rank(name: "Adept Penman", minWords: 1000),
    Rank(name: "Inkling", minWords: 1500),
    Rank(name: "Quill Rookie", minWords: 2000),
    Rank(name: "Page Apprentice", minWords: 2500),
    Rank(name: "Wordsmith in Training", minWords: 3000),
    Rank(name: "Prose Pupil", minWords: 3500),
    Rank(name: "Paragraph Novice", minWords: 4000),
    Rank(name: "Script Explorer", minWords: 4500),
    Rank(name: "Sentence Seeker", minWords: 5000),
    Rank(name: "Journeyman of Ink", minWords: 6000),
    Rank(name: "Verse Weaver", minWords: 7500),
    Rank(name: "Tale Teller", minWords: 9000),
    Rank(name: "Chapter Crafter", minWords: 10000),
    Rank(name: "Narrative Navigator", minWords: 12500),
    Rank(name: "Manuscript Maven", minWords: 15000),
    Rank(name: "Syntax Scholar", minWords: 17500),
    Rank(name: "Grammar Guardian", minWords: 20000),
    Rank(name: "Plot Architect", minWords: 22500),
    Rank(name: "Poetry Pioneer", minWords: 25000),
    Rank(name: "Story Shaper", minWords: 30000),
    Rank(name: "Text Curator", minWords: 35000),
    Rank(name: "Prose Philosopher", minWords: 40000),
    Rank(name: "Plot Magician", minWords: 45000),
    Rank(name: "Narrative Alchemist", minWords: 50000),
    Rank(name: "Epic Scribe", minWords: 55000),
    Rank(name: "Literary Luminary", minWords: 60000),
    Rank(name: "Verse Virtuoso", minWords: 65000),
    Rank(name: "Story Strategist", minWords: 70000),
    Rank(name: "Paragraph Prophet", minWords: 75000),
    Rank(name: "Master of Manuscripts", minWords: 80000),
    Rank(name: "Plot Sage", minWords: 85000),
    Rank(name: "Syntax Sorcerer", minWords: 90000),
    Rank(name: "Legend Crafter", minWords: 95000),
    Rank(name: "Virtuoso of Verse", minWords: 100000),
    Rank(name: "Word Weaver", minWords: 125000),
    Rank(name: "Tome Tactician", minWords: 150000),
    Rank(name: "Epic Composer", minWords: 175000),
    Rank(name: "Text Titan", minWords: 200000),
    Rank(name: "Guardian of Grammar", minWords: 225000),
    Rank(name: "Sentinel of Stories", minWords: 250000),
    Rank(name: "Master of Rhetoric", minWords: 275000),
    Rank(name: "Narrative Nomad", minWords: 300000),
    Rank(name: "Archon of Articulation", minWords: 350000),
    Rank(name: "Oracle of Oratory", minWords: 400000),
    Rank(name: "Syntax Sovereign", minWords: 450000),
    Rank(name: "Scribe Supreme", minWords: 500000),
    Rank(name: "Epic Emissary", minWords: 600000),
    Rank(name: "Legendary Lexicographer", minWords: 800000),
    Rank(name: "Emissary of Eloquence", minWords: 1000000)
]

struct Analytics {
    var totalWords: Int = 0
    var streak: Int = 0
    var avgWordsPerDay: Int = 0
    var avgGoalTime: String = "00:00"
    var wordRecord: Int = 0 // Changed from totalPages
    var rank: String = "Word Dabbler"
    var nextRank: String = "Novice Scribe"
    var progressToNextRank: Double = 0.0
}

struct AnalyticsView: View {
    @State private var analytics: Analytics = Analytics()
    @State private var entries: [WritingEntry] = []
    private static let goalReachedTimesKey = "goalReachedTimes"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                TotalWordsView(totalWords: analytics.totalWords)
                ComparisonTextView(totalWords: analytics.totalWords)
                StatisticsGridView(analytics: analytics)
                RankView(rank: analytics.rank, 
                         nextRank: analytics.nextRank, 
                         progress: analytics.progressToNextRank, 
                         totalWords: analytics.totalWords)
                CalendarView(entries: entries)
            }
            .padding()
        }
        .navigationBarHidden(true)
        .onAppear(perform: loadEntriesAndCalculateAnalytics)
    }
    
    private func loadEntriesAndCalculateAnalytics() {
        loadEntries()
        calculateAnalytics()
    }
    
    private func loadEntries() {
        if let savedFolders = UserDefaults.standard.data(forKey: "writingFolders") {
            let decoder = JSONDecoder()
            if let decodedFolders = try? decoder.decode([Folder].self, from: savedFolders) {
                entries = decodedFolders.flatMap { $0.entries }
            }
        } else if let savedEntries = UserDefaults.standard.data(forKey: "writingEntries") {
            let decoder = JSONDecoder()
            if let decodedEntries = try? decoder.decode([WritingEntry].self, from: savedEntries) {
                entries = decodedEntries
            }
        }
    }
    
    private func calculateAnalytics() {
        analytics.totalWords = entries.reduce(0) { $0 + $1.wordCount }
        analytics.streak = calculateStreak()
        analytics.avgWordsPerDay = calculateAverageWordsPerDay()
        analytics.avgGoalTime = calculateAverageGoalTime()
        analytics.wordRecord = calculateWordRecord() // New function
        analytics.rank = calculateRank(totalWords: analytics.totalWords)
        analytics.nextRank = calculateNextRank(currentRank: analytics.rank)
        analytics.progressToNextRank = calculateProgressToNextRank(totalWords: analytics.totalWords, currentRank: analytics.rank)
    }
    
    private func calculateAverageGoalTime() -> String {
        let calendar = Calendar.current
        var totalMinutes = 0
        var count = 0
        
        if let goalReachedTimes = UserDefaults.standard.dictionary(forKey: AnalyticsView.goalReachedTimesKey) as? [String: Date] {
            print("Goal reached times: \(goalReachedTimes)")
            for (_, time) in goalReachedTimes {
                let components = calendar.dateComponents([.hour, .minute], from: time)
                let minutes = components.hour! * 60 + components.minute!
                totalMinutes += minutes
                count += 1
            }
        } else {
            print("No goal reached times found")
        }
        
        print("Total minutes: \(totalMinutes), Count: \(count)")
        
        if count == 0 {
            return "N/A"
        }
        
        let averageMinutes = totalMinutes / count
        let hours = averageMinutes / 60
        let minutes = averageMinutes % 60
        
        let result = String(format: "%02d:%02d", hours, minutes)
        print("Calculated average goal time: \(result)")
        return result
    }
    
    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        let sortedEntries = entries.sorted { $0.date > $1.date }
        var streak = 0
        var currentDate = Date()
        
        for entry in sortedEntries {
            let entryDate = calendar.startOfDay(for: entry.date)
            let daysApart = calendar.dateComponents([.day], from: entryDate, to: currentDate).day ?? 0
            
            if daysApart == streak {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else if daysApart > streak {
                break
            }
        }
        
        return streak
    }
    
    private func calculateAverageWordsPerDay() -> Int {
        guard !entries.isEmpty else { return 0 }
        let calendar = Calendar.current
        let firstEntryDate = entries.map { $0.date }.min() ?? Date()
        let daysSinceFirstEntry = calendar.dateComponents([.day], from: firstEntryDate, to: Date()).day ?? 1
        let totalWords = entries.reduce(0) { $0 + $1.wordCount }
        return totalWords / max(daysSinceFirstEntry, 1)
    }
    
    private func calculateWordRecord() -> Int {
        let groupedByDay = Dictionary(grouping: entries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }
        let dailyWordCounts = groupedByDay.mapValues { entries in
            entries.reduce(0) { $0 + $1.wordCount }
        }
        return dailyWordCounts.values.max() ?? 0
    }
    
    private func calculateRank(totalWords: Int) -> String {
        for rank in ranks.reversed() {
            if totalWords >= rank.minWords {
                return rank.name
            }
        }
        return ranks[0].name // Default to the first rank if totalWords is less than all thresholds
    }
    
    private func calculateNextRank(currentRank: String) -> String {
        if let currentIndex = ranks.firstIndex(where: { $0.name == currentRank }),
           currentIndex < ranks.count - 1 {
            return ranks[currentIndex + 1].name
        }
        return "Max Rank Achieved"
    }
    
    private func calculateProgressToNextRank(totalWords: Int, currentRank: String) -> Double {
        if let currentIndex = ranks.firstIndex(where: { $0.name == currentRank }) {
            let currentMinWords = ranks[currentIndex].minWords
            let nextMinWords = currentIndex < ranks.count - 1 ? ranks[currentIndex + 1].minWords : currentMinWords
            let progress = Double(totalWords - currentMinWords) / Double(nextMinWords - currentMinWords)
            return min(max(progress, 0), 1) // Ensure progress is between 0 and 1
        }
        return 1 // Return 1 if current rank is not found (shouldn't happen)
    }
    
    static func updateGoalReachedTime(for date: Date) {
        let dateString = ISO8601DateFormatter().string(from: date)
        var goalReachedTimes = UserDefaults.standard.dictionary(forKey: goalReachedTimesKey) as? [String: Date] ?? [:]
        print("Before update - Goal reached times: \(goalReachedTimes)")
        goalReachedTimes[dateString] = date
        UserDefaults.standard.set(goalReachedTimes, forKey: goalReachedTimesKey)
        print("After update - Goal reached times: \(goalReachedTimes)")
        print("Updated goal reached time for \(dateString)")
    }
}

struct TotalWordsView: View {
    let totalWords: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(totalWords)")
                .font(.system(size: 84, weight: .bold, design: .monospaced))
            Text("Total Words Written")
                .font(.system(size: 18, weight: .medium, design: .monospaced))
        }
    }
}

struct ComparisonTextView: View {
    let totalWords: Int
    
    var body: some View {
        Text(getComparisonText(totalWords: totalWords))
            .font(.system(size: 12, weight: .regular, design: .monospaced))
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    
    private func getComparisonText(totalWords: Int) -> String {
        // Implement comparison text logic
        return "You've written \(totalWords) words. Keep it up!"
    }
}

struct StatisticsGridView: View {
    let analytics: Analytics
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            StatItem(title: "Day Streak", value: "\(analytics.streak)")
            StatItem(title: "Avg. Daily Words", value: "\(analytics.avgWordsPerDay)")
            StatItem(title: "Avg. Goal Time", value: analytics.avgGoalTime)
            StatItem(title: "Word Record", value: "\(analytics.wordRecord)") // Changed from "Total Pages"
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
            Text(title)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct RankView: View {
    let rank: String
    let nextRank: String
    let progress: Double
    let totalWords: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Your current rank")
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(.secondary)
                    Text(rank)
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                }
                Spacer()
                Image(systemName: "medal")
                    .font(.system(size: 32))
                    .foregroundColor(.yellow)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            
            Text(wordsToNextRank)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    private var wordsToNextRank: String {
        if let currentRankIndex = ranks.firstIndex(where: { $0.name == rank }),
           currentRankIndex < ranks.count - 1 {
            let nextRankWords = ranks[currentRankIndex + 1].minWords
            let wordsNeeded = nextRankWords - totalWords
            return "\(wordsNeeded) words to go until you reach \(nextRank)!"
        } else {
            return "You've reached the highest rank!"
        }
    }
}

struct CalendarView: View {
    let entries: [WritingEntry]
    @State private var currentDate = Date()
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearString(from: currentDate))
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                Spacer()
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        CalendarCell(date: date, status: getEntryStatus(for: date))
                    } else {
                        Color.clear
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = newDate
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        while days.count < 42 {
            days.append(nil)
        }
        
        return days
    }
    
    private func getEntryStatus(for date: Date) -> EntryStatus {
        let calendar = Calendar.current
        if let firstEntry = entries.sorted(by: { $0.date < $1.date }).first,
           date < calendar.startOfDay(for: firstEntry.date) {
            return .beforeApp
        } else if calendar.isDateInToday(date) || date <= Date() {
            if entries.contains(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                return .completed
            } else {
                return .missed
            }
        } else {
            return .future
        }
    }
}

enum EntryStatus {
    case completed, missed, future, beforeApp
}

struct CalendarCell: View {
    let date: Date
    let status: EntryStatus
    
    var body: some View {
        Group {
            switch status {
            case .completed:
                Text("🔥")
                    .font(.system(size: 18))
            case .missed:
                Text("✗")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.red)
            case .future, .beforeApp:
                Text(dayNumber)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(status == .future ? .secondary : .primary)
            }
        }
        .frame(height: 30)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}