//
//  SectionDetailView.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//
import SwiftUI

struct SectionDetailView: View {
    
    let section: WordSection
    let progress: SectionProgressState
    let dueWords: [Word]
    
    
    // MARK: - State
    
    private var isReview: Bool {
        !dueWords.isEmpty
    }
    
    private var displayedWords: [Word] {
        isReview
        ? dueWords
        : section.words
    }
    
    private var wordCountText: String {
        
        if isReview {
            
            return dueWords.count == 1
            ? "1 word to review"
            : "\(dueWords.count) words to review"
        }
        
        return "15 words"
    }
    
    private var actionTitle: String {
        
        if isReview {
            
            return dueWords.count == 1
            ? "Review 1 Word"
            : "Review \(dueWords.count) Words"
        }
        
        return "Start Section"
    }
    
    
    // MARK: - Body
    
    var body: some View {
        
        ScrollView {
            
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.lg
            ) {
                
                summaryCard
                
                vocabularySection
            }
            .padding(
                .horizontal,
                AppTheme.Layout.horizontalPadding
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
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            
            actionArea
        }
    }
    
    
    // MARK: - Summary
    
    private var summaryCard: some View {
        
        AppCard {
            
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.md
            ) {
                
                HStack {
                    
                    StatusBadge(
                        isReview
                        ? "Review"
                        : "New section",
                        systemImage:
                            isReview
                        ? "arrow.clockwise"
                        : "book.closed"
                    )
                    
                    Spacer()
                    
                    if !isReview {
                        
                        Text(
                            "\(progress.completedCount) / 15"
                        )
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    }
                }
                
                VStack(
                    alignment: .leading,
                    spacing: AppTheme.Spacing.xs
                ) {
                    
                    Text(wordCountText)
                        .font(.title2.bold())
                    
                    Text(summaryDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }
            }
        }
    }
    
    private var summaryDescription: String {
        
        if isReview {
            
            return dueWords.count == 1
            ? "This word is ready for another review."
            : "These words are ready for another review."
        }
        
        return
        "Complete both Turkish and English prompts for every word."
    }
    
    
    // MARK: - Vocabulary
    
    private var vocabularySection: some View {
        
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {
            
            HStack {
                
                Text(
                    isReview
                    ? "Ready to review"
                    : "Vocabulary"
                )
                .font(.title3.bold())
                
                Spacer()
                
                Text(
                    "\(displayedWords.count)"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            
            wordsList
        }
    }
    
    
    // MARK: - Words
    
    private var wordsList: some View {
        
        AppCard {
            
            VStack(spacing: 0) {
                
                ForEach(
                    Array(displayedWords.enumerated()),
                    id: \.element.id
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
            spacing: AppTheme.Spacing.md
        ) {
            
            Text(
                "\(index + 1)"
            )
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(
                width: 26,
                height: 26
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
                
                Text(word.italian)
                    .font(.headline)
                
                if let turkish = word.turkish,
                   !turkish.isEmpty {
                    
                    Text(turkish)
                        .font(.subheadline)
                        .foregroundStyle(
                            .secondary
                        )
                }
            }
            
            Spacer()
            
            Text(
                "#\(word.sequenceNo)"
            )
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
        .padding(
            .vertical,
            AppTheme.Spacing.sm
        )
    }
    
    
    // MARK: - Action
    
    private var actionArea: some View {
        
        VStack(spacing: 0) {
            
            Divider()
            
            NavigationLink {
                
                QuizView(
                    section: section,
                    words: displayedWords,
                    mode:
                        isReview
                    ? .sectionReview
                    : .initialSection
                )
                
            } label: {
                
                HStack(
                    spacing: AppTheme.Spacing.sm
                ) {
                    
                    Image(
                        systemName:
                            isReview
                        ? "arrow.clockwise"
                        : "play.fill"
                    )
                    
                    Text(actionTitle)
                        .fontWeight(.semibold)
                }
                .frame(
                    maxWidth: .infinity
                )
                .padding(
                    .vertical,
                    AppTheme.Spacing.xs
                )
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(
                .horizontal,
                AppTheme.Layout.horizontalPadding
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
}
