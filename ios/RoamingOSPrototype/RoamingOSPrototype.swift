import SwiftUI
import UIKit

private enum Theme {
    static let canvas = Color(hex: "FAFBFE")
    static let screen = Color.white
    static let brand = Color(hex: "0D2A63")
    static let brandSoft = Color(hex: "E9F0FF")
    static let ink = Color(hex: "17233C")
    static let inkSoft = Color(hex: "67748F")
    static let line = Color(hex: "E7EBF3")
    static let lineStrong = Color(hex: "D7DFEE")
    static let progressBase = Color(hex: "E6EAF2")
    static let scheduleBlue = Color(hex: "DDE8FF")
    static let scheduleMint = Color(hex: "DDF2E9")
    static let scheduleLavender = Color(hex: "E8E5FF")
    static let peach = Color(hex: "FFF2E5")
    static let orange = Color(hex: "F28C49")
    static let orangeSoft = Color(hex: "FFE8D2")
    static let blue = Color(hex: "2F66FF")
    static let green = Color(hex: "19986C")
    static let greenSoft = Color(hex: "DFF5EA")
    static let dispatchYellow = Color(hex: "E2A93B")
    static let dispatchYellowSoft = Color(hex: "FFF4D7")
    static let dispatchRed = Color(hex: "E35D54")
    static let dispatchRedSoft = Color(hex: "FDE7E4")
    static let shadow = Color.black.opacity(0.035)
}

private extension Color {
    init(hex: String) {
        let sanitized = hex.replacingOccurrences(of: "#", with: "")
        let value = UInt64(sanitized, radix: 16) ?? 0
        self.init(
            .sRGB,
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: 1
        )
    }
}

private enum AppScreen {
    case home
    case plan
    case schedule
    case trip
    case tripDetail
    case profile
}

private enum NavTab: CaseIterable {
    case home
    case trips
    case schedule
    case plan
    case profile

    var title: String {
        switch self {
        case .home: return "Home"
        case .trips: return "Trips"
        case .schedule: return "Schedule"
        case .plan: return "Plan"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .trips: return "car"
        case .schedule: return "calendar"
        case .plan: return "calendar.badge.clock"
        case .profile: return "person"
        }
    }
}

private struct PlanOption: Identifiable {
    let id: Int
    let miles: Int
    let weeklyPrice: Int
    let extraMilePrice: Double
    let badge: String?
}

private extension PlanOption {
    var isTripPolicy: Bool {
        id == 0
    }

    var pricePerMile: Double {
        extraMilePrice
    }

    var displayTitle: String {
        isTripPolicy ? "Trip Policy" : "\(miles) miles / week"
    }

    var displayPrice: String {
        isTripPolicy ? currencyString(extraMilePrice) : "$\(weeklyPrice)"
    }

    var billingSuffix: String {
        isTripPolicy ? "/ mile" : "/ week"
    }

    var summaryLine: String {
        isTripPolicy ? "Charged at $2.00 per mile. No weekly renewal." : "Renews May 26, 2026"
    }

    var accountPlanLabel: String {
        isTripPolicy ? "Trip Policy" : displayTitle
    }
}

private enum TripStatus {
    case onTime
    case upcoming

    var title: String {
        switch self {
        case .onTime: return "On time"
        case .upcoming: return "Upcoming"
        }
    }

    var foreground: Color {
        switch self {
        case .onTime: return Theme.green
        case .upcoming: return Theme.blue
        }
    }

    var background: Color {
        switch self {
        case .onTime: return Theme.greenSoft
        case .upcoming: return Theme.brandSoft
        }
    }
}

private struct ScheduledTrip: Identifiable, Equatable {
    let id: String
    let route: String
    let from: String
    let to: String
    let dayLine: String
    let timeWindow: String
    let timeShort: String
    let startHour: Int
    let startMinuteOfDay: Int
    let durationMinutes: Int
    let miles: Int
    let pickup: String
    let dropoff: String
    let status: TripStatus
    let tint: Color
}

private struct ScheduleBlock: Identifiable, Equatable {
    let id: String
    let dayIndex: Int
    let from: String
    let to: String
    var startMinuteOfDay: Int
    let durationMinutes: Int
    let detail: String

    var route: String {
        "\(from) → \(to)"
    }

    var timeShort: String {
        DemoTimeFormatter.range(startMinute: startMinuteOfDay, durationMinutes: durationMinutes)
    }
}

private struct ScheduleWeekDay: Identifiable, Equatable {
    let index: Int
    let date: Date
    let symbol: String
    let dateNumber: String
    let title: String

    var id: Int { index }
}

private struct ScheduleMonthDay: Identifiable, Equatable {
    let date: Date
    let dayNumber: String
    let isInDisplayedMonth: Bool

    var id: String {
        DemoCalendar.dayKey(for: date)
    }
}

private struct RouteQuote: Identifiable, Equatable {
    let id: String
    let from: String
    let to: String
    let miles: Int
    let durationMinutes: Int

    func price(for plan: PlanOption) -> Double {
        Double(miles) * plan.pricePerMile
    }
}

private struct TripBookingRequest {
    let from: String
    let to: String
    let departureMinute: Int
    let dayIndices: [Int]
}

private struct AccountProfile: Equatable {
    var fullName: String
    var preferredName: String
    var phoneNumber: String
    var email: String
    var homeAddress: String
    var workAddress: String
    var emergencyContactName: String
    var emergencyContactPhone: String
    var memberSince: String
    var planName: String
    var milesRemaining: Double
    var weeklyPlanMiles: Int
    var paymentMethod: String
    var businessProfile: String
    var riderRating: Double
    var tripCount: Int
    var notificationsEnabled: Bool
    var lockInAlertsEnabled: Bool
    var promoEmailsEnabled: Bool

    var displayName: String {
        preferredName.isEmpty ? fullName : preferredName
    }

    var initials: String {
        let source = displayName.isEmpty ? fullName : displayName
        let letters = source
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map { String($0).uppercased() }
            .joined()

        return letters.isEmpty ? "A" : letters
    }
}

private let minimumBlockGapMinutes = 10

private func snapToFiveMinutes(_ minute: Int) -> Int {
    ((minute + 2) / 5) * 5
}

private func currencyString(_ value: Double) -> String {
    String(format: "$%.2f", value)
}

private enum DemoCalendar {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .current
        calendar.firstWeekday = 1
        return calendar
    }()

    static let referenceDate = makeDate(year: 2026, month: 5, day: 20)
    static let referenceMoment = makeDate(year: 2026, month: 5, day: 20, hour: 12, minute: 55)
    static let monthSymbolsSundayFirst = ["S", "M", "T", "W", "T", "F", "S"]
    static let weekSymbolsMondayFirst = ["M", "T", "W", "T", "F", "S", "S"]

    static func makeDate(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: components) ?? Date()
    }

    static func makeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
        return calendar.date(from: components) ?? Date()
    }

    static func startOfMonth(of date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }

    static func startOfWeek(containing date: Date) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: startOfDay)
        let daysSinceMonday = (weekday + 5) % 7
        return calendar.date(byAdding: .day, value: -daysSinceMonday, to: startOfDay) ?? startOfDay
    }

    static func weekDays(containing date: Date) -> [ScheduleWeekDay] {
        let weekStart = startOfWeek(containing: date)
        return (0..<7).compactMap { offset in
            guard let dayDate = calendar.date(byAdding: .day, value: offset, to: weekStart) else {
                return nil
            }

            return ScheduleWeekDay(
                index: recurringDayIndex(for: dayDate),
                date: dayDate,
                symbol: weekSymbolsMondayFirst[offset],
                dateNumber: String(calendar.component(.day, from: dayDate)),
                title: dayTitle(for: dayDate)
            )
        }
    }

    static func monthDays(containing date: Date) -> [ScheduleMonthDay] {
        let monthStart = startOfMonth(of: date)
        let weekday = calendar.component(.weekday, from: monthStart)
        let leadingDays = weekday - 1
        let gridStart = calendar.date(byAdding: .day, value: -leadingDays, to: monthStart) ?? monthStart
        let displayedMonth = calendar.component(.month, from: monthStart)

        return (0..<42).compactMap { offset in
            guard let dayDate = calendar.date(byAdding: .day, value: offset, to: gridStart) else {
                return nil
            }

            return ScheduleMonthDay(
                date: dayDate,
                dayNumber: String(calendar.component(.day, from: dayDate)),
                isInDisplayedMonth: calendar.component(.month, from: dayDate) == displayedMonth
            )
        }
    }

    static func recurringDayIndex(for date: Date) -> Int {
        let weekday = calendar.component(.weekday, from: date)
        return (weekday + 5) % 7
    }

    static func dayTitle(for date: Date) -> String {
        let weekdaySymbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let monthSymbols = [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ]
        let weekday = weekdaySymbols[calendar.component(.weekday, from: date) - 1]
        let month = monthSymbols[calendar.component(.month, from: date) - 1]
        let day = calendar.component(.day, from: date)
        return "\(weekday), \(month) \(day)"
    }

    static func navigationTitle(for date: Date) -> String {
        dayTitle(for: date)
    }

    static func monthTitle(for date: Date) -> String {
        let monthSymbols = [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ]
        let month = monthSymbols[calendar.component(.month, from: date) - 1]
        let year = calendar.component(.year, from: date)
        return "\(month) \(year)"
    }

    static func shiftedMonth(from date: Date, offset: Int) -> Date {
        calendar.date(byAdding: .month, value: offset, to: date) ?? date
    }

    static func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        calendar.isDate(lhs, inSameDayAs: rhs)
    }

    static func dayKey(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }
}

private func blocksOverlap(
    startMinute: Int,
    durationMinutes: Int,
    otherStartMinute: Int,
    otherDurationMinutes: Int
) -> Bool {
    let endMinute = startMinute + durationMinutes
    let otherEndMinute = otherStartMinute + otherDurationMinutes

    return startMinute < otherEndMinute + minimumBlockGapMinutes &&
        otherStartMinute < endMinute + minimumBlockGapMinutes
}

private struct DragPreviewState {
    let minute: Int
    let isBlocked: Bool
}

private enum ScheduleTemporalState: Equatable {
    case completed
    case inProgress
    case upcoming

    var title: String {
        switch self {
        case .completed: return "Completed"
        case .inProgress: return "In Progress"
        case .upcoming: return "Upcoming"
        }
    }

    var description: String {
        switch self {
        case .completed:
            return "This trip has already finished. Past trips stay locked so dispatch history stays intact."
        case .inProgress:
            return "This trip is already underway. Active trips cannot be moved."
        case .upcoming:
            return "This trip is still ahead. Turn on Edit mode if you want to reschedule it."
        }
    }

    var accent: Color {
        switch self {
        case .completed: return Theme.inkSoft
        case .inProgress: return Theme.blue
        case .upcoming: return Theme.green
        }
    }
}

private enum DecisionPanelDetent: Equatable {
    case collapsed
    case compact
    case expanded

    var cardHeight: CGFloat {
        switch self {
        case .collapsed: return 28
        case .compact: return 226
        case .expanded: return 344
        }
    }

    var boardBonus: CGFloat {
        switch self {
        case .collapsed: return 164
        case .compact: return 82
        case .expanded: return 0
        }
    }

    var boardSoftMax: CGFloat {
        switch self {
        case .collapsed: return 500
        case .compact: return 410
        case .expanded: return 320
        }
    }

    var boardReserve: CGFloat {
        switch self {
        case .collapsed: return 18
        case .compact: return 138
        case .expanded: return 232
        }
    }

    var hiddenOffset: CGFloat {
        switch self {
        case .collapsed: return 92
        case .compact, .expanded: return 0
        }
    }
}

private enum DispatchAvailabilityState: Equatable {
    case open
    case waitlist
    case blocked

    var title: String {
        switch self {
        case .open: return "Open"
        case .waitlist: return "Waitlist"
        case .blocked: return "Blocked"
        }
    }

    var description: String {
        switch self {
        case .open:
            return "A vehicle is free in this window. The trip can lock in immediately."
        case .waitlist:
            return "No vehicle is free right now, but this slot can wait for another rider to cancel."
        case .blocked:
            return "Fleet capacity is fully consumed here. Move the block to a different time."
        }
    }

    var accent: Color {
        switch self {
        case .open: return Theme.green
        case .waitlist: return Theme.dispatchYellow
        case .blocked: return Theme.dispatchRed
        }
    }

    var fill: Color {
        switch self {
        case .open: return Theme.greenSoft
        case .waitlist: return Theme.dispatchYellowSoft
        case .blocked: return Theme.dispatchRedSoft
        }
    }
}

private struct DispatchWindow: Identifiable {
    let id: String
    let startMinute: Int
    let endMinute: Int
    let state: DispatchAvailabilityState
}

private struct DispatchScenario: Identifiable, Equatable {
    let id: String
    let title: String
    let from: String
    let to: String
    let requestedStartMinute: Int
    let estimatedDurationMinutes: Int
    let riderSummary: String
}

private enum DispatchSubmissionState: Equatable {
    case lockedIn(startMinute: Int)
    case waitlisted(startMinute: Int)

    var title: String {
        switch self {
        case .lockedIn: return "Locked In"
        case .waitlisted: return "Waitlisted"
        }
    }
}

private enum DemoContent {
    static let policyRatePerMile = 2.00

    static let weekDays = DemoCalendar.weekDays(containing: DemoCalendar.referenceDate)

    static let plans = [
        PlanOption(id: 0, miles: 0, weeklyPrice: 0, extraMilePrice: policyRatePerMile, badge: "Per mile"),
        PlanOption(id: 20, miles: 20, weeklyPrice: 36, extraMilePrice: 1.80, badge: nil),
        PlanOption(id: 50, miles: 50, weeklyPrice: 75, extraMilePrice: 1.50, badge: "Most Popular"),
        PlanOption(id: 100, miles: 100, weeklyPrice: 135, extraMilePrice: 1.35, badge: nil),
    ]

    static let morningTrip = ScheduledTrip(
        id: "home-office",
        route: "Home → Office",
        from: "Home",
        to: "Office",
        dayLine: "Wed, May 20, 2026",
        timeWindow: "8:00 AM – 8:30 AM",
        timeShort: "8:00 AM – 8:30 AM",
        startHour: 8,
        startMinuteOfDay: 8 * 60,
        durationMinutes: 30,
        miles: 12,
        pickup: "101 Cedar Ave",
        dropoff: "600 Market St",
        status: .onTime,
        tint: Theme.scheduleBlue
    )

    static let middayTrip = ScheduledTrip(
        id: "office-gym",
        route: "Office → Gym",
        from: "Office",
        to: "Gym",
        dayLine: "Wed, May 20, 2026",
        timeWindow: "12:15 PM – 12:45 PM",
        timeShort: "12:15 PM – 12:45 PM",
        startHour: 12,
        startMinuteOfDay: 12 * 60 + 15,
        durationMinutes: 30,
        miles: 7,
        pickup: "Market St & 5th St",
        dropoff: "Gym, Howard St",
        status: .onTime,
        tint: Theme.scheduleMint
    )

    static let eveningTrip = ScheduledTrip(
        id: "office-home",
        route: "Gym → Home",
        from: "Office",
        to: "Home",
        dayLine: "Wed, May 20, 2026",
        timeWindow: "5:30 PM – 6:00 PM",
        timeShort: "5:30 PM – 6:00 PM",
        startHour: 17,
        startMinuteOfDay: 17 * 60 + 30,
        durationMinutes: 30,
        miles: 9,
        pickup: "Market St & 5th St",
        dropoff: "123 Main St",
        status: .upcoming,
        tint: Theme.scheduleLavender
    )

    static let trips = [morningTrip, middayTrip, eveningTrip]

    static let customerScenario = DispatchScenario(
        id: "customer-trip",
        title: "Your Trip",
        from: "Office",
        to: "SoMa",
        requestedStartMinute: 13 * 60 + 10,
        estimatedDurationMinutes: 30,
        riderSummary: "2 riders, short downtown hop"
    )

    static let scheduleBlocks = [
        ScheduleBlock(
            id: "home-office-block",
            dayIndex: 2,
            from: "Home",
            to: "Office",
            startMinuteOfDay: 8 * 60,
            durationMinutes: 30,
            detail: "Morning commute · 1 rider"
        ),
        ScheduleBlock(
            id: "office-gym-block",
            dayIndex: 2,
            from: "Office",
            to: "Gym",
            startMinuteOfDay: 12 * 60 + 15,
            durationMinutes: 30,
            detail: "Workout run · 1 rider"
        ),
        ScheduleBlock(
            id: "customer-trip-block",
            dayIndex: 2,
            from: "Office",
            to: "SoMa",
            startMinuteOfDay: 13 * 60 + 10,
            durationMinutes: 30,
            detail: "2 riders, short downtown hop"
        ),
        ScheduleBlock(
            id: "gym-home-block",
            dayIndex: 2,
            from: "Gym",
            to: "Home",
            startMinuteOfDay: 17 * 60 + 30,
            durationMinutes: 30,
            detail: "Evening return · 1 rider"
        ),
    ]

    static let routeQuotes = [
        RouteQuote(id: "home-office", from: "Home", to: "Office", miles: 12, durationMinutes: 30),
        RouteQuote(id: "office-home", from: "Office", to: "Home", miles: 12, durationMinutes: 35),
        RouteQuote(id: "office-gym", from: "Office", to: "Gym", miles: 7, durationMinutes: 30),
        RouteQuote(id: "gym-home", from: "Gym", to: "Home", miles: 9, durationMinutes: 30),
        RouteQuote(id: "office-soma", from: "Office", to: "SoMa", miles: 6, durationMinutes: 30),
        RouteQuote(id: "home-airport", from: "Home", to: "Airport", miles: 18, durationMinutes: 45),
        RouteQuote(id: "office-airport", from: "Office", to: "Airport", miles: 14, durationMinutes: 40),
    ]

    static let accountProfile = AccountProfile(
        fullName: "Alex Morgan",
        preferredName: "Alex",
        phoneNumber: "(415) 555-0188",
        email: "alex.morgan@roamingos.com",
        homeAddress: "123 Main St, Apt 8B",
        workAddress: "600 Market St, Floor 12",
        emergencyContactName: "Jordan Morgan",
        emergencyContactPhone: "(415) 555-0110",
        memberSince: "May 2026",
        planName: "50 miles / week",
        milesRemaining: 32.6,
        weeklyPlanMiles: 50,
        paymentMethod: "Visa •••• 4242",
        businessProfile: "RoamingOS HQ",
        riderRating: 4.98,
        tripCount: 128,
        notificationsEnabled: true,
        lockInAlertsEnabled: true,
        promoEmailsEnabled: false
    )

    static let dispatchWindows = [
        DispatchWindow(id: "open-early", startMinute: 7 * 60, endMinute: 9 * 60 + 10, state: .open),
        DispatchWindow(id: "blocked-commute", startMinute: 9 * 60 + 10, endMinute: 10 * 60 + 25, state: .blocked),
        DispatchWindow(id: "waitlist-late-morning", startMinute: 10 * 60 + 25, endMinute: 11 * 60 + 5, state: .waitlist),
        DispatchWindow(id: "open-midday", startMinute: 11 * 60 + 5, endMinute: 13 * 60 + 35, state: .open),
        DispatchWindow(id: "blocked-afternoon", startMinute: 13 * 60 + 35, endMinute: 15 * 60, state: .blocked),
        DispatchWindow(id: "open-shoulder", startMinute: 15 * 60, endMinute: 16 * 60 + 20, state: .open),
        DispatchWindow(id: "waitlist-evening", startMinute: 16 * 60 + 20, endMinute: 17 * 60 + 20, state: .waitlist),
        DispatchWindow(id: "blocked-lockin", startMinute: 17 * 60 + 20, endMinute: 18 * 60, state: .blocked),
        DispatchWindow(id: "open-evening", startMinute: 18 * 60, endMinute: 19 * 60 + 20, state: .open),
        DispatchWindow(id: "waitlist-dinner", startMinute: 19 * 60 + 20, endMinute: 20 * 60 + 20, state: .waitlist),
        DispatchWindow(id: "blocked-prime", startMinute: 20 * 60 + 20, endMinute: 21 * 60, state: .blocked),
        DispatchWindow(id: "open-late", startMinute: 21 * 60, endMinute: 22 * 60 + 30, state: .open),
        DispatchWindow(id: "blocked-close", startMinute: 22 * 60 + 30, endMinute: 23 * 60, state: .blocked),
    ]
}

private extension ScheduledTrip {
    var endMinuteOfDay: Int {
        startMinuteOfDay + durationMinutes
    }

    var lateCancelPenaltyMiles: Double {
        Double(miles) / 2
    }

    var lateCancelPenaltyLabel: String {
        String(format: "%.1f miles", lateCancelPenaltyMiles)
    }
}

struct RootTabView: View {
    @State private var screen: AppScreen = .home
    @State private var selectedTrip: ScheduledTrip = DemoContent.eveningTrip
    @State private var tripDetailBackTarget: AppScreen = .schedule
    @State private var selectedPlanID = 50

    var body: some View {
        ZStack {
            Theme.canvas.ignoresSafeArea()

            switch screen {
            case .home:
                HomeScreen(
                    selectedPlanID: selectedPlanID,
                    selectTab: { tab in
                        navigate(to: tab)
                    }
                )
            case .plan:
                PlanScreen(
                    selectedPlanID: $selectedPlanID,
                    back: { screen = .home },
                    continueAction: { screen = .schedule }
                )
            case .schedule:
                ScheduleScreen(
                    selectedPlanID: selectedPlanID,
                    openTrip: { trip in
                        selectedTrip = trip
                        tripDetailBackTarget = .schedule
                        screen = .tripDetail
                    },
                    selectTab: { tab in
                        navigate(to: tab)
                    }
                )
            case .trip:
                TripScreen(
                    trip: DemoContent.eveningTrip,
                    back: { screen = .home },
                    openTripDetail: {
                        selectedTrip = DemoContent.eveningTrip
                        tripDetailBackTarget = .trip
                        screen = .tripDetail
                    },
                    selectTab: { tab in
                        navigate(to: tab)
                    }
                )
            case .tripDetail:
                TripDetailScreen(
                    trip: selectedTrip,
                    back: { screen = tripDetailBackTarget },
                    cancelTrip: { screen = tripDetailBackTarget }
                )
            case .profile:
                ProfileScreen(
                    selectedPlanID: selectedPlanID,
                    selectTab: { tab in
                        navigate(to: tab)
                    }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func navigate(to tab: NavTab) {
        switch tab {
        case .home:
            screen = .home
        case .trips:
            screen = .trip
        case .schedule:
            screen = .schedule
        case .plan:
            screen = .plan
        case .profile:
            screen = .profile
        }
    }
}

private struct HomeScreen: View {
    let selectedPlanID: Int
    let selectTab: (NavTab) -> Void

    @State private var hasAnimatedIn = false

    private var selectedPlan: PlanOption {
        DemoContent.plans.first(where: { $0.id == selectedPlanID }) ?? DemoContent.plans[1]
    }

    var body: some View {
        PhoneScaffold(
            bottom: {
                StandardBottomBar(selected: .home, action: selectTab)
            }
        ) {
            VStack(spacing: 18) {
                HStack(alignment: .center) {
                    Text("Good morning, Alex")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.ink)

                    Spacer(minLength: 0)

                    HeaderIcon(symbol: "bell", action: { })
                }
                .opacity(hasAnimatedIn ? 1 : 0)
                .offset(y: hasAnimatedIn ? 0 : 10)
                .animation(.easeOut(duration: 0.32), value: hasAnimatedIn)

                PlanSummaryCard(plan: selectedPlan, action: { selectTab(.plan) })
                    .opacity(hasAnimatedIn ? 1 : 0)
                    .scaleEffect(hasAnimatedIn ? 1 : 0.97)
                    .offset(y: hasAnimatedIn ? 0 : 16)
                    .animation(.spring(response: 0.52, dampingFraction: 0.86).delay(0.06), value: hasAnimatedIn)

                MilesBalanceCard(plan: selectedPlan)
                    .opacity(hasAnimatedIn ? 1 : 0)
                    .offset(y: hasAnimatedIn ? 0 : 18)
                    .animation(.easeOut(duration: 0.34).delay(0.12), value: hasAnimatedIn)

                TripsThisWeekCard()
                    .opacity(hasAnimatedIn ? 1 : 0)
                    .offset(y: hasAnimatedIn ? 0 : 18)
                    .animation(.easeOut(duration: 0.34).delay(0.18), value: hasAnimatedIn)

                FutureBannerCard {
                    selectTab(.schedule)
                }
                    .opacity(hasAnimatedIn ? 1 : 0)
                    .scaleEffect(hasAnimatedIn ? 1 : 0.985)
                    .offset(y: hasAnimatedIn ? 0 : 20)
                    .animation(.spring(response: 0.55, dampingFraction: 0.88).delay(0.24), value: hasAnimatedIn)
            }
        }
        .onAppear {
            guard !hasAnimatedIn else { return }
            hasAnimatedIn = true
        }
    }
}

private struct PlanScreen: View {
    @Binding var selectedPlanID: Int
    let back: () -> Void
    let continueAction: () -> Void

    var body: some View {
        PhoneScaffold(
            navigation: .init(
                title: "Choose Your Plan",
                leadingSymbol: "chevron.left",
                leadingAction: back,
                trailingSymbol: "bell",
                trailingAction: { }
            ),
            bottom: {
                FooterButton(title: "Continue", action: continueAction)
            }
        ) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Choose how you want to ride.")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    Text("Trip Policy is charged at $2.00 per mile. Weekly plans lower the mileage rate.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.inkSoft)
                }

                VStack(spacing: 12) {
                    ForEach(DemoContent.plans) { plan in
                        PlanCard(
                            plan: plan,
                            isSelected: selectedPlanID == plan.id,
                            highlightAsPopular: plan.id == 50
                        ) {
                            selectedPlanID = plan.id
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    PlanFootnote(icon: "checkmark.shield", text: "Guaranteed rides before lock-in time")
                    PlanFootnote(icon: "checkmark.circle", text: "Edit at no cost before 13:59")
                    PlanFootnote(icon: "clock", text: "Late edit costs half total miles")
                }
                .padding(.top, 4)
            }
        }
    }
}

private struct ScheduleScreen: View {
    let selectedPlanID: Int
    let openTrip: (ScheduledTrip) -> Void
    let selectTab: (NavTab) -> Void

    @State private var scheduleBlocks = DemoContent.scheduleBlocks
    @State private var selectedBlockID = DemoContent.scheduleBlocks[2].id
    @State private var submissionStates: [String: DispatchSubmissionState] = [:]
    @State private var selectedDate = DemoCalendar.referenceDate
    @State private var isBookingSheetPresented = false
    @State private var highlightedSubmissionBlockID: String?
    @State private var isMonthOverviewExpanded = true
    @State private var decisionPanelDetent: DecisionPanelDetent = .compact
    @State private var isScheduleEditing = false

    private var selectedPlan: PlanOption {
        DemoContent.plans.first(where: { $0.id == selectedPlanID }) ?? DemoContent.plans[2]
    }

    var body: some View {
        PhoneScaffold(
            navigation: .init(
                title: DemoCalendar.navigationTitle(for: selectedDate),
                subtitleSymbol: "chevron.down",
                trailingSymbol: "calendar.badge.plus",
                trailingAction: { isBookingSheetPresented = true }
            ),
            scrollEnabled: false,
            bottom: {
                StandardBottomBar(selected: .schedule, action: selectTab)
            }
        ) {
            GeometryReader { proxy in
                let selectedBlock = selectedBlock
                let panelReserve = selectedBlock == nil ? 0 : decisionPanelDetent.boardReserve
                let boardSoftMax = selectedBlock == nil ? CGFloat(410) : decisionPanelDetent.boardSoftMax
                let overviewReserve = isMonthOverviewExpanded ? CGFloat(228) : CGFloat(98)
                let boardHeight = max(min(proxy.size.height - overviewReserve - panelReserve, boardSoftMax), 220)

                ZStack(alignment: .bottom) {
                    VStack(spacing: 12) {
                        MonthOverviewCard(
                            selectedDate: selectedDate,
                            monthDays: DemoCalendar.monthDays(containing: selectedDate),
                            bookingCountForDate: bookingCount(for:),
                            isExpanded: isMonthOverviewExpanded,
                            selectDate: selectDate,
                            shiftMonth: shiftSelectedMonth,
                            toggleExpanded: {
                                withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                                    isMonthOverviewExpanded.toggle()
                                }
                            }
                        )

                        WeekHeaderStrip(
                            days: selectedWeekDays,
                            selectedDate: selectedDate
                        ) { date in
                            selectDate(date)
                        }

                        DispatchTimelineBoard(
                            blocks: selectedDayBlocks,
                            windows: DemoContent.dispatchWindows,
                            selectedDate: selectedDate,
                            currentMoment: DemoCalendar.referenceMoment,
                            selectedBlockID: selectedBlockID,
                            highlightedBlockID: highlightedSubmissionBlockID,
                            submissionStates: submissionStates,
                            isEditingEnabled: isScheduleEditing,
                            boardHeight: boardHeight,
                            canEditBlock: canEditBlock,
                            selectBlock: { blockID in
                                selectedBlockID = blockID
                                if decisionPanelDetent == .collapsed {
                                    withAnimation(.smooth(duration: 0.22, extraBounce: 0)) {
                                        decisionPanelDetent = .compact
                                    }
                                }
                            },
                            previewStateForBlock: { blockID, minute in
                                previewState(for: blockID, proposedMinute: minute)
                            },
                            updateBlockStart: { blockID, minute in
                                updateBlockStart(blockID: blockID, minute: minute)
                            },
                            clearSubmissionState: { blockID in
                                submissionStates.removeValue(forKey: blockID)
                            }
                        )

                        if selectedBlock == nil {
                            ScheduleEmptyStateCard(dayTitle: DemoCalendar.dayTitle(for: selectedDate)) {
                                isBookingSheetPresented = true
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                    if let selectedBlock {
                        DispatchDecisionCard(
                            block: selectedBlock,
                            availability: currentAvailability,
                            submissionState: currentSubmissionState,
                            isPulsing: highlightedSubmissionBlockID == selectedBlock.id,
                            suggestedStartMinutes: suggestedStartMinutes,
                            timingState: temporalState(for: selectedBlock),
                            isEditingEnabled: isScheduleEditing,
                            canEnterEditMode: hasEditableBlocksOnSelectedDate,
                            detent: $decisionPanelDetent,
                            toggleEditing: {
                                withAnimation(.smooth(duration: 0.22, extraBounce: 0)) {
                                    isScheduleEditing.toggle()
                                }
                            },
                            selectSuggestedStart: { minute in
                                updateBlockStart(blockID: selectedBlock.id, minute: minute)
                                submissionStates.removeValue(forKey: selectedBlock.id)
                            },
                            primaryAction: handlePrimaryAction
                        )
                        .offset(y: decisionPanelDetent.hiddenOffset)
                        .opacity(decisionPanelDetent == .collapsed ? 0.001 : 1)
                        .allowsHitTesting(decisionPanelDetent != .collapsed)
                        .padding(.bottom, 4)
                        .zIndex(1)

                        if decisionPanelDetent == .collapsed {
                            CollapsedDecisionHandle(reopen: {
                                withAnimation(.smooth(duration: 0.22, extraBounce: 0)) {
                                    decisionPanelDetent = .compact
                                }
                            })
                            .padding(.bottom, 6)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .zIndex(2)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isBookingSheetPresented) {
            TripBookingSheet(initialSelectedDayIndex: selectedWeekdayIndex, selectedPlan: selectedPlan) { request, route in
                reserveTrip(request: request, route: route)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            syncSelectedBlock(for: selectedWeekdayIndex)
        }
    }

    private var selectedWeekDays: [ScheduleWeekDay] {
        DemoCalendar.weekDays(containing: selectedDate)
    }

    private var selectedWeekdayIndex: Int {
        DemoCalendar.recurringDayIndex(for: selectedDate)
    }

    private var selectedDayBlocks: [ScheduleBlock] {
        scheduleBlocks
            .filter { $0.dayIndex == selectedWeekdayIndex }
            .sorted { $0.startMinuteOfDay < $1.startMinuteOfDay }
    }

    private var selectedBlock: ScheduleBlock? {
        selectedDayBlocks.first(where: { $0.id == selectedBlockID }) ?? selectedDayBlocks.first
    }

    private var currentAvailability: DispatchAvailabilityState {
        guard let selectedBlock else { return .open }
        return availability(for: selectedBlock.startMinuteOfDay)
    }

    private var currentSubmissionState: DispatchSubmissionState? {
        guard let selectedBlock else { return nil }
        return submissionStates[selectedBlock.id]
    }

    private var hasEditableBlocksOnSelectedDate: Bool {
        selectedDayBlocks.contains { isEditableCandidate($0) }
    }

    private var suggestedStartMinutes: [Int] {
        guard let selectedBlock else { return [] }
        guard isScheduleEditing, canEditBlock(selectedBlock) else { return [] }
        let preferredStates: [DispatchAvailabilityState]
        switch currentAvailability {
        case .open:
            return []
        case .waitlist:
            preferredStates = [.open]
        case .blocked:
            preferredStates = [.open, .waitlist]
        }

        var starts: [Int] = []
        for window in DemoContent.dispatchWindows where preferredStates.contains(window.state) {
            let latestStart = window.endMinute - selectedBlock.durationMinutes
            guard latestStart >= window.startMinute else { continue }

            let candidate = min(snapToFiveMinutes(window.startMinute), latestStart)
            guard candidate != selectedBlock.startMinuteOfDay else { continue }

            if !starts.contains(candidate) {
                starts.append(candidate)
            }

            if starts.count == 3 {
                break
            }
        }

        return starts
    }

    private func availability(for startMinute: Int) -> DispatchAvailabilityState {
        DemoContent.dispatchWindows.first(where: { startMinute >= $0.startMinute && startMinute < $0.endMinute })?.state ?? .blocked
    }

    private func bookingCount(for date: Date) -> Int {
        let weekdayIndex = DemoCalendar.recurringDayIndex(for: date)
        return scheduleBlocks.filter { $0.dayIndex == weekdayIndex }.count
    }

    private func temporalState(for block: ScheduleBlock) -> ScheduleTemporalState {
        if selectedDate < DemoCalendar.calendar.startOfDay(for: DemoCalendar.referenceDate) {
            return .completed
        }

        if selectedDate > DemoCalendar.calendar.startOfDay(for: DemoCalendar.referenceDate) {
            return .upcoming
        }

        let currentMinute = DemoTimeFormatter.minuteOfDay(from: DemoCalendar.referenceMoment)
        let endMinute = block.startMinuteOfDay + block.durationMinutes

        if endMinute <= currentMinute {
            return .completed
        }

        if block.startMinuteOfDay <= currentMinute {
            return .inProgress
        }

        return .upcoming
    }

    private func canEditBlock(_ block: ScheduleBlock) -> Bool {
        isScheduleEditing && isEditableCandidate(block)
    }

    private func isEditableCandidate(_ block: ScheduleBlock) -> Bool {
        temporalState(for: block) == .upcoming
    }

    private func selectDate(_ date: Date) {
        selectedDate = date
        decisionPanelDetent = .compact
        isScheduleEditing = false
        syncSelectedBlock(for: DemoCalendar.recurringDayIndex(for: date))
    }

    private func shiftSelectedMonth(_ monthOffset: Int) {
        let shiftedDate = DemoCalendar.shiftedMonth(from: selectedDate, offset: monthOffset)
        selectedDate = shiftedDate
        decisionPanelDetent = .compact
        isScheduleEditing = false
        syncSelectedBlock(for: DemoCalendar.recurringDayIndex(for: shiftedDate))
    }

    private func handlePrimaryAction() {
        guard let selectedBlock else { return }
        guard temporalState(for: selectedBlock) == .upcoming else { return }
        switch currentAvailability {
        case .open:
            withAnimation(.spring(response: 0.3, dampingFraction: 0.84)) {
                submissionStates[selectedBlock.id] = .lockedIn(startMinute: selectedBlock.startMinuteOfDay)
            }
            triggerSubmissionPulse(for: selectedBlock.id)
        case .waitlist:
            withAnimation(.spring(response: 0.3, dampingFraction: 0.84)) {
                submissionStates[selectedBlock.id] = .waitlisted(startMinute: selectedBlock.startMinuteOfDay)
            }
            triggerSubmissionPulse(for: selectedBlock.id)
        case .blocked:
            break
        }
    }

    private func updateBlockStart(blockID: String, minute: Int) {
        guard let index = scheduleBlocks.firstIndex(where: { $0.id == blockID }) else { return }
        let movingBlock = scheduleBlocks[index]
        guard canEditBlock(movingBlock) else { return }
        scheduleBlocks[index].startMinuteOfDay = resolvedStartMinute(
            forDayIndex: movingBlock.dayIndex,
            durationMinutes: movingBlock.durationMinutes,
            proposedMinute: snapToFiveMinutes(minute),
            excludingBlockID: blockID
        )
    }

    private func triggerSubmissionPulse(for blockID: String) {
        highlightedSubmissionBlockID = blockID
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
            if highlightedSubmissionBlockID == blockID {
                withAnimation(.easeOut(duration: 0.22)) {
                    highlightedSubmissionBlockID = nil
                }
            }
        }
    }

    private func previewState(for blockID: String, proposedMinute: Int) -> DragPreviewState {
        guard let movingBlock = scheduleBlocks.first(where: { $0.id == blockID }) else {
            return DragPreviewState(minute: proposedMinute, isBlocked: false)
        }

        guard canEditBlock(movingBlock) else {
            return DragPreviewState(minute: movingBlock.startMinuteOfDay, isBlocked: true)
        }

        let timelineStartMinute = 7 * 60
        let timelineEndMinute = 23 * 60
        let latestStartMinute = timelineEndMinute - movingBlock.durationMinutes
        let clampedMinute = min(max(proposedMinute, timelineStartMinute), latestStartMinute)
        let originMinute = movingBlock.startMinuteOfDay

        guard clampedMinute != originMinute else {
            return DragPreviewState(minute: originMinute, isBlocked: false)
        }

        let otherBlocks = blocksForCollision(dayIndex: movingBlock.dayIndex, excludingBlockID: blockID)

        if clampedMinute > originMinute {
            var previewMinute = originMinute
            var remainingShift = clampedMinute - originMinute

            for otherBlock in otherBlocks {
                let blockedStart = otherBlock.startMinuteOfDay - movingBlock.durationMinutes - minimumBlockGapMinutes + 1
                let blockedEnd = otherBlock.startMinuteOfDay + otherBlock.durationMinutes + minimumBlockGapMinutes - 1
                let lastAllowedBefore = blockedStart - 1

                guard blockedEnd > previewMinute else { continue }

                let freeGap = max(0, blockedStart - previewMinute)
                if remainingShift < freeGap {
                    return DragPreviewState(
                        minute: min(previewMinute + remainingShift, latestStartMinute),
                        isBlocked: false
                    )
                }

                remainingShift -= freeGap
                let blockedWidth = blockedEnd - blockedStart

                if remainingShift < blockedWidth {
                    return DragPreviewState(
                        minute: min(max(lastAllowedBefore, timelineStartMinute), latestStartMinute),
                        isBlocked: true
                    )
                }

                remainingShift -= blockedWidth
                previewMinute = blockedEnd
            }

            return DragPreviewState(
                minute: min(previewMinute + remainingShift, latestStartMinute),
                isBlocked: false
            )
        }

        var previewMinute = originMinute
        var remainingShift = originMinute - clampedMinute

        for otherBlock in otherBlocks.reversed() {
            let blockedStart = otherBlock.startMinuteOfDay - movingBlock.durationMinutes - minimumBlockGapMinutes + 1
            let blockedEnd = otherBlock.startMinuteOfDay + otherBlock.durationMinutes + minimumBlockGapMinutes - 1
            let firstAllowedAfter = blockedEnd + 1

            guard blockedStart < previewMinute else { continue }

            let freeGap = max(0, previewMinute - blockedEnd)
            if remainingShift < freeGap {
                return DragPreviewState(
                    minute: max(previewMinute - remainingShift, timelineStartMinute),
                    isBlocked: false
                )
            }

            remainingShift -= freeGap
            let blockedWidth = blockedEnd - blockedStart

            if remainingShift < blockedWidth {
                return DragPreviewState(
                    minute: max(min(firstAllowedAfter, latestStartMinute), timelineStartMinute),
                    isBlocked: true
                )
            }

            remainingShift -= blockedWidth
            previewMinute = blockedStart
        }

        return DragPreviewState(
            minute: max(previewMinute - remainingShift, timelineStartMinute),
            isBlocked: false
        )
    }

    private func resolvedStartMinute(for blockID: String, proposedMinute: Int) -> Int {
        guard let movingBlock = scheduleBlocks.first(where: { $0.id == blockID }) else {
            return proposedMinute
        }

        return resolvedStartMinute(
            forDayIndex: movingBlock.dayIndex,
            durationMinutes: movingBlock.durationMinutes,
            proposedMinute: proposedMinute,
            excludingBlockID: blockID
        )
    }

    private func resolvedStartMinute(
        forDayIndex dayIndex: Int,
        durationMinutes: Int,
        proposedMinute: Int,
        excludingBlockID: String? = nil
    ) -> Int {
        let timelineStartMinute = 7 * 60
        let timelineEndMinute = 23 * 60
        let latestStartMinute = timelineEndMinute - durationMinutes
        let otherBlocks = blocksForCollision(dayIndex: dayIndex, excludingBlockID: excludingBlockID)

        var resolved = min(max(snapToFiveMinutes(proposedMinute), timelineStartMinute), latestStartMinute)
        var attempts = 0

        while attempts < 12 {
            guard let overlappingBlock = otherBlocks.first(where: {
                blocksOverlap(
                    startMinute: resolved,
                    durationMinutes: durationMinutes,
                    otherStartMinute: $0.startMinuteOfDay,
                    otherDurationMinutes: $0.durationMinutes
                )
            }) else {
                return resolved
            }

            let beforeMinute = min(
                max(overlappingBlock.startMinuteOfDay - durationMinutes - minimumBlockGapMinutes, timelineStartMinute),
                latestStartMinute
            )
            let afterMinute = min(
                max(overlappingBlock.startMinuteOfDay + overlappingBlock.durationMinutes + minimumBlockGapMinutes, timelineStartMinute),
                latestStartMinute
            )

            let beforeDistance = abs(resolved - beforeMinute)
            let afterDistance = abs(afterMinute - resolved)

            resolved = beforeDistance <= afterDistance ? beforeMinute : afterMinute
            attempts += 1
        }

        return resolved
    }

    private func overlapsOtherBlocks(for blockID: String, proposedMinute: Int) -> Bool {
        guard let movingBlock = scheduleBlocks.first(where: { $0.id == blockID }) else {
            return false
        }

        return overlapsOtherBlocks(
            on: movingBlock.dayIndex,
            durationMinutes: movingBlock.durationMinutes,
            proposedMinute: proposedMinute,
            excludingBlockID: blockID
        )
    }

    private func overlapsOtherBlocks(
        on dayIndex: Int,
        durationMinutes: Int,
        proposedMinute: Int,
        excludingBlockID: String? = nil
    ) -> Bool {
        blocksForCollision(dayIndex: dayIndex, excludingBlockID: excludingBlockID)
            .contains {
                blocksOverlap(
                    startMinute: proposedMinute,
                    durationMinutes: durationMinutes,
                    otherStartMinute: $0.startMinuteOfDay,
                    otherDurationMinutes: $0.durationMinutes
                )
            }
    }

    private func blocksForCollision(dayIndex: Int, excludingBlockID: String? = nil) -> [ScheduleBlock] {
        scheduleBlocks
            .filter { block in
                block.dayIndex == dayIndex && block.id != excludingBlockID
            }
            .sorted { $0.startMinuteOfDay < $1.startMinuteOfDay }
    }

    private func syncSelectedBlock(for dayIndex: Int) {
        let dayBlocks = scheduleBlocks
            .filter { $0.dayIndex == dayIndex }
            .sorted { $0.startMinuteOfDay < $1.startMinuteOfDay }

        if dayBlocks.contains(where: { $0.id == selectedBlockID }) {
            return
        }

        selectedBlockID = dayBlocks.first?.id ?? ""
    }

    private func reserveTrip(request: TripBookingRequest, route: RouteQuote) {
        let selectedDays = request.dayIndices.sorted()
        guard !selectedDays.isEmpty else { return }

        var newBlocks: [ScheduleBlock] = []
        var newSubmissionStates = submissionStates

        for dayIndex in selectedDays {
            let resolvedMinute = resolvedStartMinute(
                forDayIndex: dayIndex,
                durationMinutes: route.durationMinutes,
                proposedMinute: request.departureMinute
            )

            let block = ScheduleBlock(
                id: "booking-\(UUID().uuidString)",
                dayIndex: dayIndex,
                from: request.from,
                to: request.to,
                startMinuteOfDay: resolvedMinute,
                durationMinutes: route.durationMinutes,
                detail: "\(route.miles) mi • \(weeklyRepeatLabel(for: selectedDays))"
            )

            newBlocks.append(block)
            newSubmissionStates[block.id] = .lockedIn(startMinute: resolvedMinute)
        }

        scheduleBlocks.append(contentsOf: newBlocks)
        submissionStates = newSubmissionStates

        let preferredDay = selectedDays.contains(selectedWeekdayIndex) ? selectedWeekdayIndex : selectedDays[0]
        if let preferredDate = selectedWeekDays.first(where: { $0.index == preferredDay })?.date {
            selectedDate = preferredDate
        }
        selectedBlockID = newBlocks.first(where: { $0.dayIndex == preferredDay })?.id ?? newBlocks[0].id
    }

    private func weeklyRepeatLabel(for dayIndices: [Int]) -> String {
        if dayIndices == [0, 1, 2, 3, 4] {
            return "weekdays"
        }

        return dayIndices
            .compactMap { index in
                DemoContent.weekDays.first(where: { $0.index == index })
            }
            .map(\.symbol)
            .joined(separator: "/")
    }
}

private struct TripScreen: View {
    let trip: ScheduledTrip
    let back: () -> Void
    let openTripDetail: () -> Void
    let selectTab: (NavTab) -> Void

    var body: some View {
        PhoneScaffold(
            navigation: .init(
                title: "Trip",
                leadingSymbol: "chevron.left",
                leadingAction: back
            ),
            bottom: {
                StandardBottomBar(selected: .trips, action: selectTab)
            }
        ) {
            VStack(spacing: 18) {
                ScheduledHeaderCard(trip: trip)
                GuaranteeWindowCard(compact: false)
                VehicleCard()

                OutlineButton(title: "View Trip Details", action: openTripDetail)

                LateEditCard()
            }
        }
    }
}

private struct TripDetailScreen: View {
    let trip: ScheduledTrip
    let back: () -> Void
    let cancelTrip: () -> Void

    @State private var isCancelConfirmationPresented = false

    var body: some View {
        ZStack(alignment: .bottom) {
            PhoneScaffold(
                navigation: .init(
                    title: "Trip Detail",
                    leadingSymbol: "chevron.left",
                    leadingAction: back,
                    trailingSymbol: "ellipsis",
                    trailingAction: { }
                ),
                bottom: {
                    Button(action: { isCancelConfirmationPresented = true }) {
                        SoftButton(title: "Cancel Trip", foreground: .red, background: Theme.screen, border: Theme.line)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 14)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                    .background(Theme.screen)
                }
            ) {
                VStack(spacing: 0) {
                    RouteMapCard()

                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 4) {
                                    Text("Office")
                                    Text("→")
                                    Text("Home")
                                }
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Theme.ink)

                                Text(trip.status.title)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Theme.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Theme.brandSoft))
                            }

                            Spacer(minLength: 0)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Wed, May 20, 2026")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Theme.ink)
                            HStack(alignment: .lastTextBaseline) {
                                Text("5:30 PM – 6:00 PM")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Theme.ink)
                                Spacer()
                                Text("9 mi")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Theme.ink)
                            }
                        }

                        DetailStopRow(color: Theme.green, title: "Pickup", location: "Market St & 5th St", time: "5:30 PM")
                        DetailStopRow(color: Theme.blue, title: "Drop-off", location: "123 Main St", time: "6:00 PM")

                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 12) {
                                DetailMeta(title: "Vehicle type", value: "RoamingOS Standard")
                                DetailMeta(title: "Passengers", value: "1")
                            }

                            Spacer(minLength: 0)

                            CarPhoto(variant: .rearThreeQuarter)
                                .frame(width: 92, height: 44)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Theme.screen)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Theme.line, lineWidth: 1)
                            )
                    )
                }

                GuaranteeWindowCard(compact: true)
                    .padding(.top, 14)
            }
            .disabled(isCancelConfirmationPresented)

            if isCancelConfirmationPresented {
                Color.black.opacity(0.18)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isCancelConfirmationPresented = false
                    }
                    .transition(.opacity)

                CancelTripConfirmationSheet(
                    trip: trip,
                    dismiss: { isCancelConfirmationPresented = false },
                    confirm: {
                        isCancelConfirmationPresented = false
                        cancelTrip()
                    }
                )
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.9), value: isCancelConfirmationPresented)
    }
}

private struct CancelTripConfirmationSheet: View {
    let trip: ScheduledTrip
    let dismiss: () -> Void
    let confirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Capsule()
                .fill(Theme.lineStrong)
                .frame(width: 42, height: 5)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 6) {
                Text("Cancel this trip?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Theme.ink)
                Text("Cancelling this reserved ride can release your guaranteed slot and may trigger a late cancel penalty.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 10) {
                CancelPolicyRow(
                    icon: "checkmark.circle.fill",
                    tint: Theme.green,
                    background: Theme.greenSoft,
                    title: "Before 13:59",
                    detail: "You can still cancel this trip at no cost before guaranteed lock-in time."
                )

                CancelPolicyRow(
                    icon: "clock.badge.exclamationmark.fill",
                    tint: Theme.orange,
                    background: Theme.peach,
                    title: "After lock-in",
                    detail: "Late cancel would cost \(trip.lateCancelPenaltyLabel), which is half of this trip's total miles."
                )

                CancelPolicyRow(
                    icon: "shield.slash.fill",
                    tint: Theme.dispatchYellow,
                    background: Theme.dispatchYellowSoft,
                    title: "Guaranteed slot is released",
                    detail: "If you book this time again later, it may come back as waitlist or unavailable."
                )
            }

            VStack(spacing: 10) {
                Button(action: confirm) {
                    Text("Confirm Cancel Trip")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Theme.dispatchRed)
                        )
                }
                .buttonStyle(.plain)

                Button(action: dismiss) {
                    Text("Keep Trip")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Theme.screen)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Theme.lineStrong, lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Theme.screen)
                .shadow(color: Theme.shadow.opacity(1.2), radius: 18, y: 8)
        )
    }
}

private struct CancelPolicyRow: View {
    let icon: String
    let tint: Color
    let background: Color
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(background)
                .frame(width: 34, height: 34)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(tint)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text(detail)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Theme.canvas)
        )
    }
}

private struct ProfileScreen: View {
    let selectedPlanID: Int
    let selectTab: (NavTab) -> Void

    @State private var profile = DemoContent.accountProfile
    @State private var isEditSheetPresented = false

    private var selectedPlan: PlanOption {
        DemoContent.plans.first(where: { $0.id == selectedPlanID }) ?? DemoContent.plans[1]
    }

    var body: some View {
        PhoneScaffold(
            navigation: .init(
                title: "Account",
                trailingSymbol: "square.and.pencil",
                trailingAction: { isEditSheetPresented = true }
            ),
            bottom: {
                StandardBottomBar(selected: .profile, action: selectTab)
            }
        ) {
            VStack(spacing: 14) {
                AccountHeroCard(profile: profile, planTitle: selectedPlan.accountPlanLabel) {
                    isEditSheetPresented = true
                }

                StatCard {
                    HStack {
                        MetricPair(value: String(format: "%.2f", profile.riderRating), label: "Rider rating")

                        Spacer(minLength: 16)

                        MetricPair(value: "\(profile.tripCount)", label: "Trips booked")

                        Spacer(minLength: 16)

                        MetricPair(
                            value: String(format: "%.1f mi", profile.milesRemaining),
                            label: "Miles left"
                        )
                    }
                }

                ProfileSectionCard(title: "Personal info", actionTitle: "Edit") {
                    isEditSheetPresented = true
                } content: {
                    VStack(spacing: 0) {
                        ProfileInfoRow(
                            icon: "person.text.rectangle",
                            title: "Legal name",
                            value: profile.fullName
                        )
                        ProfileSectionDivider()
                        ProfileInfoRow(
                            icon: "phone",
                            title: "Mobile number",
                            value: profile.phoneNumber
                        )
                        ProfileSectionDivider()
                        ProfileInfoRow(
                            icon: "envelope",
                            title: "Email",
                            value: profile.email
                        )
                        ProfileSectionDivider()
                        ProfileInfoRow(
                            icon: "shield.lefthalf.filled",
                            title: "Emergency contact",
                            value: "\(profile.emergencyContactName) • \(profile.emergencyContactPhone)"
                        )
                    }
                }

                ProfileSectionCard(title: "Saved places", actionTitle: "Manage") {
                    isEditSheetPresented = true
                } content: {
                    VStack(spacing: 0) {
                        ProfileInfoRow(
                            icon: "house",
                            title: "Home",
                            value: profile.homeAddress
                        )
                        ProfileSectionDivider()
                        ProfileInfoRow(
                            icon: "briefcase",
                            title: "Work",
                            value: profile.workAddress
                        )
                        ProfileSectionDivider()
                        ProfileInfoRow(
                            icon: "building.2",
                            title: "Business profile",
                            value: profile.businessProfile
                        )
                    }
                }

                ProfileSectionCard(title: "Preferences") {
                    VStack(spacing: 0) {
                        ProfileToggleRow(
                            icon: "bell.badge",
                            title: "Ride notifications",
                            subtitle: "Trip updates, arrivals, and receipts",
                            isOn: $profile.notificationsEnabled
                        )
                        ProfileSectionDivider()
                        ProfileToggleRow(
                            icon: "timer",
                            title: "Lock-in reminders",
                            subtitle: "Warn me before guaranteed lock-in time",
                            isOn: $profile.lockInAlertsEnabled
                        )
                        ProfileSectionDivider()
                        ProfileToggleRow(
                            icon: "megaphone",
                            title: "Product emails",
                            subtitle: "Promotions and new feature launches",
                            isOn: $profile.promoEmailsEnabled
                        )
                    }
                }

                ProfileSectionCard(title: "Wallet & support") {
                    VStack(spacing: 0) {
                        ProfileInfoRow(
                            icon: "creditcard",
                            title: "Payment method",
                            value: profile.paymentMethod
                        )
                        ProfileSectionDivider()
                        ProfileInfoRow(
                            icon: "doc.text",
                            title: "Trip receipts",
                            value: "Email + PDF backup"
                        )
                        ProfileSectionDivider()
                        ProfileInfoRow(
                            icon: "lock.shield",
                            title: "Privacy center",
                            value: "Face ID enabled"
                        )
                        ProfileSectionDivider()
                        ProfileInfoRow(
                            icon: "questionmark.circle",
                            title: "Help",
                            value: "24/7 priority support"
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $isEditSheetPresented) {
            ProfileEditSheet(profile: profile) { updatedProfile in
                profile = updatedProfile
            }
        }
    }
}

private struct AccountHeroCard: View {
    let profile: AccountProfile
    let planTitle: String
    let editAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                    Text(profile.initials)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 62, height: 62)

                VStack(alignment: .leading, spacing: 5) {
                    Text(profile.displayName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)

                    Text(profile.fullName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.72))

                    Text(profile.phoneNumber)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.94))

                    Text(profile.email)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer(minLength: 0)

                Label(String(format: "%.2f", profile.riderRating), systemImage: "star.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.white.opacity(0.14)))
            }

            HStack(spacing: 8) {
                ProfileBadgePill(title: planTitle)
                ProfileBadgePill(title: "Member since \(profile.memberSince)")
            }

            Button(action: editAction) {
                HStack(spacing: 8) {
                    Text("Edit personal info")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(Theme.brand)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Theme.brand, Color(hex: "1E478F")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

private struct ProfileBadgePill: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Capsule().fill(Color.white.opacity(0.14)))
    }
}

private struct ProfileSectionCard<Content: View>: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    @ViewBuilder let content: Content

    init(
        title: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
        self.content = content()
    }

    var body: some View {
        StatCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.ink)

                    Spacer(minLength: 0)

                    if let actionTitle, let action {
                        Button(actionTitle, action: action)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.brand)
                            .buttonStyle(.plain)
                    }
                }

                content
            }
        }
    }
}

private struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Theme.brandSoft)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.brand)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.inkSoft)

                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}

private struct ProfileToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Theme.brandSoft)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.brand)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.ink)

                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Theme.brand)
        }
    }
}

private struct ProfileSectionDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 48)
            .padding(.vertical, 12)
    }
}

private struct ProfileEditSheet: View {
    let onSave: (AccountProfile) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draftProfile: AccountProfile

    init(profile: AccountProfile, onSave: @escaping (AccountProfile) -> Void) {
        self.onSave = onSave
        _draftProfile = State(initialValue: profile)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    StatCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Personal details")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Theme.ink)

                            BookingField(title: "Preferred name", text: $draftProfile.preferredName, prompt: "How riders know you")
                            BookingField(title: "Full legal name", text: $draftProfile.fullName, prompt: "Name on account")
                            BookingField(title: "Mobile number", text: $draftProfile.phoneNumber, prompt: "Phone number")
                            BookingField(title: "Email", text: $draftProfile.email, prompt: "Email address")
                        }
                    }

                    StatCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Saved places")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Theme.ink)

                            BookingField(title: "Home", text: $draftProfile.homeAddress, prompt: "Home address")
                            BookingField(title: "Work", text: $draftProfile.workAddress, prompt: "Work address")
                            BookingField(title: "Business profile", text: $draftProfile.businessProfile, prompt: "Business profile name")
                        }
                    }

                    StatCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Safety & billing")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Theme.ink)

                            BookingField(title: "Emergency contact", text: $draftProfile.emergencyContactName, prompt: "Contact name")
                            BookingField(title: "Emergency phone", text: $draftProfile.emergencyContactPhone, prompt: "Contact phone")
                            BookingField(title: "Payment method", text: $draftProfile.paymentMethod, prompt: "Primary card")
                        }
                    }

                    StatCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notification settings")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Theme.ink)

                            ProfileToggleRow(
                                icon: "bell.badge",
                                title: "Ride notifications",
                                subtitle: "Trip progress, arrivals, and receipt delivery",
                                isOn: $draftProfile.notificationsEnabled
                            )
                            ProfileSectionDivider()
                            ProfileToggleRow(
                                icon: "timer",
                                title: "Lock-in reminders",
                                subtitle: "Remind me before guaranteed changes close",
                                isOn: $draftProfile.lockInAlertsEnabled
                            )
                            ProfileSectionDivider()
                            ProfileToggleRow(
                                icon: "megaphone",
                                title: "Product emails",
                                subtitle: "Beta launches and occasional offers",
                                isOn: $draftProfile.promoEmailsEnabled
                            )
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 16)
                .padding(.bottom, 18)
            }
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle("Edit Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.brand)
                }
            }
            .safeAreaInset(edge: .bottom) {
                FooterButton(title: "Save changes") {
                    onSave(draftProfile)
                    dismiss()
                }
            }
        }
    }
}

private struct PhoneScaffold<Content: View, Bottom: View>: View {
    let navigation: PhoneNavigation?
    let scrollEnabled: Bool
    @ViewBuilder let bottom: Bottom
    @ViewBuilder let content: Content

    init(
        navigation: PhoneNavigation? = nil,
        scrollEnabled: Bool = true,
        @ViewBuilder bottom: () -> Bottom,
        @ViewBuilder content: () -> Content
    ) {
        self.navigation = navigation
        self.scrollEnabled = scrollEnabled
        self.bottom = bottom()
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            if let navigation {
                NavigationHeader(navigation: navigation)
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
            }

            Group {
                if scrollEnabled {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            content
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, navigation == nil ? 12 : 4)
                        .padding(.bottom, 18)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        content
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, navigation == nil ? 12 : 4)
                    .padding(.bottom, 18)
                }
            }
        }
        .frame(maxWidth: 390, maxHeight: .infinity, alignment: .top)
        .background(Theme.screen)
        .safeAreaInset(edge: .bottom) {
            bottom
        }
    }
}

private struct PhoneNavigation {
    let title: String
    var subtitleSymbol: String? = nil
    var leadingSymbol: String? = nil
    var leadingAction: (() -> Void)? = nil
    var trailingSymbol: String? = nil
    var trailingAction: (() -> Void)? = nil
}

private struct NavigationHeader: View {
    let navigation: PhoneNavigation

    var body: some View {
        HStack {
            Group {
                if let leadingSymbol = navigation.leadingSymbol {
                    HeaderIcon(symbol: leadingSymbol, action: navigation.leadingAction ?? { })
                } else {
                    Color.clear.frame(width: 28, height: 28)
                }
            }

            Spacer(minLength: 0)

            HStack(spacing: 4) {
                Text(navigation.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.ink)

                if let subtitleSymbol = navigation.subtitleSymbol {
                    Image(systemName: subtitleSymbol)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                }
            }

            Spacer(minLength: 0)

            Group {
                if let trailingSymbol = navigation.trailingSymbol {
                    HeaderIcon(symbol: trailingSymbol, action: navigation.trailingAction ?? { })
                } else {
                    Color.clear.frame(width: 28, height: 28)
                }
            }
        }
        .frame(height: 28)
    }
}

private struct HeaderIcon: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Theme.ink)
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.plain)
    }
}

private struct StatCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Theme.screen)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Theme.line, lineWidth: 1)
                    )
                    .shadow(color: Theme.shadow, radius: 8, y: 4)
            )
    }
}

private struct PlanSummaryCard: View {
    let plan: PlanOption
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Your Plan")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))

            VStack(alignment: .leading, spacing: 6) {
                Text(plan.displayTitle)
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(.white)
                Text(plan.summaryLine)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.92))
            }

            HStack(alignment: .bottom) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(plan.displayPrice)
                        .font(.system(size: 19, weight: .bold))
                    Text(plan.billingSuffix)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .foregroundStyle(.white)

                Spacer(minLength: 0)

                Button(action: action) {
                    Text(plan.isTripPolicy ? "Manage Pricing" : "Manage Plan")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(.white.opacity(0.4), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.brand)
        )
    }
}

private struct MilesBalanceCard: View {
    let plan: PlanOption

    private var packageProgress: Double {
        0.652
    }

    private var remainingMiles: Double {
        Double(plan.miles) * packageProgress
    }

    private var usedMiles: Double {
        max(Double(plan.miles) - remainingMiles, 0)
    }

    var body: some View {
        StatCard {
            VStack(alignment: .leading, spacing: 10) {
                if plan.isTripPolicy {
                    Text("Trip pricing")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.inkSoft)

                    Text("\(currencyString(DemoContent.policyRatePerMile)) / mile")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.ink)

                    Text("No weekly mileage balance. You are charged only for the trips you book.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.inkSoft)
                } else {
                    Text("Miles Balance")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.inkSoft)

                    Text("\(remainingMiles, specifier: "%.1f") miles")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.ink)

                    MileageProgressBar(progress: packageProgress)

                    HStack {
                        Text("\(usedMiles, specifier: "%.1f") miles used")
                        Spacer()
                        Text("\(plan.miles) miles total")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.inkSoft)
                }
            }
        }
    }
}

private struct TripsThisWeekCard: View {
    var body: some View {
        StatCard {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Trips This Week")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.inkSoft)

                    HStack(spacing: 22) {
                        MetricPair(value: "3", label: "Completed")
                        MetricPair(value: "2", label: "Upcoming")
                    }
                }

                Spacer(minLength: 0)

                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Theme.orangeSoft)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Theme.orange)
                    )
            }
        }
    }
}

private struct FutureBannerCard: View {
    let action: () -> Void

    @State private var isBannerSettled = false
    @State private var isPressed = false
    @State private var isArrowFloating = false
    @State private var isSheenVisible = false
    @State private var tapFlash = false

    var body: some View {
        Button(action: handleTap) {
            ZStack(alignment: .bottomLeading) {
                GeometryReader { proxy in
                    if let uiImage = BundleBannerImage.image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(isBannerSettled ? 1.0 : 1.035)
                            .overlay(
                                LinearGradient(
                                    colors: [
                                        Theme.brand.opacity(0.42),
                                        Theme.brand.opacity(0.2),
                                        Color.clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                LinearGradient(
                                    colors: [
                                        Color.black.opacity(0.16),
                                        Color.clear,
                                        Color.black.opacity(0.12)
                                    ],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .overlay(alignment: .leading) {
                                GeometryReader { sheenProxy in
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0),
                                            Color.white.opacity(0.18),
                                            Color.white.opacity(0)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .frame(width: 70)
                                    .rotationEffect(.degrees(12))
                                    .offset(x: isSheenVisible ? sheenProxy.size.width + 90 : -120)
                                }
                                .clipped()
                            }
                            .frame(
                                width: proxy.size.width,
                                height: proxy.size.height,
                                alignment: .center
                            )
                            .clipped()
                    } else {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "214F91"), Color(hex: "0F2F67")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }

                if tapFlash {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                        .transition(.opacity)
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Mobility reimagined\nfor a better future.")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)

                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(.white)
                        .frame(width: 40, height: 34)
                        .overlay(
                            Image(systemName: "arrow.right")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Theme.ink)
                                .offset(x: isArrowFloating ? 2.5 : -1.5)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 6, y: 3)
                }
                .padding(.leading, 18)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
        .buttonStyle(.plain)
        .frame(height: 126)
        .scaleEffect(isPressed ? 0.986 : 1)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(isPressed ? 0.32 : 0.12), lineWidth: isPressed ? 1.2 : 0.8)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        withAnimation(.easeOut(duration: 0.14)) {
                            isPressed = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.84)) {
                        isPressed = false
                    }
                }
        )
        .onAppear {
            guard !isBannerSettled else { return }
            withAnimation(.easeOut(duration: 0.7)) {
                isBannerSettled = true
            }
            withAnimation(.easeInOut(duration: 1.05).repeatForever(autoreverses: true)) {
                isArrowFloating = true
            }
            withAnimation(.easeInOut(duration: 1.4).delay(0.55).repeatForever(autoreverses: false)) {
                isSheenVisible = true
            }
        }
        .animation(.spring(response: 0.24, dampingFraction: 0.84), value: isPressed)
        .animation(.easeInOut(duration: 0.2), value: tapFlash)
    }

    private func handleTap() {
        withAnimation(.easeOut(duration: 0.12)) {
            tapFlash = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            withAnimation(.easeOut(duration: 0.18)) {
                tapFlash = false
            }
            action()
        }
    }
}

private struct MileageProgressBar: View {
    let progress: CGFloat

    @State private var displayedProgress: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.progressBase)
                Capsule()
                    .fill(Theme.brand)
                    .frame(width: proxy.size.width * displayedProgress)
            }
        }
        .frame(height: 6)
        .onAppear {
            withAnimation(.easeOut(duration: 0.9).delay(0.12)) {
                displayedProgress = progress
            }
        }
        .onChange(of: progress) { _, newProgress in
            withAnimation(.easeOut(duration: 0.45)) {
                displayedProgress = newProgress
            }
        }
    }
}

private struct MetricPair: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.ink)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.inkSoft)
        }
    }
}

	private struct PlanCard: View {
	    let plan: PlanOption
	    let isSelected: Bool
	    let highlightAsPopular: Bool
	    let action: () -> Void

        private var savingsPercent: Int {
            Int(round((1 - (plan.extraMilePrice / DemoContent.policyRatePerMile)) * 100))
        }
	
	    var body: some View {
	        Button(action: action) {
	            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(plan.displayTitle)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.ink)

                        Text(plan.displayPrice)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Theme.ink)
                    }

                    Spacer(minLength: 0)

                    VStack(alignment: .trailing, spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(isSelected ? Theme.brand : Theme.screen)
                                .overlay(Circle().stroke(isSelected ? Theme.brand : Theme.lineStrong, lineWidth: 1))
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .opacity(isSelected ? 1 : 0)
                        }
                        .frame(width: 20, height: 20)

                        if let badge = plan.badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(Theme.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Theme.brandSoft))
                        }
	                    }
	                }
	
                    VStack(alignment: .leading, spacing: 6) {
                        if plan.isTripPolicy {
                            Text("Charged at \(currencyString(DemoContent.policyRatePerMile)) per mile with no weekly subscription")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Theme.inkSoft)
                        } else {
                            Text("Package rate \(currencyString(plan.extraMilePrice)) / mile")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Theme.inkSoft)

                            HStack(spacing: 8) {
                                Text("Policy \(currencyString(DemoContent.policyRatePerMile)) / mile")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(Theme.inkSoft)

                                if savingsPercent > 0 {
                                    Text("Save \(savingsPercent)%")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(Theme.green)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(Theme.greenSoft))
                                }
                            }
                        }
                    }
	            }
	            .padding(14)
	            .frame(maxWidth: .infinity, alignment: .leading)
	            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(highlightAsPopular ? Theme.brandSoft.opacity(0.65) : Theme.screen)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(isSelected ? Theme.brand : Theme.lineStrong, lineWidth: isSelected ? 1.4 : 1)
                    )
            )
	        }
	        .buttonStyle(.plain)
	    }
	}

private struct PlanFootnote: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.ink)
                .frame(width: 16, height: 16)

            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.ink)
        }
    }
}

private struct FooterButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Theme.brand)
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(Theme.screen)
    }
}

private struct WeekHeaderStrip: View {
    let days: [ScheduleWeekDay]
    let selectedDate: Date
    let action: (Date) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(days) { day in
                Button(action: { action(day.date) }) {
                    VStack(spacing: 10) {
                        Text(day.symbol)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Theme.ink)

                        Text(day.dateNumber)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(DemoCalendar.isSameDay(day.date, selectedDate) ? .white : Theme.ink)
                            .frame(width: 26, height: 26)
                            .background(DemoCalendar.isSameDay(day.date, selectedDate) ? Theme.brand : .clear, in: Circle())
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 2)
    }
}

private struct MonthOverviewCard: View {
    let selectedDate: Date
    let monthDays: [ScheduleMonthDay]
    let bookingCountForDate: (Date) -> Int
    let isExpanded: Bool
    let selectDate: (Date) -> Void
    let shiftMonth: (Int) -> Void
    let toggleExpanded: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        StatCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(DemoCalendar.monthTitle(for: selectedDate))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Theme.ink)

                        if !isExpanded {
                            Text(collapsedSummary)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Theme.inkSoft)
                        }
                    }

                    Spacer(minLength: 0)

                    HStack(spacing: 8) {
                        MonthNavButton(symbol: "chevron.left") {
                            shiftMonth(-1)
                        }
                        MonthNavButton(symbol: "chevron.right") {
                            shiftMonth(1)
                        }
                        MonthNavButton(symbol: isExpanded ? "chevron.up" : "chevron.down") {
                            toggleExpanded()
                        }
                    }
                }

                if isExpanded {
                    HStack(spacing: 0) {
                        ForEach(DemoCalendar.monthSymbolsSundayFirst, id: \.self) { symbol in
                            Text(symbol)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(Theme.inkSoft)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(monthDays) { day in
                            MonthDayCell(
                                day: day,
                                isSelected: DemoCalendar.isSameDay(day.date, selectedDate),
                                bookingCount: bookingCountForDate(day.date)
                            ) {
                                selectDate(day.date)
                            }
                        }
                    }
                }
            }
        }
    }

    private var collapsedSummary: String {
        let tripCount = bookingCountForDate(selectedDate)
        let tripLabel = tripCount == 1 ? "1 trip" : "\(tripCount) trips"
        return "Focused on \(DemoCalendar.dayTitle(for: selectedDate)) · \(tripLabel)"
    }
}

private struct MonthNavButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Theme.canvas)
                .frame(width: 30, height: 30)
                .overlay(
                    Image(systemName: symbol)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct MonthDayCell: View {
    let day: ScheduleMonthDay
    let isSelected: Bool
    let bookingCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(day.dayNumber)
                    .font(.system(size: 13, weight: isSelected ? .bold : .semibold))
                    .foregroundStyle(dayTextColor)
                    .frame(width: 28, height: 28)
                    .background(isSelected ? Theme.blue : .clear, in: Circle())

                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { dotIndex in
                        Circle()
                            .fill(dotIndex < min(bookingCount, 3) ? Theme.brand : Color.clear)
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(height: 5)
                .opacity(day.isInDisplayedMonth ? 1 : 0.22)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var dayTextColor: Color {
        if isSelected {
            return .white
        }

        return day.isInDisplayedMonth ? Theme.ink : Theme.inkSoft.opacity(0.5)
    }
}

private enum DemoTimeFormatter {
    private static let calendar = Calendar(identifier: .gregorian)

    static func shortTime(_ minuteOfDay: Int) -> String {
        let clamped = max(0, minuteOfDay)
        let hour24 = (clamped / 60) % 24
        let minute = clamped % 60
        let suffix = hour24 >= 12 ? "PM" : "AM"
        let hour12: Int
        switch hour24 {
        case 0: hour12 = 12
        case 1...12: hour12 = hour24
        default: hour12 = hour24 - 12
        }
        return String(format: "%d:%02d %@", hour12, minute, suffix)
    }

    static func range(startMinute: Int, durationMinutes: Int) -> String {
        "\(shortTime(startMinute)) – \(shortTime(startMinute + durationMinutes))"
    }

    static func hourLabel(_ hour24: Int) -> String {
        switch hour24 {
        case 0: return "12 AM"
        case 12: return "12 PM"
        case 13...23: return "\(hour24 - 12) PM"
        default: return "\(hour24) AM"
        }
    }

    static func date(for minuteOfDay: Int) -> Date {
        let clamped = max(0, minuteOfDay)
        var components = DateComponents()
        components.year = 2026
        components.month = 5
        components.day = 20
        components.hour = clamped / 60
        components.minute = clamped % 60
        return calendar.date(from: components) ?? Date()
    }

    static func minuteOfDay(from date: Date) -> Int {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }
}

private struct DispatchStatusBadge: View {
    let title: String
    let foreground: Color
    let background: Color

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(background))
    }
}

private struct DispatchTimelineBoard: View {
    let blocks: [ScheduleBlock]
    let windows: [DispatchWindow]
    let selectedDate: Date
    let currentMoment: Date
    let selectedBlockID: String
    let highlightedBlockID: String?
    let submissionStates: [String: DispatchSubmissionState]
    let isEditingEnabled: Bool
    let boardHeight: CGFloat
    let canEditBlock: (ScheduleBlock) -> Bool
    let selectBlock: (String) -> Void
    let previewStateForBlock: (String, Int) -> DragPreviewState
    let updateBlockStart: (String, Int) -> Void
    let clearSubmissionState: (String) -> Void

    @State private var dragOriginMinute: Int?
    @State private var draggingBlockID: String?
    @State private var dragPreviewMinute: Int?
    @State private var dragPreviewIsBlocked = false

    private let hours = Array(7...22)
    private let timelineStartMinute = 7 * 60
    private let timelineEndMinute = 23 * 60
    private let labelWidth: CGFloat = 34
    private let pointsPerMinute: CGFloat = 2.3

    var body: some View {
        GeometryReader { proxy in
            let timelineWidth = proxy.size.width - labelWidth - 10
            let contentHeight = max(
                boardHeight,
                CGFloat(timelineEndMinute - timelineStartMinute) * pointsPerMinute
            )
            let hourHeight = 60 * pointsPerMinute

            ScrollView(.vertical, showsIndicators: false) {
                HStack(alignment: .top, spacing: 10) {
                    VStack(spacing: 0) {
                        ForEach(hours, id: \.self) { hour in
                            Text(DemoTimeFormatter.hourLabel(hour))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Theme.inkSoft)
                                .frame(width: labelWidth, height: hourHeight, alignment: .topLeading)
                                .padding(.top, 6)
                        }
                    }

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Theme.screen)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Theme.line, lineWidth: 1)
                            )

                        ForEach(windows) { window in
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(window.state.fill.opacity(0.72))
                                .frame(width: timelineWidth - 14, height: max(height(for: window), 10))
                                .offset(x: 7, y: yPosition(for: window.startMinute))
                        }

                        ForEach(hours, id: \.self) { hour in
                            Rectangle()
                                .fill(Theme.line)
                                .frame(width: timelineWidth - 14, height: 1)
                                .offset(x: 7, y: yPosition(for: hour * 60))
                        }

                        if let currentMinuteMarker {
                            Rectangle()
                                .fill(Theme.dispatchRed)
                                .frame(width: timelineWidth - 22, height: 2)
                                .offset(x: 11, y: yPosition(for: currentMinuteMarker))

                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Theme.dispatchRed)
                                    .frame(width: 8, height: 8)

                                Text("Now \(DemoTimeFormatter.shortTime(currentMinuteMarker))")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Theme.dispatchRed)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Theme.dispatchRedSoft.opacity(0.96))
                            )
                            .offset(x: 15, y: max(yPosition(for: currentMinuteMarker) - 18, 6))
                        }

                        ForEach(blocks) { block in
                            InteractiveScheduleBlock(
                                block: block,
                                displayStartMinute: displayedStartMinute(for: block),
                                availability: displayAvailability(for: block),
                                timingState: timingState(for: block),
                                submissionState: submissionStates[block.id],
                                isSelected: selectedBlockID == block.id,
                                isPulsing: highlightedBlockID == block.id,
                                isDragging: draggingBlockID == block.id,
                                isEditingEnabled: isEditingEnabled,
                                canDrag: canEditBlock(block),
                                onHandleDragChanged: { translationHeight in
                                    if draggingBlockID != block.id {
                                        draggingBlockID = block.id
                                        dragOriginMinute = block.startMinuteOfDay
                                        dragPreviewMinute = block.startMinuteOfDay
                                        selectBlock(block.id)
                                    }

                                    clearSubmissionState(block.id)
                                    let baseMinute = dragOriginMinute ?? block.startMinuteOfDay
                                    let minuteOffset = Int((translationHeight / pointsPerMinute).rounded())
                                    let proposedMinute = clampedStartMinute(
                                        baseMinute + minuteOffset,
                                        durationMinutes: block.durationMinutes
                                    )
                                    let preview = previewStateForBlock(block.id, proposedMinute)
                                    dragPreviewMinute = preview.minute
                                    dragPreviewIsBlocked = preview.isBlocked
                                },
                                onHandleDragEnded: {
                                    let previewMinute = dragPreviewMinute ?? block.startMinuteOfDay
                                    updateBlockStart(block.id, previewMinute)
                                    dragOriginMinute = nil
                                    dragPreviewMinute = nil
                                    dragPreviewIsBlocked = false
                                    draggingBlockID = nil
                                }
                            )
	                            .frame(
	                                width: timelineWidth - 18,
	                                height: max(height(forDuration: block.durationMinutes), 50),
	                                alignment: .topLeading
	                            )
                            .offset(x: 9, y: yPosition(for: displayedStartMinute(for: block)))
                            .transaction { transaction in
                                if draggingBlockID == block.id {
                                    transaction.animation = nil
                                    transaction.disablesAnimations = true
                                }
                            }
                            .onTapGesture {
                                selectBlock(block.id)
                            }
                        }
                    }
                    .frame(width: timelineWidth, height: contentHeight)
                }
                .frame(height: contentHeight, alignment: .top)
            }
        }
        .frame(height: boardHeight)
    }

    private func displayedStartMinute(for block: ScheduleBlock) -> Int {
        if draggingBlockID == block.id {
            return dragPreviewMinute ?? block.startMinuteOfDay
        }

        return block.startMinuteOfDay
    }

    private func displayAvailability(for block: ScheduleBlock) -> DispatchAvailabilityState {
        let minute = displayedStartMinute(for: block)

        if draggingBlockID == block.id && dragPreviewIsBlocked {
            return .blocked
        }

        return availability(forMinute: minute)
    }

    private func availability(forMinute minute: Int) -> DispatchAvailabilityState {
        windows.first(where: { minute >= $0.startMinute && minute < $0.endMinute })?.state ?? .blocked
    }

    private func availability(for block: ScheduleBlock) -> DispatchAvailabilityState {
        availability(forMinute: block.startMinuteOfDay)
    }

    private var currentMinuteMarker: Int? {
        guard DemoCalendar.isSameDay(selectedDate, currentMoment) else { return nil }
        let minute = DemoTimeFormatter.minuteOfDay(from: currentMoment)
        guard minute >= timelineStartMinute && minute <= timelineEndMinute else { return nil }
        return minute
    }

    private func timingState(for block: ScheduleBlock) -> ScheduleTemporalState {
        guard let currentMinuteMarker else { return .upcoming }
        let endMinute = block.startMinuteOfDay + block.durationMinutes

        if endMinute <= currentMinuteMarker {
            return .completed
        }

        if block.startMinuteOfDay <= currentMinuteMarker {
            return .inProgress
        }

        return .upcoming
    }

    private func yPosition(for minute: Int) -> CGFloat {
        CGFloat(minute - timelineStartMinute) * pointsPerMinute
    }

    private func height(for window: DispatchWindow) -> CGFloat {
        CGFloat(window.endMinute - window.startMinute) * pointsPerMinute
    }

    private func height(forDuration durationMinutes: Int) -> CGFloat {
        CGFloat(durationMinutes) * pointsPerMinute
    }

    private func clampedStartMinute(_ minute: Int, durationMinutes: Int) -> Int {
        min(max(minute, timelineStartMinute), timelineEndMinute - durationMinutes)
    }
}

private struct InteractiveScheduleBlock: View {
    let block: ScheduleBlock
    let displayStartMinute: Int
    let availability: DispatchAvailabilityState
    let timingState: ScheduleTemporalState
    let submissionState: DispatchSubmissionState?
    let isSelected: Bool
    let isPulsing: Bool
    let isDragging: Bool
    let isEditingEnabled: Bool
    let canDrag: Bool
    let onHandleDragChanged: (CGFloat) -> Void
    let onHandleDragEnded: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(block.route)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)

                Text("\(DemoTimeFormatter.range(startMinute: displayStartMinute, durationMinutes: block.durationMinutes)) • \(block.durationMinutes) min")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Theme.inkSoft)
                    .lineLimit(1)

                Text(block.detail)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Theme.inkSoft.opacity(0.92))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 6) {
                DispatchStatusBadge(
                    title: badgeTitle,
                    foreground: badgeAccent,
                    background: badgeAccent.opacity(0.14)
                )

                Image(systemName: badgeSymbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(badgeAccent)
                    .frame(width: 26, height: 26)
                    .contentShape(Rectangle())
                    .gesture(
                        (isSelected && canDrag)
                            ? DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    onHandleDragChanged(value.translation.height)
                                }
                                .onEnded { _ in
                                    onHandleDragEnded()
                                }
                            : nil
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(blockFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isSelected ? Theme.brand : badgeAccent, lineWidth: borderWidth)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(badgeAccent.opacity(isPulsing ? 0.3 : 0), lineWidth: 5)
                        .blur(radius: isPulsing ? 4 : 0)
                )
                .shadow(
                    color: (isSelected ? Theme.brand : badgeAccent).opacity(isPulsing ? 0.18 : 0.08),
                    radius: isDragging ? 12 : (isSelected ? 8 : 2),
                    y: isDragging ? 8 : (isSelected ? 4 : 1)
                )
        )
        .scaleEffect(isDragging ? 1.028 : (isPulsing ? 1.018 : (isSelected ? 1.01 : 1)))
        .opacity(timingState == .completed ? 0.82 : 1)
        .animation(.spring(response: 0.22, dampingFraction: 0.82), value: isSelected)
        .animation(.spring(response: 0.24, dampingFraction: 0.8), value: isPulsing)
    }

    private var badgeTitle: String {
        if timingState != .upcoming {
            return timingState.title
        }

        switch submissionState {
        case .lockedIn(let minute) where minute == block.startMinuteOfDay:
            return "Locked"
        case .waitlisted(let minute) where minute == block.startMinuteOfDay:
            return "Queued"
        default:
            return availability.title
        }
    }

    private var badgeAccent: Color {
        if timingState == .completed {
            return Theme.inkSoft
        }

        if timingState == .inProgress {
            return Theme.blue
        }

        switch submissionState {
        case .lockedIn(let minute) where minute == block.startMinuteOfDay:
            return Theme.green
        case .waitlisted(let minute) where minute == block.startMinuteOfDay:
            return Theme.dispatchYellow
        default:
            return availability.accent
        }
    }

    private var badgeSymbol: String {
        if timingState == .completed {
            return "lock.fill"
        }

        if timingState == .inProgress {
            return "clock.fill"
        }

        if !isEditingEnabled {
            return "lock.open.rotation"
        }

        switch submissionState {
        case .lockedIn(let minute) where minute == block.startMinuteOfDay:
            return "checkmark.seal.fill"
        case .waitlisted(let minute) where minute == block.startMinuteOfDay:
            return "clock.badge.exclamationmark"
        default:
            return "arrow.up.and.down"
        }
    }

    private var borderWidth: CGFloat {
        isSelected ? 1.9 : 1.3
    }

    private var blockFill: Color {
        if timingState == .completed {
            return Theme.line.opacity(0.45)
        }

        if timingState == .inProgress {
            return Theme.brandSoft.opacity(0.82)
        }

        return availability.fill.opacity(0.92)
    }
}

private struct DispatchDecisionCard: View {
    let block: ScheduleBlock
    let availability: DispatchAvailabilityState
    let submissionState: DispatchSubmissionState?
    let isPulsing: Bool
    let suggestedStartMinutes: [Int]
    let timingState: ScheduleTemporalState
    let isEditingEnabled: Bool
    let canEnterEditMode: Bool
    @Binding var detent: DecisionPanelDetent
    let toggleEditing: () -> Void
    let selectSuggestedStart: (Int) -> Void
    let primaryAction: () -> Void

    @GestureState private var dragTranslation: CGFloat = 0

    var body: some View {
        StatCard {
            VStack(alignment: .leading, spacing: 0) {
                handleBar

                switch detent {
                case .collapsed:
                    EmptyView()
                case .compact:
                    compactBody
                case .expanded:
                    expandedBody
                }
            }
        }
        .frame(height: detent.cardHeight, alignment: .top)
        .clipped()
        .offset(y: dragVisualOffset)
        .scaleEffect(isPulsing ? 1.01 : 1)
        .animation(.smooth(duration: 0.22, extraBounce: 0), value: detent)
        .animation(.spring(response: 0.26, dampingFraction: 0.82), value: isPulsing)
    }

    private var headline: String {
        switch timingState {
        case .completed:
            return "This trip is already complete."
        case .inProgress:
            return "This trip is already in progress."
        case .upcoming:
            break
        }

        switch submissionState {
        case .lockedIn(let minute) where minute == block.startMinuteOfDay:
            return "Vehicle reserved for this block."
        case .waitlisted(let minute) where minute == block.startMinuteOfDay:
            return "This block is now in the waitlist."
        default:
            switch availability {
            case .open: return "This block can lock in right now."
            case .waitlist: return "This block can enter the waitlist."
            case .blocked: return "This block needs a new time."
            }
        }
    }

    private var subheadline: String {
        switch timingState {
        case .completed, .inProgress:
            return timingState.description
        case .upcoming:
            break
        }

        switch submissionState {
        case .lockedIn(let minute) where minute == block.startMinuteOfDay:
            return "The rider now has a guaranteed vehicle at \(DemoTimeFormatter.shortTime(block.startMinuteOfDay))."
        case .waitlisted(let minute) where minute == block.startMinuteOfDay:
            return "We will promote this rider automatically if another trip cancels."
        default:
            return "Requested departure \(DemoTimeFormatter.shortTime(block.startMinuteOfDay)) for \(block.durationMinutes) minutes."
        }
    }

    private var noteText: String {
        if timingState != .upcoming {
            return timingState.description
        }

        if !isEditingEnabled {
            return "Edit mode is off. Turn it on before dragging or rescheduling any future block."
        }

        switch submissionState {
        case .lockedIn(let minute) where minute == block.startMinuteOfDay:
            return "Locked blocks reserve fleet capacity immediately."
        case .waitlisted(let minute) where minute == block.startMinuteOfDay:
            return "Yellow windows stay in line for cancellations or released capacity."
        default:
            return availability.description
        }
    }

    private var badgeTitle: String {
        if timingState != .upcoming {
            return timingState.title
        }

        switch submissionState {
        case .lockedIn(let minute) where minute == block.startMinuteOfDay:
            return "Locked In"
        case .waitlisted(let minute) where minute == block.startMinuteOfDay:
            return "Waitlisted"
        default:
            return availability.title
        }
    }

    private var badgeAccent: Color {
        switch submissionState {
        case .lockedIn(let minute) where minute == block.startMinuteOfDay:
            return Theme.green
        case .waitlisted(let minute) where minute == block.startMinuteOfDay:
            return Theme.dispatchYellow
        default:
            return availability.accent
        }
    }

    private var buttonTitle: String {
        switch timingState {
        case .completed:
            return "Completed"
        case .inProgress:
            return "Trip In Progress"
        case .upcoming:
            break
        }

        switch submissionState {
        case .lockedIn(let minute) where minute == block.startMinuteOfDay:
            return "Locked In"
        case .waitlisted(let minute) where minute == block.startMinuteOfDay:
            return "Waitlisted"
        default:
            switch availability {
            case .open:
                return "Lock In \(DemoTimeFormatter.shortTime(block.startMinuteOfDay))"
            case .waitlist:
                return "Join Waitlist"
            case .blocked:
                return "Move To Another Window"
            }
        }
    }

    private var buttonEnabled: Bool {
        timingState == .upcoming && !isSubmittedForCurrentMinute && availability != .blocked
    }

    private var isSubmittedForCurrentMinute: Bool {
        switch submissionState {
        case .lockedIn(let minute) where minute == block.startMinuteOfDay:
            return true
        case .waitlisted(let minute) where minute == block.startMinuteOfDay:
            return true
        default:
            return false
        }
    }

    @ViewBuilder
    private var handleBar: some View {
        VStack(spacing: 8) {
            Capsule()
                .fill(Theme.lineStrong)
                .frame(width: 36, height: 5)

            HStack(spacing: 8) {
                Text(handleTitle)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.inkSoft)

                Spacer(minLength: 0)

                Image(systemName: handleSymbol)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.inkSoft)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, detent == .collapsed ? 10 : 12)
        .contentShape(Rectangle())
        .gesture(expansionGesture)
        .onTapGesture {
            advancePanel()
        }
    }

    @ViewBuilder
    private var compactBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            summarySection
            headlineSection(showSubheadline: false)
            primaryButton
        }
    }

    @ViewBuilder
    private var expandedBody: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                summarySection
                headlineSection(showSubheadline: true)

                VStack(alignment: .leading, spacing: 8) {
                    DetailMeta(title: "Current block", value: block.timeShort)
                    DetailMeta(title: "Trip status", value: timingState.title)
                    DetailMeta(title: "Edit mode", value: isEditingEnabled ? "On for future trips" : "Off")
                    DetailMeta(title: "System note", value: noteText)
                }

                if !suggestedStartMinutes.isEmpty && !isSubmittedForCurrentMinute && timingState == .upcoming && isEditingEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(availability == .waitlist ? "Try a green window instead" : "Suggested windows")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.ink)

                        HStack(spacing: 8) {
                            ForEach(suggestedStartMinutes, id: \.self) { minute in
                                SuggestionChip(
                                    title: DemoTimeFormatter.shortTime(minute),
                                    isHighlighted: availability == .blocked
                                ) {
                                    selectSuggestedStart(minute)
                                }
                            }
                        }
                    }
                }

                primaryButton
            }
            .padding(.bottom, 8)
        }
    }

    @ViewBuilder
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Selected block")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.inkSoft)

                Spacer(minLength: 0)

                Button(action: toggleEditing) {
                    Text(isEditingEnabled ? "Done" : "Edit")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(canEnterEditMode || isEditingEnabled ? Theme.brand : Theme.inkSoft)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill((canEnterEditMode || isEditingEnabled) ? Theme.brandSoft : Theme.line.opacity(0.8))
                        )
                }
                .buttonStyle(.plain)
                .disabled(!canEnterEditMode && !isEditingEnabled)
            }

            Text(block.route)
                .font(.system(size: 21, weight: .semibold))
                .foregroundStyle(Theme.ink)

            HStack(alignment: .center, spacing: 8) {
                HStack(spacing: 8) {
                    SuggestionChip(title: DemoTimeFormatter.shortTime(block.startMinuteOfDay), isHighlighted: false, action: { })
                        .allowsHitTesting(false)
                    SuggestionChip(title: "\(block.durationMinutes) min block", isHighlighted: false, action: { })
                        .allowsHitTesting(false)
                }

                Spacer(minLength: 0)

                DispatchStatusBadge(
                    title: badgeTitle,
                    foreground: badgeAccent,
                    background: badgeAccent.opacity(0.14)
                )
            }

            Text(block.detail)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.inkSoft)
        }
    }

    @ViewBuilder
    private func headlineSection(showSubheadline: Bool) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(headline)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.ink)

                if showSubheadline {
                    Text(subheadline)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.inkSoft)
                }
            }

            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var primaryButton: some View {
        Button(action: primaryAction) {
            Text(buttonTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(buttonEnabled ? badgeAccent : Theme.lineStrong)
                )
        }
        .buttonStyle(.plain)
        .disabled(!buttonEnabled)
    }

    private var handleTitle: String {
        switch detent {
        case .collapsed:
            return "Pull up to reopen the selected block"
        case .compact:
            return "Drag up for details"
        case .expanded:
            return "Drag down to focus the day"
        }
    }

    private var handleSymbol: String {
        switch detent {
        case .collapsed: return "chevron.up"
        case .compact: return "chevron.up"
        case .expanded: return "chevron.down"
        }
    }

    private var dragVisualOffset: CGFloat {
        let softenedOffset = dragTranslation * 0.14
        return min(max(softenedOffset, -12), 12)
    }

    private var expansionGesture: some Gesture {
        DragGesture(minimumDistance: 6)
            .updating($dragTranslation) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                let threshold: CGFloat = 28
                if value.translation.height <= -threshold {
                    expandPanel()
                } else if value.translation.height >= threshold {
                    collapsePanel()
                }
            }
    }

    private func advancePanel() {
        switch detent {
        case .collapsed:
            setDetent(.compact)
        case .compact:
            setDetent(.expanded)
        case .expanded:
            setDetent(.compact)
        }
    }

    private func expandPanel() {
        switch detent {
        case .collapsed:
            setDetent(.compact)
        case .compact:
            setDetent(.expanded)
        case .expanded:
            break
        }
    }

    private func collapsePanel() {
        switch detent {
        case .expanded:
            setDetent(.compact)
        case .compact:
            setDetent(.collapsed)
        case .collapsed:
            break
        }
    }

    private func setDetent(_ newDetent: DecisionPanelDetent) {
        withAnimation(.smooth(duration: 0.22, extraBounce: 0)) {
            detent = newDetent
        }
    }
}

private struct CollapsedDecisionHandle: View {
    let reopen: () -> Void

    @GestureState private var dragTranslation: CGFloat = 0

    var body: some View {
        HStack(spacing: 8) {
            Capsule()
                .fill(Theme.lineStrong)
                .frame(width: 24, height: 4)

            Text("Show selected block")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.inkSoft)

            Image(systemName: "chevron.up")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.inkSoft)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Theme.screen)
                .overlay(
                    Capsule()
                        .stroke(Theme.line, lineWidth: 1)
                )
                .shadow(color: Theme.ink.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .offset(y: max(0, dragTranslation * 0.12))
        .contentShape(Capsule())
        .gesture(
            DragGesture(minimumDistance: 6)
                .updating($dragTranslation) { value, state, _ in
                    state = value.translation.height
                }
                .onEnded { value in
                    if value.translation.height < -18 {
                        reopen()
                    }
                }
        )
        .onTapGesture {
            reopen()
        }
    }
}

private struct ScheduleEmptyStateCard: View {
    let dayTitle: String
    let action: () -> Void

    var body: some View {
        StatCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("No trips on \(dayTitle)")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(Theme.ink)

                Text("Book a one-time or repeating trip for this week, then drag it if you want to fine-tune the time.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.inkSoft)

                OutlineButton(title: "Book Trip", action: action)
            }
        }
    }
}

private struct TripBookingSheet: View {
    let initialSelectedDayIndex: Int
    let selectedPlan: PlanOption
    let onReserve: (TripBookingRequest, RouteQuote) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var from: String
    @State private var to: String
    @State private var departureMinute: Int
    @State private var selectedDayIndices: Set<Int>
    @State private var isCalculatingQuote = true
    @State private var calculationStageIndex = 0

    private let departurePresets = [480, 790, 1050]

    init(
        initialSelectedDayIndex: Int,
        selectedPlan: PlanOption,
        onReserve: @escaping (TripBookingRequest, RouteQuote) -> Void
    ) {
        self.initialSelectedDayIndex = initialSelectedDayIndex
        self.selectedPlan = selectedPlan
        self.onReserve = onReserve
        _from = State(initialValue: "Office")
        _to = State(initialValue: "SoMa")
        _departureMinute = State(initialValue: 13 * 60 + 10)
        _selectedDayIndices = State(initialValue: Set([initialSelectedDayIndex]))
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    routeCard
                    departureCard
                    quoteCard
                }
                .padding(.horizontal, 14)
                .padding(.top, 16)
                .padding(.bottom, 18)
            }
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle("Book Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.brand)
                }
            }
            .safeAreaInset(edge: .bottom) {
                FooterButton(title: reserveButtonTitle, action: reserve)
                .opacity(canReserve ? 1 : 0.45)
                .disabled(!canReserve)
            }
        }
        .task(id: calculationKey) {
            await simulateQuoteCalculation()
        }
    }

    private var routeCard: some View {
        StatCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Route")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.ink)

                BookingField(title: "From", text: $from, prompt: "Start location")
                BookingField(title: "To", text: $to, prompt: "Destination")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Demo routes")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.ink)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(Array(DemoContent.routeQuotes.prefix(6))) { quote in
                            RouteQuickPickCard(
                                quote: quote,
                                plan: selectedPlan,
                                isSelected: matchedQuote?.id == quote.id
                            ) {
                                from = quote.from
                                to = quote.to
                            }
                        }
                    }
                }
            }
        }
    }

    private var departureCard: some View {
        StatCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Departure")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.ink)

                DatePicker(
                    "Departure time",
                    selection: departureDateBinding,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
                .font(.system(size: 16, weight: .semibold))
                .tint(Theme.brand)

                timeSuggestionsRow
                repeatSection
            }
        }
    }

    private var timeSuggestionsRow: some View {
        HStack(spacing: 8) {
            ForEach(departurePresets, id: \.self) { minute in
                SuggestionChip(
                    title: DemoTimeFormatter.shortTime(minute),
                    isHighlighted: departureMinute == minute
                ) {
                    departureMinute = minute
                }
            }
        }
    }

    private var repeatSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Repeat every week")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.ink)

            repeatShortcutRow
            repeatDayRow
        }
    }

    private var repeatShortcutRow: some View {
        HStack(spacing: 8) {
            SuggestionChip(title: "Weekdays", isHighlighted: isWeekdaySelection) {
                selectedDayIndices = Set([0, 1, 2, 3, 4])
            }
            SuggestionChip(title: "Daily", isHighlighted: selectedDayIndices.count == 7) {
                selectedDayIndices = Set(0...6)
            }
            SuggestionChip(title: "Reset", isHighlighted: false) {
                selectedDayIndices = Set([initialSelectedDayIndex])
            }
        }
    }

    private var repeatDayRow: some View {
        HStack(spacing: 8) {
            ForEach(DemoContent.weekDays) { day in
                BookingDayPill(
                    day: day,
                    isSelected: selectedDayIndices.contains(day.index)
                ) {
                    toggleDay(day.index)
                }
            }
        }
    }

    private var quoteCard: some View {
        StatCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Live Quote")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.ink)

                if let matchedQuote {
                    if isCalculatingQuote {
                        QuoteComputationCard(
                            plan: selectedPlan,
                            stageIndex: calculationStageIndex
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    } else {
                        let perTripPrice = matchedQuote.price(for: selectedPlan)
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 16) {
                                MetricPair(value: "\(matchedQuote.miles) mi", label: "Distance")
                                MetricPair(value: "\(matchedQuote.durationMinutes) min", label: "Block")
                                MetricPair(value: currencyString(perTripPrice), label: "Per trip")
                            }

                            Divider()

                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(sortedDayIndices.count) trips / week")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(Theme.ink)
                                    Text("Repeats on \(repeatSummary)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(Theme.inkSoft)
                                }

                                Spacer(minLength: 0)

                                Text(currencyString(Double(sortedDayIndices.count) * perTripPrice))
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(Theme.brand)
                            }

                            Text(pricingPolicyLine(for: matchedQuote))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Theme.ink)

                            Text("Busy days snap to the nearest available slot in that day, and you can still refine the block afterward.")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Theme.inkSoft)
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                } else {
                    Text("Use one of the demo routes above to get a live distance, duration, and total price.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.inkSoft)
                }
            }
            .animation(.easeInOut(duration: 0.24), value: isCalculatingQuote)
        }
    }

    private var departureDateBinding: Binding<Date> {
        Binding(
            get: { DemoTimeFormatter.date(for: departureMinute) },
            set: { departureMinute = DemoTimeFormatter.minuteOfDay(from: $0) }
        )
    }

    private var matchedQuote: RouteQuote? {
        DemoContent.routeQuotes.first {
            $0.from.compare(from.trimmingCharacters(in: .whitespacesAndNewlines), options: .caseInsensitive) == .orderedSame &&
            $0.to.compare(to.trimmingCharacters(in: .whitespacesAndNewlines), options: .caseInsensitive) == .orderedSame
        }
    }

    private var sortedDayIndices: [Int] {
        selectedDayIndices.sorted()
    }

    private var calculationKey: String {
        let fromKey = from.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let toKey = to.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let dayKey = sortedDayIndices.map(String.init).joined(separator: "-")
        return "\(selectedPlan.id)|\(fromKey)|\(toKey)|\(departureMinute)|\(dayKey)"
    }

    private var repeatSummary: String {
        if sortedDayIndices == [0, 1, 2, 3, 4] {
            return "weekdays"
        }

        return sortedDayIndices
            .compactMap { index in
                DemoContent.weekDays.first(where: { $0.index == index })?.symbol
            }
            .joined(separator: "/")
    }

    private var reserveButtonTitle: String {
        if isCalculatingQuote {
            return "Calculating Quote..."
        }

        if sortedDayIndices.count <= 1 {
            return "Reserve Trip"
        }

        return "Reserve \(sortedDayIndices.count) Weekly Trips"
    }

    private var canReserve: Bool {
        matchedQuote != nil && !sortedDayIndices.isEmpty && !isCalculatingQuote
    }

    private var isWeekdaySelection: Bool {
        sortedDayIndices == [0, 1, 2, 3, 4]
    }

    private func toggleDay(_ dayIndex: Int) {
        if selectedDayIndices.contains(dayIndex) {
            selectedDayIndices.remove(dayIndex)
        } else {
            selectedDayIndices.insert(dayIndex)
        }
    }

    private func reserve() {
        guard let matchedQuote else { return }

        onReserve(
            TripBookingRequest(
                from: from.trimmingCharacters(in: .whitespacesAndNewlines),
                to: to.trimmingCharacters(in: .whitespacesAndNewlines),
                departureMinute: snapToFiveMinutes(departureMinute),
                dayIndices: sortedDayIndices
            ),
            matchedQuote
        )
        dismiss()
    }

    private func pricingPolicyLine(for quote: RouteQuote) -> String {
        let total = quote.price(for: selectedPlan)
        if selectedPlan.isTripPolicy {
            return "Trip Policy uses \(currencyString(selectedPlan.pricePerMile)) per mile. This \(quote.miles)-mile trip is \(currencyString(total))."
        }

        return "\(selectedPlan.displayTitle) uses \(currencyString(selectedPlan.pricePerMile)) per mile. This \(quote.miles)-mile trip is \(currencyString(total))."
    }

    @MainActor
    private func simulateQuoteCalculation() async {
        guard matchedQuote != nil else {
            isCalculatingQuote = false
            calculationStageIndex = 0
            return
        }

        isCalculatingQuote = true
        calculationStageIndex = 0

        let pauses: [UInt64] = [240_000_000, 340_000_000, 320_000_000]
        for (index, pause) in pauses.enumerated() {
            do {
                try await Task.sleep(nanoseconds: pause)
            } catch {
                return
            }

            guard !Task.isCancelled else { return }

            withAnimation(.easeInOut(duration: 0.2)) {
                calculationStageIndex = min(index + 1, 2)
            }
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.88)) {
            isCalculatingQuote = false
        }
    }
}

private struct SuggestionChip: View {
    let title: String
    let isHighlighted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(isHighlighted ? Theme.brand : Theme.ink)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(isHighlighted ? Theme.brandSoft : Theme.canvas)
                        .overlay(
                            Capsule()
                                .stroke(isHighlighted ? Theme.brand : Theme.lineStrong, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

private struct BookingField: View {
    let title: String
    @Binding var text: String
    let prompt: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.ink)

            TextField(prompt, text: $text)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Theme.canvas)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Theme.lineStrong, lineWidth: 1)
                        )
                )
        }
    }
}

private struct RouteQuickPickCard: View {
    let quote: RouteQuote
    let plan: PlanOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(quote.from) → \(quote.to)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)

                Text("\(quote.miles) mi • \(currencyString(quote.price(for: plan)))")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.inkSoft)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Theme.brandSoft : Theme.canvas)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? Theme.brand : Theme.lineStrong, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct BookingDayPill: View {
    let day: ScheduleWeekDay
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(day.symbol)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : Theme.ink)
                Text(day.dateNumber)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : Theme.ink)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Theme.brand : Theme.canvas)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? Theme.brand : Theme.lineStrong, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct QuoteComputationCard: View {
    let plan: PlanOption
    let stageIndex: Int

    private var steps: [String] {
        [
            "Checking route distance and trip block",
            "Checking fleet availability for this week",
            "Applying \(plan.displayTitle) pricing"
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ProgressView()
                    .tint(Theme.brand)

                VStack(alignment: .leading, spacing: 3) {
                    Text("RoamingOS is preparing this trip")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    Text("This is a demo-time calculation so investors can see the system thinking.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.inkSoft)
                }
            }

            VStack(spacing: 10) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    QuoteComputationStepRow(
                        title: step,
                        state: stepState(for: index)
                    )
                }
            }
        }
    }

    private func stepState(for index: Int) -> QuoteComputationStepState {
        if index < stageIndex {
            return .complete
        }

        if index == stageIndex {
            return .active
        }

        return .pending
    }
}

private enum QuoteComputationStepState: Equatable {
    case pending
    case active
    case complete
}

private struct QuoteComputationStepRow: View {
    let title: String
    let state: QuoteComputationStepState

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 24, height: 24)

                Image(systemName: iconName)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(foregroundColor)
            }

            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(state == .pending ? Theme.inkSoft : Theme.ink)

            Spacer(minLength: 0)

            if state == .active {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(Theme.brand)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(rowBackground)
        )
    }

    private var iconName: String {
        switch state {
        case .pending:
            return "circle"
        case .active:
            return "bolt.fill"
        case .complete:
            return "checkmark"
        }
    }

    private var foregroundColor: Color {
        switch state {
        case .pending:
            return Theme.inkSoft
        case .active:
            return Theme.brand
        case .complete:
            return Theme.green
        }
    }

    private var backgroundColor: Color {
        switch state {
        case .pending:
            return Theme.screen
        case .active:
            return Theme.brandSoft
        case .complete:
            return Theme.greenSoft
        }
    }

    private var rowBackground: Color {
        switch state {
        case .pending:
            return Theme.canvas
        case .active:
            return Theme.brandSoft.opacity(0.55)
        case .complete:
            return Theme.greenSoft.opacity(0.68)
        }
    }
}

private struct ScheduleHourRow: View {
    let hour: Int
    let trip: ScheduledTrip?
    let openTrip: (ScheduledTrip) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(hourLabel)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Theme.inkSoft)
                .frame(width: 34, alignment: .leading)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 0) {
                Rectangle()
                    .fill(Theme.line)
                    .frame(height: 1)

                if let trip {
                    Button(action: { openTrip(trip) }) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(trip.route)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Theme.ink)
                                Text(trip.timeShort)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Theme.ink)
                                Text("\(trip.miles) mi")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Theme.ink)
                            }

                            Spacer(minLength: 0)

                            Image(systemName: "car.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Theme.ink)
                                .padding(.top, 8)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(trip.tint)
                        )
                        .padding(.top, 10)
                    }
                    .buttonStyle(.plain)
                } else {
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(height: trip == nil ? 58 : 96, alignment: .top)
        .padding(.horizontal, 10)
    }

    private var hourLabel: String {
        switch hour {
        case 0: return "12 AM"
        case 12: return "12 PM"
        case 13...23: return "\(hour - 12) PM"
        default: return "\(hour) AM"
        }
    }
}

private struct ScheduledHeaderCard: View {
    let trip: ScheduledTrip

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Scheduled")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Wed, May 20, 2026")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("5:30 PM – 6:00 PM")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }

                Spacer(minLength: 0)

                Text("On time")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color(hex: "177D58")))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.brand)
        )
    }
}

private struct GuaranteeWindowCard: View {
    let compact: Bool

    @State private var animatedProgress: CGFloat = 0

    private let targetProgress: CGFloat = 0.68

    var body: some View {
        StatCard {
            VStack(alignment: .leading, spacing: compact ? 10 : 12) {
                HStack(spacing: 8) {
                    Image(systemName: "shield")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.blue)
                    Text("Guaranteed before 13:59")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                }

                Text("You can edit this trip at no cost before 13:59.")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.inkSoft)

                VStack(spacing: 8) {
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Theme.progressBase)
                            Capsule()
                                .fill(Theme.blue)
                                .frame(width: proxy.size.width * animatedProgress)
                            Circle()
                                .fill(Theme.ink)
                                .frame(width: 8, height: 8)
                                .offset(x: proxy.size.width * animatedProgress - 4)
                        }
                    }
                    .frame(height: 6)

                    HStack {
                        Text("Now")
                        Spacer()
                        Text("13:59")
                        Spacer()
                        Text("Lock-in")
                    }
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Theme.inkSoft)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.85).delay(compact ? 0.06 : 0.16)) {
                animatedProgress = targetProgress
            }
        }
    }
}

private struct VehicleCard: View {
    var body: some View {
        StatCard {
            HStack(spacing: 12) {
                CarPhoto(variant: .sideProfile)
                    .frame(width: 112, height: 54)

                VStack(alignment: .leading, spacing: 4) {
                    Text("RoamingOS Standard")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    Text("7ABC123")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.inkSoft)
                }

                Spacer(minLength: 0)
            }
        }
    }
}

private struct OutlineButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.brand)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Theme.brand, lineWidth: 1.4)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct LateEditCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Late cancel would cost")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.inkSoft)
                Text("4.5 miles")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(hex: "F26426"))
                Text("(Half of total miles)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.ink)
            }

            Spacer(minLength: 0)

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Theme.orangeSoft)
                .frame(width: 38, height: 38)
                .overlay(
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Theme.orange)
                )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.peach)
        )
    }
}

private struct RouteMapCard: View {
    var body: some View {
        ZStack {
            if let uiImage = BundleRouteMapImage.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                GeometryReader { proxy in
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(hex: "EEF1F4"))

                        MapStreetLayer()
                            .stroke(Color.white.opacity(0.9), lineWidth: 1.4)

                        MapParkPatches()
                            .fill(Color(hex: "DFF0D8"))

                        Path { path in
                            let points = [
                                CGPoint(x: proxy.size.width * 0.19, y: proxy.size.height * 0.66),
                                CGPoint(x: proxy.size.width * 0.34, y: proxy.size.height * 0.48),
                                CGPoint(x: proxy.size.width * 0.55, y: proxy.size.height * 0.26),
                                CGPoint(x: proxy.size.width * 0.73, y: proxy.size.height * 0.72),
                                CGPoint(x: proxy.size.width * 0.86, y: proxy.size.height * 0.43)
                            ]
                            guard let first = points.first else { return }
                            path.move(to: first)
                            for point in points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                        .stroke(Theme.blue, style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))

                        Circle()
                            .fill(Color.white)
                            .frame(width: 18, height: 18)
                            .overlay(Circle().stroke(Theme.blue, lineWidth: 3))
                            .position(x: proxy.size.width * 0.19, y: proxy.size.height * 0.66)

                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Theme.brand)
                            .position(x: proxy.size.width * 0.86, y: proxy.size.height * 0.43)
                    }
                }
            }
        }
        .frame(height: 136)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct MapStreetLayer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let verticals: [CGFloat] = [0.08, 0.2, 0.34, 0.49, 0.66, 0.82, 0.92]
        let horizontals: [CGFloat] = [0.16, 0.31, 0.5, 0.68, 0.86]

        for ratio in verticals {
            let x = rect.width * ratio
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x + 20, y: rect.maxY))
        }

        for ratio in horizontals {
            let y = rect.height * ratio
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y + 16))
        }

        return path
    }
}

private struct MapParkPatches: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: CGRect(x: rect.width * 0.03, y: rect.height * 0.12, width: rect.width * 0.17, height: rect.height * 0.28), cornerSize: CGSize(width: 10, height: 10))
        path.addRoundedRect(in: CGRect(x: rect.width * 0.75, y: rect.height * 0.07, width: rect.width * 0.12, height: rect.height * 0.18), cornerSize: CGSize(width: 10, height: 10))
        path.addRoundedRect(in: CGRect(x: rect.width * 0.63, y: rect.height * 0.75, width: rect.width * 0.16, height: rect.height * 0.15), cornerSize: CGSize(width: 10, height: 10))
        return path
    }
}

private struct DetailStopRow: View {
    let color: Color
    let title: String
    let location: String
    let time: String

    var body: some View {
        HStack(alignment: .top) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(color)
                Text(location)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.ink)
            }

            Spacer(minLength: 0)

            Text(time)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.inkSoft)
        }
    }
}

private struct DetailMeta: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.inkSoft)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.ink)
        }
    }
}

private struct SoftButton: View {
    let title: String
    let foreground: Color
    let background: Color
    let border: Color

    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(border, lineWidth: 1)
                    )
            )
    }
}

private struct StandardBottomBar: View {
    let selected: NavTab
    let action: (NavTab) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Theme.line)
                .frame(height: 1)

            HStack {
                ForEach(NavTab.allCases, id: \.title) { tab in
                    NavItem(tab: tab, selected: selected == tab) {
                        action(tab)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 10)
            .padding(.bottom, 8)
        }
        .background(Theme.screen)
    }
}

private struct NavItem: View {
    let tab: NavTab
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                tabIcon

                Text(tab.title)
                    .font(.system(size: 10, weight: selected ? .semibold : .medium))
                    .foregroundStyle(selected ? Theme.brand : Theme.inkSoft)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var tabIcon: some View {
        switch tab {
        case .schedule:
            CalendarGridGlyph(selected: selected)
        case .plan:
            PlanDocumentGlyph(selected: selected)
        case .home:
            Image(systemName: selected ? "house.fill" : "house")
                .font(.system(size: 18, weight: selected ? .semibold : .regular))
                .foregroundStyle(selected ? Theme.brand : Theme.inkSoft)
        case .trips:
            Image(systemName: selected ? "car.fill" : "car")
                .font(.system(size: 18, weight: selected ? .semibold : .regular))
                .foregroundStyle(selected ? Theme.brand : Theme.inkSoft)
        case .profile:
            Image(systemName: "person")
                .font(.system(size: 18, weight: selected ? .semibold : .regular))
                .foregroundStyle(selected ? Theme.brand : Theme.inkSoft)
        }
    }
}

private struct CalendarGridGlyph: View {
    let selected: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4.5, style: .continuous)
                .stroke(selected ? Theme.brand : Theme.inkSoft.opacity(0.8), lineWidth: 1.6)
                .frame(width: 18, height: 17)

            Rectangle()
                .fill(selected ? Theme.brand : Theme.inkSoft.opacity(0.8))
                .frame(width: 12, height: 1.4)
                .offset(y: -4.5)

            VStack(spacing: 1.8) {
                dotRow
                dotRow
            }
            .offset(y: 2)
        }
    }

    private var dotRow: some View {
        HStack(spacing: 1.8) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(selected ? Theme.brand : Theme.inkSoft.opacity(0.8))
                    .frame(width: 1.8, height: 1.8)
            }
        }
    }
}

private struct PlanDocumentGlyph: View {
    let selected: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4.5, style: .continuous)
                .stroke(selected ? Theme.brand : Theme.inkSoft.opacity(0.8), lineWidth: 1.6)
                .frame(width: 18, height: 17)

            VStack(spacing: 2.4) {
                RoundedRectangle(cornerRadius: 1.2, style: .continuous)
                    .fill(selected ? Theme.brand : Theme.inkSoft.opacity(0.8))
                    .frame(width: 9, height: 1.7)
                RoundedRectangle(cornerRadius: 1.2, style: .continuous)
                    .fill(selected ? Theme.brand : Theme.inkSoft.opacity(0.8))
                    .frame(width: 7.2, height: 1.7)
                RoundedRectangle(cornerRadius: 1.2, style: .continuous)
                    .fill(selected ? Theme.brand : Theme.inkSoft.opacity(0.8))
                    .frame(width: 8.3, height: 1.7)
            }

            Circle()
                .fill(selected ? Theme.brand : Theme.inkSoft.opacity(0.8))
                .frame(width: 4.2, height: 4.2)
                .offset(x: 5.4, y: -4.6)
        }
    }
}

private enum CarPhotoVariant {
    case frontThreeQuarter
    case sideProfile
    case rearThreeQuarter
}

private struct CarPhoto: View {
    let variant: CarPhotoVariant

    var body: some View {
        GeometryReader { proxy in
            let baseWidth = max(proxy.size.width, proxy.size.height * 1.5)
            let zoomScale = zoom
            let imageWidth = baseWidth * zoomScale
            let imageHeight = imageWidth / 1.5

            Group {
                if let uiImage = BundleCarImage.image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .interpolation(.high)
                        .antialiased(true)
                        .frame(width: imageWidth, height: imageHeight)
                        .offset(
                            x: (0.5 - focus.x) * imageWidth,
                            y: (0.5 - focus.y) * imageHeight
                        )
                } else {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.opacity(0.95))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Theme.line, lineWidth: 1)
                        )
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
    }

    private var focus: CGPoint {
        switch variant {
        case .frontThreeQuarter:
            return CGPoint(x: 0.245, y: 0.24)
        case .sideProfile:
            return CGPoint(x: 0.75, y: 0.225)
        case .rearThreeQuarter:
            return CGPoint(x: 0.76, y: 0.74)
        }
    }

    private var zoom: CGFloat {
        switch variant {
        case .frontThreeQuarter:
            return 2.0
        case .sideProfile:
            return 2.15
        case .rearThreeQuarter:
            return 2.1
        }
    }
}

private enum BundleCarImage {
    static let image: UIImage? = {
        if let image = UIImage(named: "tesla-reference") {
            return image
        }
        if let image = UIImage(named: "tesla-reference.jpg") {
            return image
        }
        guard let url = Bundle.main.url(forResource: "tesla-reference", withExtension: "jpg") else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }()
}

private enum BundleBannerImage {
    static let image: UIImage? = {
        if let image = UIImage(named: "banner-background") {
            return image
        }
        if let image = UIImage(named: "banner-background.jpg") {
            return image
        }
        guard let url = Bundle.main.url(forResource: "banner-background", withExtension: "jpg") else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }()
}

private enum BundleRouteMapImage {
    static let image: UIImage? = {
        if let image = UIImage(named: "route-map-reference") {
            return image
        }
        if let image = UIImage(named: "route-map-reference.jpg") {
            return image
        }
        guard let url = Bundle.main.url(forResource: "route-map-reference", withExtension: "jpg") else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }()
}
