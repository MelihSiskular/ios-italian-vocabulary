//
//  HistoryView.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 26.08.2026.
//

import SwiftUI
import Charts


struct HistoryView: View {
    
    @StateObject private var viewModel =
    HistoryViewModel()
    
    @State private var
    isShowingCustomRange = false
    
    
    // User explicitly wanted these two
    // chart series colors.
    
    private let attemptsColor =
    Color.orange
    
    private let correctColor =
    Color(
        red: 0.10,
        green: 0.38,
        blue: 0.22
    )
    private let averageColor =
    Color.red
    
    // MARK: - Body
    
    var body: some View {
        
        NavigationStack {
            
            Group {
                
                if viewModel.isLoading {
                    
                    ProgressView(
                        "Loading history..."
                    )
                    
                } else if let errorMessage =
                            viewModel.errorMessage,
                          viewModel.sessions.isEmpty {
                    
                    ContentUnavailableView(
                        "Something went wrong",
                        systemImage:
                            "exclamationmark.triangle",
                        description:
                            Text(errorMessage)
                    )
                    
                } else {
                    
                    content
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(
                .large
            )
            .onAppear {
                
                Task {
                    await viewModel.load()
                }
            }
            .refreshable {
                await viewModel.load()
            }
            .sheet(
                isPresented:
                    $isShowingCustomRange
            ) {
                
                customRangeSheet
            }
        }
    }
    
    
    // MARK: - Content
    
    private var content: some View {
        
        ScrollView {
            
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xl
            ) {
                
                activitySection
                
                sessionsSection
            }
            .padding(
                .horizontal,
                AppTheme.Layout.horizontalPadding
            )
            .padding(
                .bottom,
                AppTheme.Spacing.xxl
            )
        }
    }
    
    
    // MARK: - Activity Chart
    
    private var activitySection: some View {
        
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {
            
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xs
            ) {
                
                Text("Last 30 days")
                    .font(.title2.bold())
                
                Text(
                    "All quiz attempts and correct answers from the last 30 days."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            
            
            AppCard {
                
                VStack(
                    alignment: .leading,
                    spacing: AppTheme.Spacing.md
                ) {
                    
                    activityChart
                    
                    chartLegend
                }
            }
        }
    }
    
    
    private var activityChart: some View {
        
        Chart(
            viewModel.dailyActivity
        ) { item in
            
            
            // MARK: Practiced
            
            LineMark(
                x: .value(
                    "Date",
                    item.date
                ),
                y: .value(
                    "Attempts",
                    item.attempts
                )
            )
            .foregroundStyle(
                attemptsColor
            )
            
            PointMark(
                x: .value(
                    "Date",
                    item.date
                ),
                y: .value(
                    "Attempts",
                    item.attempts
                )
            )
            .foregroundStyle(
                attemptsColor
            )
            .symbolSize(18)
            
            // MARK: Successful
            
            LineMark(
                x: .value(
                    "Date",
                    item.date
                ),
                y: .value(
                    "Correct",
                    item.correctAttempts
                )
            )
            .foregroundStyle(
                correctColor
            )
            
            PointMark(
                x: .value(
                    "Date",
                    item.date
                ),
                y: .value(
                    "Correct",
                    item.correctAttempts
                )
            )
            .foregroundStyle(
                correctColor
            )
            .symbolSize(18)
            
            if viewModel.averageAttemptsPerActiveDay > 0 {
                
                RuleMark(
                    y: .value(
                        "Average",
                        viewModel.averageAttemptsPerActiveDay
                    )
                )
                .foregroundStyle(
                    averageColor.opacity(0.75)
                )
                .lineStyle(
                    StrokeStyle(
                        lineWidth: 1.5,
                        dash: [6, 5]
                    )
                )
                .annotation(
                    position: .top,
                    alignment: .leading
                ) {
                    
                    Text(
                        "\(Int(viewModel.averageAttemptsPerActiveDay.rounded()))"
                    )
                    .font(
                        .caption2.weight(.medium)
                    )
                    .foregroundStyle(
                        averageColor.opacity(0.55)
                    )
                }
            }
        }
        .frame(height: 220)
        .chartYScale(
            domain: 0...chartMaximum
        )
        .chartXAxis {
            
            AxisMarks(
                values:
                        .automatic(
                            desiredCount: 5
                        )
            ) {
                
                AxisGridLine()
                    .foregroundStyle(
                        Color.primary.opacity(
                            0.05
                        )
                    )
                
                AxisTick()
                
                AxisValueLabel(
                    format:
                            .dateTime
                        .day()
                        .month(
                            .abbreviated
                        )
                )
            }
        }
        .chartYAxis {
            
            AxisMarks(
                position: .leading
            ) {
                
                AxisGridLine()
                    .foregroundStyle(
                        Color.primary.opacity(
                            0.06
                        )
                    )
                
                AxisValueLabel()
            }
        }
    }
    
    
    private var chartMaximum: Int {
        
        let maximum =
        viewModel.dailyActivity
            .map {
                max(
                    $0.attempts,
                    $0.correctAttempts
                )
            }
            .max() ?? 0
        
        return max(
            maximum + 2,
            5
        )
    }
    
    
    private var chartLegend: some View {
        
        HStack(
            spacing: AppTheme.Spacing.lg
        ) {
            
            legendItem(
                title: "Attempts",
                color: attemptsColor
            )
            
            legendItem(
                title: "Correct",
                color: correctColor
            )
            
            legendItem(
                title: "Avg",
                color: averageColor
            )
        }
    }
    
    private func legendItem(
        title: String,
        color: Color
    ) -> some View {
        
        HStack(
            spacing: AppTheme.Spacing.xs
        ) {
            
            Circle()
                .fill(color)
                .frame(
                    width: 8,
                    height: 8
                )
            
            Text(title)
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )
        }
    }
    
    
    // MARK: - Sessions
    
    private var sessionsSection: some View {
        
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {
            
            sessionsHeader
            
            
            if viewModel.isPageLoading {
                
                AppCard {
                    
                    HStack {
                        
                        Spacer()
                        
                        ProgressView()
                        
                        Spacer()
                    }
                    .padding(
                        .vertical,
                        AppTheme.Spacing.lg
                    )
                }
                
            } else if viewModel
                .sessions
                .isEmpty {
                
                AppCard {
                    
                    HStack(
                        spacing:
                            AppTheme.Spacing.md
                    ) {
                        
                        Image(
                            systemName:
                                "calendar.badge.clock"
                        )
                        .foregroundStyle(
                            .secondary
                        )
                        
                        VStack(
                            alignment: .leading,
                            spacing:
                                AppTheme.Spacing.xs
                        ) {
                            
                            Text(
                                "No sessions found"
                            )
                            .font(.headline)
                            
                            Text(
                                "Try another date range."
                            )
                            .font(.subheadline)
                            .foregroundStyle(
                                .secondary
                            )
                        }
                        
                        Spacer()
                    }
                }
                
            } else {
                
                sessionGroups
                
                paginationControls
            }
        }
    }
    
    
    private var sessionsHeader: some View {
        
        HStack(
            alignment: .center
        ) {
            
            VStack(
                alignment: .leading,
                spacing: 2
            ) {
                
                Text("Sessions")
                    .font(.title2.bold())
                
                Text(
                    "\(viewModel.totalSessionCount) total"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            filterMenu
        }
    }
    
    
    // MARK: - Filter Menu
    
    private var filterMenu: some View {
        
        Menu {
            
            Button {
                
                Task {
                    await viewModel
                        .applyFilter(
                            .allTime
                        )
                }
                
            } label: {
                
                filterMenuLabel(
                    .allTime
                )
            }
            
            
            Button {
                
                Task {
                    await viewModel
                        .applyFilter(
                            .last7Days
                        )
                }
                
            } label: {
                
                filterMenuLabel(
                    .last7Days
                )
            }
            
            
            Button {
                
                Task {
                    await viewModel
                        .applyFilter(
                            .last30Days
                        )
                }
                
            } label: {
                
                filterMenuLabel(
                    .last30Days
                )
            }
            
            
            Button {
                
                Task {
                    await viewModel
                        .applyFilter(
                            .thisMonth
                        )
                }
                
            } label: {
                
                filterMenuLabel(
                    .thisMonth
                )
            }
            
            
            Divider()
            
            
            Button {
                
                isShowingCustomRange = true
                
            } label: {
                
                Label(
                    "Custom range",
                    systemImage:
                        "calendar"
                )
            }
            
        } label: {
            
            HStack(
                spacing: AppTheme.Spacing.xs
            ) {
                
                Text(
                    viewModel
                        .selectedFilter
                        .title
                )
                
                Image(
                    systemName:
                        "chevron.down"
                )
                .font(.caption2)
            }
            .font(
                .subheadline.weight(
                    .semibold
                )
            )
            .foregroundStyle(.secondary)
            .padding(
                .horizontal,
                AppTheme.Spacing.sm
            )
            .padding(
                .vertical,
                AppTheme.Spacing.xs
            )
            .background(
                Capsule()
                    .fill(
                        Color.primary.opacity(
                            0.06
                        )
                    )
            )
        }
    }
    
    
    @ViewBuilder
    private func filterMenuLabel(
        _ filter: HistoryDateFilter
    ) -> some View {
        
        if viewModel.selectedFilter
            == filter {
            
            Label(
                filter.title,
                systemImage:
                    "checkmark"
            )
            
        } else {
            
            Text(filter.title)
        }
    }
    
    
    // MARK: - Session Groups
    
    private var sessionGroups: some View {
        
        LazyVStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.xl
        ) {
            
            ForEach(
                viewModel.groupedSessions
            ) { group in
                
                VStack(
                    alignment: .leading,
                    spacing:
                        AppTheme.Spacing.md
                ) {
                    
                    Text(
                        viewModel.dayTitle(
                            group.date
                        )
                    )
                    .font(
                        .headline
                    )
                    .foregroundStyle(
                        .secondary
                    )
                    
                    
                    ForEach(
                        group.sessions
                    ) { session in
                        
                        sessionCard(
                            session
                        )
                    }
                }
            }
        }
    }
    
    
    // MARK: - Session Card
    
    private func sessionCard(
        _ session: QuizSessionRecord
    ) -> some View {
        
        let attempts =
        viewModel.attemptCount(
            for: session
        )
        
        let mistakes =
        viewModel.mistakeCount(
            for: session
        )
        
        let firstTry =
        viewModel
            .firstTryCorrectCount(
                for: session
            )
        
        let totalTasks =
        viewModel.totalTasks(
            for: session
        )
        
        
        return AppCard {
            
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.md
            ) {
                
                HStack(
                    alignment: .top
                ) {
                    
                    VStack(
                        alignment: .leading,
                        spacing:
                            AppTheme.Spacing.xs
                    ) {
                        
                        if let sectionNumber =
                            session.sectionNumber {
                            
                            Text(
                                "Section \(sectionNumber)"
                            )
                            .font(.headline)
                        }
                        
                        Text(
                            viewModel.modeTitle(
                                for: session
                            )
                        )
                        .font(.subheadline)
                        .foregroundStyle(
                            .secondary
                        )
                    }
                    
                    
                    Spacer()
                    
                    
                    StatusBadge(
                        viewModel.statusTitle(
                            for: session
                        ),
                        systemImage:
                            viewModel.statusIcon(
                                for: session
                            )
                    )
                }
                
                
                Divider()
                
                
                HStack {
                    
                    historyMetric(
                        title: "Tasks",
                        value:
                            "\(totalTasks)"
                    )
                    
                    Spacer()
                    
                    historyMetric(
                        title: "Attempts",
                        value:
                            "\(attempts)"
                    )
                    
                    Spacer()
                    
                    historyMetric(
                        title: "Mistakes",
                        value:
                            "\(mistakes)"
                    )
                }
                
                
                HStack {
                    
                    Label(
                        "First try \(firstTry)/\(totalTasks)",
                        systemImage:
                            "scope"
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
                    
                    
                    Spacer()
                    
                    
                    Text(
                        session.startedAt
                            .formatted(
                                date: .omitted,
                                time: .shortened
                            )
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
                }
            }
        }
    }
    
    
    private func historyMetric(
        title: String,
        value: String
    ) -> some View {
        
        VStack(
            alignment: .leading,
            spacing: 3
        ) {
            
            Text(value)
                .font(.headline)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )
        }
    }
    
    
    // MARK: - Pagination
    
    private var paginationControls:
    some View {
        
        AppCard {
            
            HStack {
                
                Button {
                    
                    HapticManager.selection()
                    
                    Task {
                        await viewModel.previousPage()
                    }
                    
                }label: {
                    
                    Image(
                        systemName:
                            "chevron.left"
                    )
                    .frame(
                        width: 36,
                        height: 36
                    )
                }
                .buttonStyle(.plain)
                .disabled(
                    !viewModel.canGoPrevious
                )
                .opacity(
                    viewModel.canGoPrevious
                    ? 1
                    : 0.3
                )
                
                
                Spacer()
                
                
                VStack(
                    spacing: 2
                ) {
                    
                    Text(
                        "Page \(viewModel.currentPage) of \(viewModel.totalPages)"
                    )
                    .font(
                        .subheadline.weight(
                            .semibold
                        )
                    )
                    
                    Text(
                        "\(viewModel.totalSessionCount) sessions"
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
                }
                
                
                Spacer()
                
                
                Button {
                    
                    HapticManager.selection()
                    
                    Task {
                        await viewModel.nextPage()
                    }
                    
                }label: {
                    
                    Image(
                        systemName:
                            "chevron.right"
                    )
                    .frame(
                        width: 36,
                        height: 36
                    )
                }
                .buttonStyle(.plain)
                .disabled(
                    !viewModel.canGoNext
                )
                .opacity(
                    viewModel.canGoNext
                    ? 1
                    : 0.3
                )
            }
        }
    }
    
    
    // MARK: - Custom Range Sheet
    
    private var customRangeSheet:
    some View {
        
        NavigationStack {
            
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xl
            ) {
                
                VStack(
                    alignment: .leading,
                    spacing:
                        AppTheme.Spacing.xs
                ) {
                    
                    Text(
                        "Choose a date range"
                    )
                    .font(.title2.bold())
                    
                    Text(
                        "History sessions will be filtered to this period."
                    )
                    .font(.subheadline)
                    .foregroundStyle(
                        .secondary
                    )
                }
                
                
                AppCard {
                    
                    VStack(
                        spacing:
                            AppTheme.Spacing.md
                    ) {
                        
                        DatePicker(
                            "From",
                            selection:
                                $viewModel
                                .customStartDate,
                            displayedComponents:
                                    .date
                        )
                        
                        Divider()
                        
                        DatePicker(
                            "To",
                            selection:
                                $viewModel
                                .customEndDate,
                            displayedComponents:
                                    .date
                        )
                    }
                }
                
                
                Spacer()
                
                
                Button {
                    
                    Task {
                        
                        await viewModel
                            .applyCustomRange()
                        
                        isShowingCustomRange =
                        false
                    }
                    
                } label: {
                    
                    Text("Apply Range")
                        .fontWeight(
                            .semibold
                        )
                        .frame(
                            maxWidth:
                                    .infinity
                        )
                }
                .buttonStyle(
                    .borderedProminent
                )
                .controlSize(.large)
                .disabled(
                    !viewModel
                        .customRangeIsValid
                )
            }
            .padding(
                AppTheme.Layout.horizontalPadding
            )
            .navigationTitle(
                "Custom Range"
            )
            .navigationBarTitleDisplayMode(
                .inline
            )
            .toolbar {
                
                ToolbarItem(
                    placement:
                            .cancellationAction
                ) {
                    
                    Button("Cancel") {
                        
                        isShowingCustomRange =
                        false
                    }
                }
            }
        }
        .presentationDetents(
            [.medium]
        )
    }
}
