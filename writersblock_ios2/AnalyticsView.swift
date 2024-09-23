import SwiftUI

struct Analytics {
    var totalWords: Int = 0
    var streak: Int = 0
    var avgWordsPerDay: Int = 0
    var avgGoalTime: String = "00:00"
    var totalPages: Int = 0
    var rank: String = "Word Dabbler"
    var nextRank: String = "Novice Scribe"
    var progressToNextRank: Double = 0.0
}

struct AnalyticsView: View {
    @State private var analytics: Analytics = Analytics()
    @State private var entries: [WritingEntry] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                TotalWordsView(totalWords: analytics.totalWords)
                ComparisonTextView(totalWords: analytics.totalWords)
                StatisticsGridView(analytics: analytics)
                RankView(rank: analytics.rank, totalWords: analytics.totalWords)
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
        if let savedEntries = UserDefaults.standard.data(forKey: "writingEntries") {
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
        analytics.totalPages = analytics.totalWords / 250 // Assuming 250 words per page
        analytics.rank = calculateRank(totalWords: analytics.totalWords)
        analytics.nextRank = calculateNextRank(currentRank: analytics.rank)
        analytics.progressToNextRank = calculateProgressToNextRank(totalWords: analytics.totalWords, currentRank: analytics.rank)
    }
    
    private func calculateStreak() -> Int {
        // Implement streak calculation logic
        return 0
    }
    
    private func calculateAverageWordsPerDay() -> Int {
        guard !entries.isEmpty else { return 0 }
        let totalDays = Calendar.current.dateComponents([.day], from: entries.first!.date, to: Date()).day ?? 1
        return analytics.totalWords / max(totalDays, 1)
    }
    
    private func calculateRank(totalWords: Int) -> String {
        // Implement rank calculation logic
        return "Word Dabbler"
    }
    
    private func calculateNextRank(currentRank: String) -> String {
        // Implement next rank calculation logic
        return "Novice Scribe"
    }
    
    private func calculateProgressToNextRank(totalWords: Int, currentRank: String) -> Double {
        // Implement progress to next rank calculation logic
        return 0.5
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
            StatItem(title: "Total Pages", value: "\(analytics.totalPages)")
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
            
            ProgressView(value: 0.5) // Replace with actual progress calculation
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            
            Text("Keep writing to reach the next rank!")
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
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
