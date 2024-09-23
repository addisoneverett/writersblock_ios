import SwiftUI

// This file can be used for any additional models or helper structs that aren't defined elsewhere

extension Date {
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
    
    var endOfMonth: Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth)!
    }
}

enum DateRange: CaseIterable, Hashable {
    case allTime, lastMonth, lastYear, custom(Date, Date)

    static var allCases: [DateRange] {
        [.allTime, .lastMonth, .lastYear]
    }

    var description: String {
        switch self {
        case .allTime: return "All Time"
        case .lastMonth: return "Last Month"
        case .lastYear: return "Last Year"
        case .custom(let start, let end): return "\(start.formatted(date: .abbreviated, time: .omitted)) - \(end.formatted(date: .abbreviated, time: .omitted))"
        }
    }

    func contains(_ date: Date) -> Bool {
        switch self {
        case .allTime:
            return true
        case .lastMonth:
            return date > Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        case .lastYear:
            return date > Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        case .custom(let start, let end):
            return date >= start && date <= end
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .allTime:
            hasher.combine(0)
        case .lastMonth:
            hasher.combine(1)
        case .lastYear:
            hasher.combine(2)
        case .custom(let start, let end):
            hasher.combine(3)
            hasher.combine(start)
            hasher.combine(end)
        }
    }

    static func == (lhs: DateRange, rhs: DateRange) -> Bool {
        switch (lhs, rhs) {
        case (.allTime, .allTime), (.lastMonth, .lastMonth), (.lastYear, .lastYear):
            return true
        case (.custom(let lStart, let lEnd), .custom(let rStart, let rEnd)):
            return lStart == rStart && lEnd == rEnd
        default:
            return false
        }
    }
}

// Add any other helper structs or extensions as needed