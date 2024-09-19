import SwiftUI

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
        let ranks = [
            (0, "Word Dabbler"),
            (500, "Novice Scribe"),
            (1000, "Adept Penman"),
            (1500, "Inkling"),
            (2000, "Quill Rookie"),
            (2500, "Page Apprentice"),
            (3000, "Wordsmith in Training"),
            (3500, "Prose Pupil"),
            (4000, "Paragraph Novice"),
            (4500, "Script Explorer"),
            (5000, "Sentence Seeker"),
            (6000, "Journeyman of Ink"),
            (7500, "Verse Weaver"),
            (9000, "Tale Teller"),
            (10000, "Chapter Crafter"),
            (12500, "Narrative Navigator"),
            (15000, "Manuscript Maven"),
            (17500, "Syntax Scholar"),
            (20000, "Grammar Guardian"),
            (22500, "Plot Architect"),
            (25000, "Poetry Pioneer"),
            (30000, "Story Shaper"),
            (35000, "Text Curator"),
            (40000, "Prose Philosopher"),
            (45000, "Plot Magician"),
            (50000, "Narrative Alchemist"),
            (55000, "Epic Scribe"),
            (60000, "Literary Luminary"),
            (65000, "Verse Virtuoso"),
            (70000, "Story Strategist"),
            (75000, "Paragraph Prophet"),
            (80000, "Master of Manuscripts"),
            (85000, "Plot Sage"),
            (90000, "Syntax Sorcerer"),
            (95000, "Legend Crafter"),
            (100000, "Virtuoso of Verse"),
            (125000, "Word Weaver"),
            (150000, "Tome Tactician"),
            (175000, "Epic Composer"),
            (200000, "Text Titan"),
            (225000, "Guardian of Grammar"),
            (250000, "Sentinel of Stories"),
            (275000, "Master of Rhetoric"),
            (300000, "Narrative Nomad"),
            (350000, "Archon of Articulation"),
            (400000, "Oracle of Oratory"),
            (450000, "Syntax Sovereign"),
            (500000, "Scribe Supreme"),
            (600000, "Epic Emissary"),
            (800000, "Legendary Lexicographer"),
            (1000000, "Emissary of Eloquence")
        ]
        
        for (wordCount, rank) in ranks.reversed() {
            if totalWords >= wordCount {
                return rank
            }
        }
        return "Word Dabbler"
    }
    
    private func calculateNextRank(currentRank: String) -> String {
        let ranks = [
            "Word Dabbler", "Novice Scribe", "Adept Penman", "Inkling", "Quill Rookie",
            "Page Apprentice", "Wordsmith in Training", "Prose Pupil", "Paragraph Novice",
            "Script Explorer", "Sentence Seeker", "Journeyman of Ink", "Verse Weaver",
            "Tale Teller", "Chapter Crafter", "Narrative Navigator", "Manuscript Maven",
            "Syntax Scholar", "Grammar Guardian", "Plot Architect", "Poetry Pioneer",
            "Story Shaper", "Text Curator", "Prose Philosopher", "Plot Magician",
            "Narrative Alchemist", "Epic Scribe", "Literary Luminary", "Verse Virtuoso",
            "Story Strategist", "Paragraph Prophet", "Master of Manuscripts", "Plot Sage",
            "Syntax Sorcerer", "Legend Crafter", "Virtuoso of Verse", "Word Weaver",
            "Tome Tactician", "Epic Composer", "Text Titan", "Guardian of Grammar",
            "Sentinel of Stories", "Master of Rhetoric", "Narrative Nomad",
            "Archon of Articulation", "Oracle of Oratory", "Syntax Sovereign",
            "Scribe Supreme", "Epic Emissary", "Legendary Lexicographer",
            "Emissary of Eloquence"
        ]
        
        if let currentIndex = ranks.firstIndex(of: currentRank),
           currentIndex < ranks.count - 1 {
            return ranks[currentIndex + 1]
        }
        return "Emissary of Eloquence"
    }
    
    private func calculateProgressToNextRank(totalWords: Int, currentRank: String) -> Double {
        let ranks = [
            (0, "Word Dabbler"),
            (500, "Novice Scribe"),
            (1000, "Adept Penman"),
            (1500, "Inkling"),
            (2000, "Quill Rookie"),
            (2500, "Page Apprentice"),
            (3000, "Wordsmith in Training"),
            (3500, "Prose Pupil"),
            (4000, "Paragraph Novice"),
            (4500, "Script Explorer"),
            (5000, "Sentence Seeker"),
            (6000, "Journeyman of Ink"),
            (7500, "Verse Weaver"),
            (9000, "Tale Teller"),
            (10000, "Chapter Crafter"),
            (12500, "Narrative Navigator"),
            (15000, "Manuscript Maven"),
            (17500, "Syntax Scholar"),
            (20000, "Grammar Guardian"),
            (22500, "Plot Architect"),
            (25000, "Poetry Pioneer"),
            (30000, "Story Shaper"),
            (35000, "Text Curator"),
            (40000, "Prose Philosopher"),
            (45000, "Plot Magician"),
            (50000, "Narrative Alchemist"),
            (55000, "Epic Scribe"),
            (60000, "Literary Luminary"),
            (65000, "Verse Virtuoso"),
            (70000, "Story Strategist"),
            (75000, "Paragraph Prophet"),
            (80000, "Master of Manuscripts"),
            (85000, "Plot Sage"),
            (90000, "Syntax Sorcerer"),
            (95000, "Legend Crafter"),
            (100000, "Virtuoso of Verse"),
            (125000, "Word Weaver"),
            (150000, "Tome Tactician"),
            (175000, "Epic Composer"),
            (200000, "Text Titan"),
            (225000, "Guardian of Grammar"),
            (250000, "Sentinel of Stories"),
            (275000, "Master of Rhetoric"),
            (300000, "Narrative Nomad"),
            (350000, "Archon of Articulation"),
            (400000, "Oracle of Oratory"),
            (450000, "Syntax Sovereign"),
            (500000, "Scribe Supreme"),
            (600000, "Epic Emissary"),
            (800000, "Legendary Lexicographer"),
            (1000000, "Emissary of Eloquence")
        ]
        
        if let currentIndex = ranks.firstIndex(where: { $0.1 == currentRank }),
           currentIndex < ranks.count - 1 {
            let currentThreshold = ranks[currentIndex].0
            let nextThreshold = ranks[currentIndex + 1].0
            return Double(totalWords - currentThreshold) / Double(nextThreshold - currentThreshold)
        }
        return 1.0
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
        let comparisonBooks = [
            ("Green Eggs and Ham", "Dr. Seuss", 750),
            ("Gettysburg Address", "Abraham Lincoln", 270),
            ("The Tell-Tale Heart", "Edgar Allan Poe", 2200),
            ("The Yellow Wallpaper", "Charlotte Perkins Gilman", 6000),
            ("A Scandal in Bohemia", "Arthur Conan Doyle", 7500),
            ("The Lottery", "Shirley Jackson", 3400),
            ("A Good Man is Hard to Find", "Flannery O'Connor", 6200),
            ("Animal Farm", "George Orwell", 30000),
            ("Of Mice and Men", "John Steinbeck", 29000),
            ("Breakfast at Tiffany's", "Truman Capote", 26000),
            ("The Old Man and the Sea", "Ernest Hemingway", 27000),
            ("The Metamorphosis", "Franz Kafka", 21000),
            ("The Great Gatsby", "F. Scott Fitzgerald", 47000),
            ("The Outsiders", "S.E. Hinton", 48500),
            ("The Road Not Taken", "Robert Frost", 256),
            ("The Raven", "Edgar Allan Poe", 1080),
            ("Where the Sidewalk Ends", "Shel Silverstein", 110),
            ("Fahrenheit 451", "Ray Bradbury", 46000),
            ("Slaughterhouse-Five", "Kurt Vonnegut", 49500),
            ("The Catcher in the Rye", "J.D. Salinger", 73000),
            ("Lord of the Flies", "William Golding", 59900),
            ("The Picture of Dorian Gray", "Oscar Wilde", 78000),
            ("The Road", "Cormac McCarthy", 87000),
            ("To Kill a Mockingbird", "Harper Lee", 100000),
            ("1984", "George Orwell", 88900),
            ("Brave New World", "Aldous Huxley", 64000),
            ("The Stranger", "Albert Camus", 36000),
            ("The Alchemist", "Paulo Coelho", 39000),
            ("Siddhartha", "Hermann Hesse", 41500),
            ("Fight Club", "Chuck Palahniuk", 49000),
            ("The Perks of Being a Wallflower", "Stephen Chbosky", 62000),
            ("The Hobbit", "J.R.R. Tolkien", 95000),
            ("Coraline", "Neil Gaiman", 30000),
            ("The Giver", "Lois Lowry", 43000),
            ("Harry Potter and the Philosopher's Stone", "J.K. Rowling", 77000),
            ("Ender's Game", "Orson Scott Card", 100000),
            ("The Hunger Games", "Suzanne Collins", 99750),
            ("Twilight", "Stephenie Meyer", 118000),
            ("Divergent", "Veronica Roth", 105000),
            ("Ready Player One", "Ernest Cline", 136000),
            ("The Maze Runner", "James Dashner", 101000),
            ("The Da Vinci Code", "Dan Brown", 138000),
            ("Gone Girl", "Gillian Flynn", 145000),
            ("The Fault in Our Stars", "John Green", 67000),
            ("The Catcher in the Rye", "J.D. Salinger", 73000),
            ("American Psycho", "Bret Easton Ellis", 145000),
            ("The Girl on the Train", "Paula Hawkins", 107000),
            ("The Shining", "Stephen King", 160000),
            ("Jurassic Park", "Michael Crichton", 120000),
            ("A Game of Thrones", "George R.R. Martin", 298000),
            ("The Fellowship of the Ring", "J.R.R. Tolkien", 187000),
            ("The Two Towers", "J.R.R. Tolkien", 156000),
            ("The Return of the King", "J.R.R. Tolkien", 137000),
            ("The Martian", "Andy Weir", 100000),
            ("IT", "Stephen King", 445000),
            ("A Clash of Kings", "George R.R. Martin", 326000),
            ("A Storm of Swords", "George R.R. Martin", 414000),
            ("The Winds of Winter", "George R.R. Martin", 600000),
            ("Don Quixote", "Miguel de Cervantes", 430000),
            ("Moby-Dick", "Herman Melville", 206000),
            ("War and Peace", "Leo Tolstoy", 587000),
            ("Les Misérables", "Victor Hugo", 655000),
            ("The Count of Monte Cristo", "Alexandre Dumas", 464000),
            ("Ulysses", "James Joyce", 265000),
            ("Gone with the Wind", "Margaret Mitchell", 418000),
            ("Infinite Jest", "David Foster Wallace", 543000),
            ("The Stand", "Stephen King", 472000),
            ("Atlas Shrugged", "Ayn Rand", 645000),
            ("Middlemarch", "George Eliot", 316000),
            ("Gravity's Rainbow", "Thomas Pynchon", 280000),
            ("The Brothers Karamazov", "Fyodor Dostoevsky", 365000),
            ("David Copperfield", "Charles Dickens", 360000),
            ("Bleak House", "Charles Dickens", 360000),
            ("A Tale of Two Cities", "Charles Dickens", 135000),
            ("Anna Karenina", "Leo Tolstoy", 350000),
            ("Crime and Punishment", "Fyodor Dostoevsky", 211000),
            ("The Grapes of Wrath", "John Steinbeck", 169000),
            ("The Hunchback of Notre-Dame", "Victor Hugo", 195000),
            ("The Odyssey", "Homer", 121000),
            ("Pride and Prejudice", "Jane Austen", 122000),
            ("Frankenstein", "Mary Shelley", 74000),
            ("Jane Eyre", "Charlotte Brontë", 183000),
            ("Wuthering Heights", "Emily Brontë", 107000),
            ("Emma", "Jane Austen", 160000),
            ("Sense and Sensibility", "Jane Austen", 119000),
            ("Dracula", "Bram Stoker", 160000),
            ("The Time Machine", "H.G. Wells", 32000),
            ("The War of the Worlds", "H.G. Wells", 60000),
            ("Heart of Darkness", "Joseph Conrad", 38000),
            ("Dune", "Frank Herbert", 188000),
            ("The Call of the Wild", "Jack London", 47000),
            ("The Bell Jar", "Sylvia Plath", 70000),
            ("The Scarlet Letter", "Nathaniel Hawthorne", 63000),
            ("The Handmaid's Tale", "Margaret Atwood", 90000),
            ("Rebecca", "Daphne du Maurier", 118000),
            ("Dr. Jekyll and Mr. Hyde", "Robert Louis Stevenson", 60000),
            ("A Clockwork Orange", "Anthony Burgess", 60000),
            ("The Hitchhiker's Guide to the Galaxy", "Douglas Adams", 46000),
            ("One Hundred Years of Solitude", "Gabriel García Márquez", 144000),
            ("The Sound and the Fury", "William Faulkner", 110000),
            ("Beloved", "Toni Morrison", 111000),
            ("The Godfather", "Mario Puzo", 139000),
            ("The Book Thief", "Markus Zusak", 118000),
            ("Where the Sidewalk Ends", "Shel Silverstein", 110),
            ("The Raven", "Edgar Allan Poe", 1080)
        ]
        
        if totalWords < 100 {
            return "You're on your way to becoming a writer! Keep going, every word counts!"
        }
        
        let closestBook = comparisonBooks.min(by: { abs($0.2 - totalWords) < abs($1.2 - totalWords) })!
        let difference = abs(closestBook.2 - totalWords)
        let moreOrLess = totalWords > closestBook.2 ? "more" : "fewer"
        
        if difference < 100 {
            return "Amazing! You've written about the same number of words as '\(closestBook.0)' by \(closestBook.1) (\(closestBook.2) words)!"
        } else {
            return "You've written \(difference) words \(moreOrLess) than '\(closestBook.0)' by \(closestBook.1) (\(closestBook.2) words). Keep writing!"
        }
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
            
            ProgressView(value: calculateProgressToNextRank())
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            
            Text("Only \(wordsToNextRank()) words to go! Keep writing to become a \"\(calculateNextRank())\"!")
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    private func calculateProgressToNextRank() -> Double {
        let ranks = [
            (0, "Word Dabbler"), (500, "Novice Scribe"), (1000, "Adept Penman"),
            (1500, "Inkling"), (2000, "Quill Rookie"), (2500, "Page Apprentice"),
            (3000, "Wordsmith in Training"), (3500, "Prose Pupil"), (4000, "Paragraph Novice"),
            (4500, "Script Explorer"), (5000, "Sentence Seeker"), (6000, "Journeyman of Ink"),
            (7500, "Verse Weaver"), (9000, "Tale Teller"), (10000, "Chapter Crafter"),
            (12500, "Narrative Navigator"), (15000, "Manuscript Maven"), (17500, "Syntax Scholar"),
            (20000, "Grammar Guardian"), (22500, "Plot Architect"), (25000, "Poetry Pioneer")
            // Add more ranks as needed
        ]
        
        if let currentIndex = ranks.firstIndex(where: { $0.1 == rank }),
           currentIndex < ranks.count - 1 {
            let currentThreshold = ranks[currentIndex].0
            let nextThreshold = ranks[currentIndex + 1].0
            return Double(totalWords - currentThreshold) / Double(nextThreshold - currentThreshold)
        }
        return 1.0
    }
    
    private func calculateNextRank() -> String {
        let ranks = [
            "Word Dabbler", "Novice Scribe", "Adept Penman", "Inkling", "Quill Rookie",
            "Page Apprentice", "Wordsmith in Training", "Prose Pupil", "Paragraph Novice",
            "Script Explorer", "Sentence Seeker", "Journeyman of Ink", "Verse Weaver",
            "Tale Teller", "Chapter Crafter", "Narrative Navigator", "Manuscript Maven",
            "Syntax Scholar", "Grammar Guardian", "Plot Architect", "Poetry Pioneer"
            // Add more ranks as needed
        ]
        
        if let currentIndex = ranks.firstIndex(of: rank),
           currentIndex < ranks.count - 1 {
            return ranks[currentIndex + 1]
        }
        return "Master Wordsmith"
    }
    
    private func wordsToNextRank() -> Int {
        let ranks = [
            (0, "Word Dabbler"), (500, "Novice Scribe"), (1000, "Adept Penman"),
            (1500, "Inkling"), (2000, "Quill Rookie"), (2500, "Page Apprentice"),
            (3000, "Wordsmith in Training"), (3500, "Prose Pupil"), (4000, "Paragraph Novice"),
            (4500, "Script Explorer"), (5000, "Sentence Seeker"), (6000, "Journeyman of Ink"),
            (7500, "Verse Weaver"), (9000, "Tale Teller"), (10000, "Chapter Crafter"),
            (12500, "Narrative Navigator"), (15000, "Manuscript Maven"), (17500, "Syntax Scholar"),
            (20000, "Grammar Guardian"), (22500, "Plot Architect"), (25000, "Poetry Pioneer")
            // Add more ranks as needed
        ]
        
        if let currentIndex = ranks.firstIndex(where: { $0.1 == rank }),
           currentIndex < ranks.count - 1 {
            let nextThreshold = ranks[currentIndex + 1].0
            return max(nextThreshold - totalWords, 0)
        }
        return 0
    }
}

struct CalendarView: View {
    let entries: [WritingEntry]
    
    @State private var currentDate = Date()
    let calendar = Calendar.current
    
    var body: some View {
        VStack {
            Text(monthYearString(from: currentDate))
                .font(.system(size: 16, weight: .medium, design: .monospaced))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<7, id: \.self) { index in
                    Text(weekdaySymbol(for: index))
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                
                ForEach(daysInMonth(), id: \.self) { day in
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
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func weekdaySymbol(for index: Int) -> String {
        let symbols = calendar.veryShortWeekdaySymbols
        return symbols[index]
    }
    
    private func daysInMonth() -> [Int?] {
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
    
    private func hasEntry(for day: Int) -> Bool {
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
                .font(.system(size: 14, weight: .regular, design: .monospaced))
            
            if hasEntry {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 14))
            }
        }
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
    }
}
