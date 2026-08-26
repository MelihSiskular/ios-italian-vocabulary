//
//  ProgressView.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import SwiftUI

struct LearningProgressView: View {
    
    @StateObject private var viewModel =
    ProgressViewModel()
    
    private let metricColumns = [
        GridItem(
            .flexible(),
            spacing: AppTheme.Layout.gridSpacing
        ),
        GridItem(
            .flexible(),
            spacing: AppTheme.Layout.gridSpacing
        )
    ]
    
    
    // MARK: - Body
    
    var body: some View {
        
        NavigationStack {
            
            Group {
                
                if viewModel.isLoading {
                    
                    ProgressView(
                        "Loading progress..."
                    )
                    
                } else if let errorMessage =
                            viewModel.errorMessage {
                    
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
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.load()
            }
            .refreshable {
                await viewModel.load()
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
                
                progressHero
                
                overviewSection
                
                masterySection
                
                hardestWordsSection
                
                mistakeTypesSection
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
    
    
    // MARK: - Hero
    
    private var progressHero: some View {
        
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {
            
            HStack(
                alignment: .firstTextBaseline
            ) {
                
                Text(
                    "\(viewModel.learnedWords)"
                )
                .font(
                    .system(
                        size: 42,
                        weight: .bold,
                        design: .rounded
                    )
                )
                
                Text(
                    viewModel.learnedWords == 1
                    ? "word learned"
                    : "words learned"
                )
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)
            }
            
            Text(heroSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }
    
    private var heroSubtitle: String {
        
        if viewModel.learnedWords == 0 {
            return "Your vocabulary journey starts here."
        }
        
        if viewModel.dueWords > 0 {
            
            return viewModel.dueWords == 1
            ? "1 word is ready for review."
            : "\(viewModel.dueWords) words are ready for review."
        }
        
        return "Your learned vocabulary is up to date."
    }
    
    
    // MARK: - Overview
    
    private var overviewSection: some View {
        
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {
            
            sectionTitle(
                "Overview"
            )
            
            LazyVGrid(
                columns: metricColumns,
                spacing:
                    AppTheme.Layout.gridSpacing
            ) {
                
                metricCard(
                    title: "Accuracy",
                    value:
                        String(
                            format: "%.1f%%",
                            viewModel.accuracy
                        ),
                    systemImage:
                        "scope"
                )
                
                metricCard(
                    title: "Due now",
                    value:
                        "\(viewModel.dueWords)",
                    systemImage:
                        "clock.arrow.circlepath"
                )
                
                metricCard(
                    title: "Sessions",
                    value:
                        "\(viewModel.totalSessions)",
                    systemImage:
                        "rectangle.stack"
                )
                
                metricCard(
                    title: "Mistakes",
                    value:
                        "\(viewModel.totalMistakes)",
                    systemImage:
                        "exclamationmark.circle"
                )
            }
        }
    }
    
    
    // MARK: - Mastery
    
    private var masterySection: some View {
        
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {
            
            HStack {
                
                sectionTitle(
                    "Mastery"
                )
                
                Spacer()
                
                StatusBadge(
                    String(
                        format:
                            "Avg %.1f",
                        viewModel.averageMastery
                    ),
                    systemImage:
                        "chart.line.uptrend.xyaxis"
                )
            }
            
            AppCard {
                
                if viewModel.masteryDistribution.isEmpty {
                    
                    emptyRow(
                        icon: "chart.bar",
                        text:
                            "No mastery data yet."
                    )
                    
                } else {
                    
                    VStack(spacing: 0) {
                        
                        ForEach(
                            viewModel.masteryDistribution,
                            id: \.0
                        ) { item in
                            
                            masteryRow(
                                level: item.0,
                                count: item.1
                            )
                            
                            if item.0
                                != viewModel
                                .masteryDistribution
                                .last?.0 {
                                
                                Divider()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func masteryRow(
        level: Int,
        count: Int
    ) -> some View {
        
        HStack(
            spacing: AppTheme.Spacing.md
        ) {
            
            ZStack {
                
                Circle()
                    .fill(
                        Color.primary.opacity(
                            0.05
                        )
                    )
                
                Text("\(level)")
                    .font(
                        .caption.weight(
                            .bold
                        )
                    )
                    .foregroundStyle(
                        .secondary
                    )
            }
            .frame(
                width: 32,
                height: 32
            )
            
            VStack(
                alignment: .leading,
                spacing: 2
            ) {
                
                Text(
                    "Level \(level)"
                )
                .font(.headline)
                
                Text(
                    masteryDescription(
                        level
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(
                "\(count)"
            )
            .font(
                .title3.weight(
                    .semibold
                )
            )
            
            Text(
                count == 1
                ? "word"
                : "words"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(
            .vertical,
            AppTheme.Spacing.sm
        )
    }
    
    private func masteryDescription(
        _ level: Int
    ) -> String {
        
        switch level {
            
        case 0:
            return "Not started"
            
        case 1...2:
            return "Building familiarity"
            
        case 3...5:
            return "Getting stronger"
            
        case 6...9:
            return "Well established"
            
        default:
            return "Mastered"
        }
    }
    
    
    // MARK: - Hardest Words
    
    private var hardestWordsSection: some View {
        
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {
            
            sectionTitle(
                "Hardest Words"
            )
            
            if viewModel.hardestWords.isEmpty {
                
                AppCard {
                    
                    emptyRow(
                        icon:
                            "checkmark.circle",
                        text:
                            "No difficult words yet."
                    )
                }
                
            } else {
                
                AppCard {
                    
                    VStack(spacing: 0) {
                        
                        ForEach(
                            Array(
                                viewModel
                                    .hardestWords
                                    .prefix(10)
                            )
                        ) { stat in
                            
                            hardWordRow(stat)
                            
                            if stat.id
                                != viewModel
                                .hardestWords
                                .prefix(10)
                                .last?.id {
                                
                                Divider()
                                    .padding(
                                        .leading,
                                        42
                                    )
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func hardWordRow(
        _ stat: HardWordStat
    ) -> some View {
        
        HStack(
            alignment: .center,
            spacing: AppTheme.Spacing.md
        ) {
            
            Image(
                systemName:
                    difficultyIcon(
                        stat
                    )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(
                width: 28,
                height: 28
            )
            .background(
                Circle()
                    .fill(
                        Color.primary.opacity(
                            0.05
                        )
                    )
            )
            
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xs
            ) {
                
                Text(
                    stat.word.italian
                )
                .font(.headline)
                
                if let turkish =
                    stat.word.turkish,
                   !turkish.isEmpty {
                    
                    Text(turkish)
                        .font(.subheadline)
                        .foregroundStyle(
                            .secondary
                        )
                }
                
                Text(
                    mistakeDescription(
                        stat
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(
                alignment: .trailing,
                spacing: 2
            ) {
                
                Text(
                    "\(stat.wrongAttempts)"
                )
                .font(
                    .title3.weight(
                        .semibold
                    )
                )
                
                Text(
                    stat.wrongAttempts == 1
                    ? "mistake"
                    : "mistakes"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(
            .vertical,
            AppTheme.Spacing.sm
        )
    }
    
    private func difficultyIcon(
        _ stat: HardWordStat
    ) -> String {
        
        if stat.noRecallErrors > 0 {
            return "brain"
        }
        
        if stat.confusionErrors > 0 {
            return "arrow.triangle.swap"
        }
        
        if stat.spellingErrors > 0 {
            return "textformat.abc"
        }
        
        return "exclamationmark"
    }
    
    
    // MARK: - Mistake Types
    
    private var mistakeTypesSection: some View {
        
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {
            
            sectionTitle(
                "Mistake Types"
            )
            
            AppCard {
                
                if viewModel.errorCounts.isEmpty {
                    
                    emptyRow(
                        icon:
                            "checkmark.circle",
                        text:
                            "No mistakes yet."
                    )
                    
                } else {
                    
                    VStack(spacing: 0) {
                        
                        ForEach(
                            viewModel.errorCounts,
                            id: \.0
                        ) { item in
                            
                            mistakeTypeRow(
                                type: item.0,
                                count: item.1
                            )
                            
                            if item.0
                                != viewModel
                                .errorCounts
                                .last?.0 {
                                
                                Divider()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func mistakeTypeRow(
        type: String,
        count: Int
    ) -> some View {
        
        HStack(
            spacing: AppTheme.Spacing.md
        ) {
            
            Image(
                systemName:
                    errorIcon(type)
            )
            .foregroundStyle(.secondary)
            .frame(width: 24)
            
            Text(
                errorTitle(type)
            )
            .font(.body)
            
            Spacer()
            
            Text("\(count)")
                .fontWeight(.semibold)
        }
        .padding(
            .vertical,
            AppTheme.Spacing.sm
        )
    }
    
    
    // MARK: - Components
    
    private func metricCard(
        title: String,
        value: String,
        systemImage: String
    ) -> some View {
        
        AppCard {
            
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.md
            ) {
                
                Image(
                    systemName:
                        systemImage
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                
                VStack(
                    alignment: .leading,
                    spacing: AppTheme.Spacing.xs
                ) {
                    
                    Text(value)
                        .font(
                            .system(
                                size: 28,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                    
                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(
                maxWidth: .infinity,
                minHeight: 90,
                alignment: .leading
            )
        }
    }
    
    private func sectionTitle(
        _ title: String
    ) -> some View {
        
        Text(title)
            .font(.title2.bold())
    }
    
    private func emptyRow(
        icon: String,
        text: String
    ) -> some View {
        
        HStack(
            spacing: AppTheme.Spacing.md
        ) {
            
            Image(
                systemName: icon
            )
            .foregroundStyle(.secondary)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
    }
    
    
    // MARK: - Error Helpers
    
    private func errorTitle(
        _ errorType: String
    ) -> String {
        
        switch errorType {
            
        case "spelling_error":
            return "Spelling"
            
        case "confused_with_another_word":
            return "Confused words"
            
        case "wrong_word_form":
            return "Wrong word form"
            
        case "no_recall":
            return "No recall"
            
        case "unknown_or_semantic_error":
            return "Meaning / Unknown"
            
        default:
            return errorType
        }
    }
    
    private func errorIcon(
        _ errorType: String
    ) -> String {
        
        switch errorType {
            
        case "spelling_error":
            return "textformat.abc"
            
        case "confused_with_another_word":
            return "arrow.triangle.swap"
            
        case "wrong_word_form":
            return "textformat"
            
        case "no_recall":
            return "brain"
            
        case "unknown_or_semantic_error":
            return "questionmark"
            
        default:
            return "exclamationmark"
        }
    }
    
    
    // MARK: - Hard Word Helper
    
    private func mistakeDescription(
        _ stat: HardWordStat
    ) -> String {
        
        var parts: [String] = []
        
        if stat.noRecallErrors > 0 {
            
            parts.append(
                "\(stat.noRecallErrors) no recall"
            )
        }
        
        if stat.spellingErrors > 0 {
            
            parts.append(
                "\(stat.spellingErrors) spelling"
            )
        }
        
        if stat.confusionErrors > 0 {
            
            parts.append(
                "\(stat.confusionErrors) confused"
            )
        }
        
        if stat.wrongWordFormErrors > 0 {
            
            parts.append(
                "\(stat.wrongWordFormErrors) word form"
            )
        }
        
        if stat.semanticErrors > 0 {
            
            parts.append(
                "\(stat.semanticErrors) meaning"
            )
        }
        
        return parts.joined(
            separator: " • "
        )
    }
}
