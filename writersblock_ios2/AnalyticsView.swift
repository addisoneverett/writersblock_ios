import SwiftUI

struct AnalyticsView: View {
    @State private var analytics: Analytics = Analytics()
    @State private var entries: [WritingEntry] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TotalWordsView(totalWords: analytics.totalWords)
                ComparisonTextView(totalWords: analytics.totalWords)
                StatisticsGridView(analytics: analytics)
                RankView(rank: analytics.rank, totalWords: analytics.totalWords)
                CalendarView(entries: entries)
            }
            .padding()
        }
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
        // Implement progress calculation logic
        return 0.5
    }
}

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

struct TotalWordsView: View {
    let totalWords: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(totalWords)")
                .font(.system(size: 48, weight: .bold))
            Text("Total Words Written")
                .font(.title2)
        }
    }
}

struct ComparisonTextView: View {
    let totalWords: Int
    
    var body: some View {
        Text(getComparisonText(totalWords: totalWords))
            .font(.caption) // Changed from .body to .caption
            .multilineTextAlignment(.center)
            .padding(.horizontal) // Added horizontal padding
            .padding(.vertical, 4) // Reduced vertical padding
    }
    
    private func getComparisonText(totalWords: Int) -> String {
        // Implement the comparison logic here
        // This should return a string comparing the total words to a book or other milestone
        return "That's almost as many words as 'The Great Gatsby' by F. Scott Fitzgerald (47,094 words)!"
    }
}

struct StatisticsGridView: View {
    let analytics: Analytics
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
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
        VStack {
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct RankView: View {
    let rank: String
    let totalWords: Int
    @State private var nextRank: String = "Novice Scribe"
    @State private var progressToNextRank: Double = 0.5
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Your current rank")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(rank)
                        .font(.title3.bold())
                }
                Spacer()
                Image(systemName: "medal")
                    .font(.title2)
                    .foregroundColor(.yellow)
            }
            
            ProgressView(value: progressToNextRank)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            
            Text("Only \(Int((1 - progressToNextRank) * 1000)) words to go! Keep writing to become a \"\(nextRank)\"!")
                .font(.caption)
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
    let calendar = Calendar.current
    
    var body: some View {
        VStack {
            Text(monthYearString(from: currentDate))
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<7, id: \.self) { index in
                    Text(weekdaySymbol(for: index))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ForEach(Array(daysInMonth().enumerated()), id: \.offset) { index, day in
                    if let day = day {
                        CalendarDayView(day: day, hasEntry: hasEntry(for: day))
                    } else {
                        Text("")
                            .frame(height: 30)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    func weekdaySymbol(for index: Int) -> String {
        let symbols = calendar.veryShortWeekdaySymbols
        return symbols[index]
    }
    
    func daysInMonth() -> [Int?] {
        guard let range = calendar.range(of: .day, in: .month, for: currentDate) else { return [] }
        let numDays = range.count
        
        let firstWeekday = calendar.component(.weekday, from: currentDate)
        var days: [Int?] = Array(repeating: nil, count: firstWeekday - 1)
        days += Array(1...numDays)
        
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    func hasEntry(for day: Int) -> Bool {
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        guard let date = calendar.date(from: components) else { return false }
        let dayDate = calendar.date(byAdding: .day, value: day - 1, to: date)!
        
        return entries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: dayDate)
        }
    }
}

struct CalendarDayView: View {
    let day: Int
    let hasEntry: Bool
    
    var body: some View {
        ZStack {
            Text("\(day)")
                .frame(height: 30)
                .font(.body)
            
            if hasEntry {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 20))
            }
        }
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
    }
}
