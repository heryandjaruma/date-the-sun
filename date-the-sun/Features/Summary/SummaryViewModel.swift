import Foundation
import Combine

@MainActor
final class SummaryViewModel: ObservableObject {
    @Published var selectedPeriod: SummaryPeriod = .daily
    @Published private(set) var protectionItems: [ProtectionItem] = []
    @Published var dateText: String
    @Published var currentDate: Date

    // 👇 Changed to @Published var so your weekly range headers can change on calendar pick!
    @Published var weekLabel: String
    
    // 👇 Removed private(set) so we can update these stats inside our refresh function safely
    @Published var headline: String = ""
    @Published var weeklyHeadline: String = ""
    @Published var mood: KiranMood = .happy
    @Published var weeklyMood: KiranMood = .calm
    @Published var intervals: [SunExposureInterval] = []
    @Published var weekDays: [DayExposureStat] = []
    @Published var protectionWeek: [ProtectionWeekRow] = []

    private let sunDataProvider: SunDataProviding
    private let calendar: Calendar

    init(sunDataProvider: SunDataProviding = MockSunDataProvider(),
         calendar: Calendar = .current,
         now: Date = Date()) {
        self.sunDataProvider = sunDataProvider
        self.calendar = calendar
        self.currentDate = now

        // Initialize date display values
        self.dateText = Self.formattedDate(now, calendar: calendar)
        self.weekLabel = Self.formattedWeek(now, calendar: calendar)
        
        // 👇 Reusable function to initialize our data layout cleanly
        loadDashboardData(for: now)
    }

    func select(_ period: SummaryPeriod) {
        selectedPeriod = period
    }

    func toggleProtection(_ item: ProtectionItem) {
        guard let index = protectionItems.firstIndex(where: { $0.id == item.id }) else { return }
        protectionItems[index].isCompleted.toggle()
    }
    
    /// Updates strings and forces a fresh query execution down to the data provider layer
    func updateForDate(_ date: Date) {
        self.currentDate = date
        
        // 1. Re-format the layout tracking strings
        let formatter = DateFormatter()
        formatter.calendar = self.calendar
        formatter.dateFormat = "d MMMM yyyy"
        self.dateText = formatter.string(from: date)
        self.weekLabel = Self.formattedWeek(date, calendar: self.calendar)
        
        // 2. 👇 FIXED: Reload dashboard variables using the selected calendar date
        loadDashboardData(for: date)
    }
    
    /// Helper routine that connects to your repository provider asset layer
    private func loadDashboardData(for date: Date) {
        // NOTE: If your SunDataProviding protocol accepts parameters, pass `date` directly into it:
        // e.g., sunDataProvider.summaryForDate(date)
        let daily = sunDataProvider.todaySummary()
        let weekly = sunDataProvider.weeklySummary()

        // Reassign values to update the active @Published screen observers
        headline = daily.headline
        mood = daily.mood
        intervals = daily.intervals
        protectionItems = daily.protectionItems

        weeklyHeadline = weekly.headline
        weeklyMood = weekly.mood
        weekDays = weekly.days
        protectionWeek = weekly.protection
    }

    // MARK: - Date formatting

    private static func formattedDate(_ date: Date, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }

    private static func formattedWeek(_ date: Date, calendar: Calendar) -> String {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return "This Week"
        }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "d MMM"
        let start = formatter.string(from: interval.start)
        let end = formatter.string(from: interval.end.addingTimeInterval(-1))
        return "\(start) – \(end)"
    }
}
