//
//  HistoryViewModel.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 26.08.2026.
//
import Foundation
internal import Combine


// MARK: - Filter

enum HistoryDateFilter:
    String,
    CaseIterable,
    Identifiable {
    
    case allTime
    case last7Days
    case last30Days
    case thisMonth
    case custom
    
    var id: String {
        rawValue
    }
    
    var title: String {
        
        switch self {
            
        case .allTime:
            return "All time"
            
        case .last7Days:
            return "Last 7 days"
            
        case .last30Days:
            return "Last 30 days"
            
        case .thisMonth:
            return "This month"
            
        case .custom:
            return "Custom range"
        }
    }
}


// MARK: - Daily Learning Activity

struct DailyLearningActivity:
    Identifiable {
    
    let date: Date
    
    let practicedWords: Int
    let successfulWords: Int
    
    var id: Date {
        date
    }
}


// MARK: - History Day Group

struct HistoryDayGroup:
    Identifiable {
    
    let date: Date
    let sessions: [QuizSessionRecord]
    
    var id: Date {
        date
    }
}


// MARK: - ViewModel

@MainActor
final class HistoryViewModel:
    ObservableObject {
    
    @Published private(set)
    var sessions: [QuizSessionRecord] = []
    
    @Published private(set)
    var attempts: [ReviewAttemptRecord] = []
    
    @Published private(set)
    var dailyActivity:
    [DailyLearningActivity] = []
    
    @Published private(set)
    var isLoading = false
    
    @Published private(set)
    var isPageLoading = false
    
    @Published var errorMessage: String?
    
    
    // MARK: Pagination
    
    let pageSize = 20
    
    @Published private(set)
    var currentPage = 1
    
    @Published private(set)
    var totalPages = 1
    
    @Published private(set)
    var totalSessionCount = 0
    
    
    // MARK: Filter
    
    @Published private(set)
    var selectedFilter:
    HistoryDateFilter = .allTime
    
    @Published var customStartDate: Date
    
    @Published var customEndDate: Date
    
    
    private let analyticsService =
    AnalyticsService()
    
    private let calendar =
    Calendar.current
    
    
    init() {
        
        let today =
        Calendar.current
            .startOfDay(
                for: Date()
            )
        
        customEndDate = today
        
        customStartDate =
        Calendar.current.date(
            byAdding: .day,
            value: -6,
            to: today
        ) ?? today
    }
    
    
    // MARK: - Initial Load
    
    func load() async {
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            
            async let chartAttemptsTask =
            analyticsService
                .fetchAttempts(
                    from:
                        chartRange.start,
                    toExclusive:
                        chartRange.end
                )
            
            let page =
            try await fetchCurrentPage()
            
            let pageAttempts =
            try await analyticsService
                .fetchAttempts(
                    sessionIds:
                        page.sessions.map(
                            \.id
                        )
                )
            
            let chartAttempts =
            try await chartAttemptsTask
            
            apply(
                page: page,
                pageAttempts: pageAttempts
            )
            
            dailyActivity =
            makeDailyActivity(
                from: chartAttempts
            )
            
        } catch {
            
            errorMessage =
            error.localizedDescription
            
            print(
                "❌ History load error:",
                error
            )
        }
    }
    
    
    // MARK: - Page Loading
    
    private func loadCurrentPage() async {
        
        isPageLoading = true
        errorMessage = nil
        
        defer {
            isPageLoading = false
        }
        
        do {
            
            let page =
            try await fetchCurrentPage()
            
            let pageAttempts =
            try await analyticsService
                .fetchAttempts(
                    sessionIds:
                        page.sessions.map(
                            \.id
                        )
                )
            
            apply(
                page: page,
                pageAttempts: pageAttempts
            )
            
        } catch {
            
            errorMessage =
            error.localizedDescription
            
            print(
                "❌ History page error:",
                error
            )
        }
    }
    
    
    private func fetchCurrentPage()
    async throws -> HistorySessionPage {
        
        let range =
        filterRange
        
        return try await analyticsService
            .fetchHistoryPage(
                page: currentPage,
                pageSize: pageSize,
                startDate: range.start,
                endDateExclusive:
                    range.end
            )
    }
    
    
    private func apply(
        page: HistorySessionPage,
        pageAttempts: [ReviewAttemptRecord]
    ) {
        
        sessions = page.sessions
        attempts = pageAttempts
        
        totalSessionCount =
        page.totalCount
        
        totalPages = max(
            Int(
                ceil(
                    Double(page.totalCount)
                    / Double(pageSize)
                )
            ),
            1
        )
        
        if currentPage > totalPages {
            
            currentPage =
            totalPages
        }
    }
    
    
    // MARK: - Pagination Actions
    
    var canGoPrevious: Bool {
        currentPage > 1
    }
    
    var canGoNext: Bool {
        currentPage < totalPages
    }
    
    
    func nextPage() async {
        
        guard canGoNext else {
            return
        }
        
        currentPage += 1
        
        await loadCurrentPage()
    }
    
    
    func previousPage() async {
        
        guard canGoPrevious else {
            return
        }
        
        currentPage -= 1
        
        await loadCurrentPage()
    }
    
    
    // MARK: - Filters
    
    func applyFilter(
        _ filter: HistoryDateFilter
    ) async {
        
        guard filter != .custom else {
            return
        }
        
        selectedFilter = filter
        currentPage = 1
        
        await loadCurrentPage()
    }
    
    
    func applyCustomRange() async {
        
        guard customRangeIsValid else {
            return
        }
        
        selectedFilter = .custom
        currentPage = 1
        
        await loadCurrentPage()
    }
    
    
    var customRangeIsValid: Bool {
        
        let start =
        calendar.startOfDay(
            for: customStartDate
        )
        
        let end =
        calendar.startOfDay(
            for: customEndDate
        )
        
        return start <= end
    }
    
    
    // MARK: - Filter Date Range
    
    private var filterRange:
    (start: Date?, end: Date?) {
        
        let now = Date()
        
        let today =
        calendar.startOfDay(
            for: now
        )
        
        let tomorrow =
        calendar.date(
            byAdding: .day,
            value: 1,
            to: today
        ) ?? now
        
        
        switch selectedFilter {
            
        case .allTime:
            
            return (
                nil,
                nil
            )
            
            
        case .last7Days:
            
            let start =
            calendar.date(
                byAdding: .day,
                value: -6,
                to: today
            )
            
            return (
                start,
                tomorrow
            )
            
            
        case .last30Days:
            
            let start =
            calendar.date(
                byAdding: .day,
                value: -29,
                to: today
            )
            
            return (
                start,
                tomorrow
            )
            
            
        case .thisMonth:
            
            guard let interval =
                    calendar.dateInterval(
                        of: .month,
                        for: now
                    )
            else {
                
                return (
                    nil,
                    nil
                )
            }
            
            return (
                interval.start,
                interval.end
            )
            
            
        case .custom:
            
            let start =
            calendar.startOfDay(
                for: customStartDate
            )
            
            let endDay =
            calendar.startOfDay(
                for: customEndDate
            )
            
            let end =
            calendar.date(
                byAdding: .day,
                value: 1,
                to: endDay
            )
            
            return (
                start,
                end
            )
        }
    }
    
    
    // MARK: - Chart Range
    
    private var chartRange:
    (start: Date, end: Date) {
        
        let today =
        calendar.startOfDay(
            for: Date()
        )
        
        let start =
        calendar.date(
            byAdding: .day,
            value: -29,
            to: today
        ) ?? today
        
        let end =
        calendar.date(
            byAdding: .day,
            value: 1,
            to: today
        ) ?? Date()
        
        return (
            start,
            end
        )
    }
    
    
    // MARK: - Daily Chart Analytics
    
    private func makeDailyActivity(
        from attempts: [ReviewAttemptRecord]
    ) -> [DailyLearningActivity] {
        
        let range = chartRange
        
        let attemptsByDay =
        Dictionary(
            grouping: attempts
        ) { attempt in
            
            calendar.startOfDay(
                for: attempt.createdAt
            )
        }
        
        
        var result:
        [DailyLearningActivity] = []
        
        
        for offset in 0..<30 {
            
            guard let day =
                    calendar.date(
                        byAdding: .day,
                        value: offset,
                        to: range.start
                    )
            else {
                continue
            }
            
            let dayAttempts =
            attemptsByDay[day] ?? []
            
            
            // Unique words encountered
            let practicedWords =
            Set(
                dayAttempts.map {
                    $0.wordId
                }
            )
            .count
            
            
            // MARK: Successful Words
            
            let attemptsBySession =
            Dictionary(
                grouping: dayAttempts
            ) {
                $0.sessionId
            }
            
            
            var successfulWordIds:
            Set<Int> = []
            
            
            for (_, sessionAttempts)
                    in attemptsBySession {
                
                let attemptsByWord =
                Dictionary(
                    grouping:
                        sessionAttempts
                ) {
                    $0.wordId
                }
                
                
                for (
                    wordId,
                    wordAttempts
                ) in attemptsByWord {
                    
                    let cleanLanguages =
                    Set(
                        wordAttempts
                            .filter {
                                $0.isCorrect
                                &&
                                $0.isFirstTryCorrect
                            }
                            .map {
                                $0.clueLanguage
                            }
                    )
                    
                    
                    if cleanLanguages
                        .contains("tr"),
                       cleanLanguages
                        .contains("en") {
                        
                        successfulWordIds
                            .insert(wordId)
                    }
                }
            }
            
            
            result.append(
                DailyLearningActivity(
                    date: day,
                    practicedWords:
                        practicedWords,
                    successfulWords:
                        successfulWordIds.count
                )
            )
        }
        
        return result
    }
    
    
    // MARK: - Grouped Sessions
    
    var groupedSessions:
    [HistoryDayGroup] {
        
        let grouped =
        Dictionary(
            grouping: sessions
        ) { session in
            
            calendar.startOfDay(
                for:
                    session.startedAt
            )
        }
        
        
        return grouped
            .map {
                
                HistoryDayGroup(
                    date: $0.key,
                    sessions:
                        $0.value.sorted {
                            $0.startedAt
                            >
                            $1.startedAt
                        }
                )
            }
            .sorted {
                $0.date > $1.date
            }
    }
    
    
    func dayTitle(
        _ date: Date
    ) -> String {
        
        if calendar.isDateInToday(
            date
        ) {
            return "Today"
        }
        
        if calendar.isDateInYesterday(
            date
        ) {
            return "Yesterday"
        }
        
        return date.formatted(
            .dateTime
                .day()
                .month(.wide)
                .year()
        )
    }
    
    
    // MARK: - Attempt Analytics
    
    func attempts(
        for sessionId: UUID
    ) -> [ReviewAttemptRecord] {
        
        attempts.filter {
            $0.sessionId == sessionId
        }
    }
    
    
    func attemptCount(
        for session: QuizSessionRecord
    ) -> Int {
        
        attempts(
            for: session.id
        )
        .count
    }
    
    
    func mistakeCount(
        for session: QuizSessionRecord
    ) -> Int {
        
        attempts(
            for: session.id
        )
        .filter {
            !$0.isCorrect
        }
        .count
    }
    
    
    func firstTryCorrectCount(
        for session: QuizSessionRecord
    ) -> Int {
        
        attempts(
            for: session.id
        )
        .filter {
            $0.isFirstTryCorrect
        }
        .count
    }
    
    
    func totalTasks(
        for session: QuizSessionRecord
    ) -> Int {
        
        session.totalWords * 2
    }
    
    
    // MARK: - Session UI Helpers
    
    func modeTitle(
        for session: QuizSessionRecord
    ) -> String {
        
        switch session.mode {
            
        case "initial_section":
            return "Initial Section"
            
        case "section_review":
            return "Section Review"
            
        case "daily_review":
            return "Daily Review"
            
        case "free_practice":
            return "Free Practice"
            
        default:
            return session.mode
        }
    }
    
    
    func statusTitle(
        for session: QuizSessionRecord
    ) -> String {
        
        let attempts =
        attemptCount(
            for: session
        )
        
        if attempts == 0 {
            return "Interrupted"
        }
        
        if session.mode
            == "section_review" {
            
            return mistakeCount(
                for: session
            ) == 0
            ? "Complete"
            : "Partial"
        }
        
        return session.passed
        ? "Passed"
        : "Retry"
    }
    
    
    func statusIcon(
        for session: QuizSessionRecord
    ) -> String {
        
        let attempts =
        attemptCount(
            for: session
        )
        
        if attempts == 0 {
            return "pause"
        }
        
        if session.mode
            == "section_review" {
            
            return mistakeCount(
                for: session
            ) == 0
            ? "checkmark"
            : "arrow.clockwise"
        }
        
        return session.passed
        ? "checkmark"
        : "arrow.clockwise"
    }
}
