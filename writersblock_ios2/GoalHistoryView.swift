import SwiftUI

struct GoalHistoryView: View {
    @EnvironmentObject var writingStateManager: WritingStateManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(getDates(), id: \.self) { date in
                    HStack {
                        Text(formatDate(date))
                        Spacer()
                        if let achieved = writingStateManager.goalHistory[date] {
                            Image(systemName: achieved ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(achieved ? .green : .red)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Goal History")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func getDates() -> [Date] {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        let startDate = writingStateManager.goalHistory.keys.min() ?? endDate
        
        return calendar.generateDates(
            inside: DateInterval(start: startDate, end: endDate),
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        ).reversed()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)

        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date <= interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }

        return dates
    }
}