//
//  SectionDetailView.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import SwiftUI


struct SectionDetailView: View {
    
    let section: WordSection
    
    @State private var currentProgress:
    SectionProgressState
    
    @State private var currentDueWords:
    [Word]
    
    @State private var isRefreshing =
    false
    
    private let wordProgressService =
    WordProgressService()
    
    
    // MARK: - Init
    
    init(
        section: WordSection,
        progress: SectionProgressState,
        dueWords: [Word]
    ) {
        
        self.section =
        section
        
        self._currentProgress =
        State(
            initialValue:
                progress
        )
        
        self._currentDueWords =
        State(
            initialValue:
                dueWords
        )
    }
    
    
    // MARK: - State
    
    private var isReview: Bool {
        
        !currentDueWords.isEmpty
    }
    
    
    private var isUpToDate: Bool {
        
        currentProgress.isCompletedOnce
        && currentDueWords.isEmpty
    }
    
    
    private var displayedWords:
    [Word] {
        
        if isReview {
            
            return currentDueWords
        }
        
        return section.words
    }
    
    
    private var wordCountText:
    String {
        
        if isReview {
            
            return currentDueWords.count == 1
            ? "1 word to review"
            : "\(currentDueWords.count) words to review"
        }
        
        if isUpToDate {
            
            return "Review up to date"
        }
        
        return section.words.count == 1
        ? "1 word"
        : "\(section.words.count) words"
    }
    
    
    private var actionTitle: String {
        
        if isReview {
            
            return currentDueWords.count == 1
            ? "Review 1 Word"
            : "Review \(currentDueWords.count) Words"
        }
        
        if isUpToDate {
            
            return "Practice Section"
        }
        
        return "Start Section"
    }
    
    private var actionMode:
    QuizMode {
        
        if isReview {
            return .sectionReview
        }
        
        if isUpToDate {
            return .freePractice
        }
        
        return .initialSection
    }
    
    
    private var actionWords:
    [Word] {
        
        if isReview {
            return currentDueWords
        }
        
        return section.words
    }
    
    
    private var actionIcon:
    String {
        
        if isReview {
            return "arrow.clockwise"
        }
        
        if isUpToDate {
            return "repeat"
        }
        
        return "play.fill"
    }
    
    
    // MARK: - Body
    
    var body: some View {
        
        ScrollView {
            
            VStack(
                alignment: .leading,
                spacing:
                    AppTheme.Spacing.lg
            ) {
                
                summaryCard
                
                vocabularySection
            }
            .padding(
                .horizontal,
                AppTheme.Layout
                    .horizontalPadding
            )
            .padding(
                .top,
                AppTheme.Spacing.sm
            )
            .padding(
                .bottom,
                AppTheme.Spacing.xxl
            )
        }
        .navigationTitle(
            "Section \(section.number)"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
        .safeAreaInset(
            edge: .bottom
        ) {
            
            actionArea
        }
        .task {
            
            await refreshSectionState()
        }
    }
    
    
    // MARK: - Summary
    
    private var summaryCard:
    some View {
        
        AppCard {
            
            VStack(
                alignment: .leading,
                spacing:
                    AppTheme.Spacing.md
            ) {
                
                HStack {
                    
                    StatusBadge(
                        statusTitle,
                        systemImage:
                            statusIcon
                    )
                    
                    Spacer()
                    
                    if !currentProgress
                        .isCompletedOnce {
                        
                        Text(
                            "\(currentProgress.completedCount) / \(section.words.count)"
                        )
                        .font(
                            .subheadline
                                .weight(
                                    .semibold
                                )
                        )
                        .foregroundStyle(
                            .secondary
                        )
                    }
                }
                
                
                VStack(
                    alignment: .leading,
                    spacing:
                        AppTheme.Spacing.xs
                ) {
                    
                    Text(
                        wordCountText
                    )
                    .font(
                        .title2.bold()
                    )
                    
                    Text(
                        summaryDescription
                    )
                    .font(
                        .subheadline
                    )
                    .foregroundStyle(
                        .secondary
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                }
            }
        }
    }
    
    
    private var statusTitle:
    String {
        
        if isReview {
            
            return "Review"
        }
        
        if isUpToDate {
            
            return "Up to date"
        }
        
        return "New section"
    }
    
    
    private var statusIcon:
    String {
        
        if isReview {
            
            return "arrow.clockwise"
        }
        
        if isUpToDate {
            
            return "checkmark"
        }
        
        return "book.closed"
    }
    
    
    private var summaryDescription:
    String {
        
        if isReview {
            
            return currentDueWords.count == 1
            ? "This word is ready for another review."
            : "These words are ready for another review."
        }
        
        if isUpToDate {
            
            return "No words are waiting for review right now."
        }
        
        return
        "Complete both Turkish and English prompts for every word."
    }
    
    
    // MARK: - Vocabulary
    
    private var vocabularySection:
    some View {
        
        VStack(
            alignment: .leading,
            spacing:
                AppTheme.Spacing.md
        ) {
            
            HStack {
                
                Text(
                    isReview
                    ? "Ready to review"
                    : "Vocabulary"
                )
                .font(
                    .title3.bold()
                )
                
                Spacer()
                
                Text(
                    "\(displayedWords.count)"
                )
                .font(
                    .subheadline
                )
                .foregroundStyle(
                    .secondary
                )
            }
            
            wordsList
        }
    }
    
    
    // MARK: - Words
    
    private var wordsList:
    some View {
        
        AppCard {
            
            VStack(
                spacing: 0
            ) {
                
                ForEach(
                    Array(
                        displayedWords
                            .enumerated()
                    ),
                    id:
                        \.element.id
                ) { index, word in
                    
                    wordRow(
                        word,
                        index: index
                    )
                    
                    if word.id
                        != displayedWords.last?.id {
                        
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
    
    
    private func wordRow(
        _ word: Word,
        index: Int
    ) -> some View {
        
        HStack(
            alignment: .center,
            spacing:
                AppTheme.Spacing.md
        ) {
            
            Text(
                "\(index + 1)"
            )
            .font(
                .caption
                    .weight(
                        .semibold
                    )
            )
            .foregroundStyle(
                .secondary
            )
            .frame(
                width: 26,
                height: 26
            )
            .background {
                
                Circle()
                    .fill(
                        Color.primary
                            .opacity(
                                0.05
                            )
                    )
            }
            
            
            VStack(
                alignment: .leading,
                spacing:
                    AppTheme.Spacing.xs
            ) {
                
                Text(
                    word.italian
                )
                .font(
                    .headline
                )
                
                if let turkish =
                    word.turkish,
                   !turkish.isEmpty {
                    
                    Text(
                        turkish
                    )
                    .font(
                        .subheadline
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }
            }
            
            
            Spacer()
            
            
            Text(
                "#\(word.sequenceNo)"
            )
            .font(
                .caption
            )
            .foregroundStyle(
                .tertiary
            )
        }
        .padding(
            .vertical,
            AppTheme.Spacing.sm
        )
    }
    
    
    // MARK: - Action
    
    private var actionArea: some View {
        
        VStack(
            spacing: 0
        ) {
            
            Divider()
            
            NavigationLink {
                
                QuizView(
                    section: section,
                    words: actionWords,
                    mode: actionMode
                )
                .onDisappear {
                    
                    Task {
                        await refreshSectionState()
                    }
                }
                
            } label: {
                
                HStack(
                    spacing:
                        AppTheme.Spacing.sm
                ) {
                    
                    Image(
                        systemName:
                            actionIcon
                    )
                    
                    Text(
                        actionTitle
                    )
                    .fontWeight(
                        .semibold
                    )
                }
                .frame(
                    maxWidth:
                            .infinity
                )
                .padding(
                    .vertical,
                    AppTheme.Spacing.xs
                )
            }
            .buttonStyle(
                .borderedProminent
            )
            .controlSize(
                .large
            )
            .padding(
                .horizontal,
                AppTheme.Layout
                    .horizontalPadding
            )
            .padding(
                .top,
                AppTheme.Spacing.md
            )
            .padding(
                .bottom,
                AppTheme.Spacing.sm
            )
        }
        .background(
            .bar
        )
    }
    
    
    // MARK: - Refresh
    
    @MainActor
    private func refreshSectionState()
    async {
        
        guard !isRefreshing
        else {
            return
        }
        
        isRefreshing = true
        
        defer {
            isRefreshing = false
        }
        
        
        do {
            
            let wordIds =
            section.words
                .map(\.id)
            
            let progress =
            try await wordProgressService
                .fetchProgress(
                    for: wordIds
                )
            
            
            let progressByWordId =
            Dictionary(
                uniqueKeysWithValues:
                    progress.map {
                        (
                            $0.wordId,
                            $0
                        )
                    }
            )
            
            
            let now =
            Date()
            
            var completedCount =
            0
            
            var dueCount =
            0
            
            var completedOnceCount =
            0
            
            var refreshedDueWords:
            [Word] = []
            
            
            for word in section.words {
                
                guard let item =
                        progressByWordId[
                            word.id
                        ]
                else {
                    
                    continue
                }
                
                
                if item.completedOnce {
                    
                    completedOnceCount += 1
                }
                
                
                guard item.completedOnce
                else {
                    
                    continue
                }
                
                
                if let nextReviewAt =
                    item.nextReviewAt {
                    
                    if nextReviewAt <= now {
                        
                        dueCount += 1
                        
                        refreshedDueWords
                            .append(
                                word
                            )
                        
                    } else {
                        
                        completedCount += 1
                    }
                    
                } else {
                    
                    completedCount += 1
                }
            }
            
            
            currentProgress =
            SectionProgressState(
                completedCount:
                    completedCount,
                dueCount:
                    dueCount,
                completedOnceCount:
                    completedOnceCount
            )
            
            currentDueWords =
            refreshedDueWords
            
            
            print(
                "🔄 Section \(section.number) refreshed:",
                "\(refreshedDueWords.count) due"
            )
            
        } catch {
            
            print(
                "❌ Section refresh error:",
                error
            )
        }
    }
}
