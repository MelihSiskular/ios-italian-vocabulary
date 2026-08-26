//
//  QuizResultView.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//
import SwiftUI

struct QuizResultView: View {
    
    @State private var didPlayHaptic = false
    
    let result: QuizResult
    
    @Environment(\.dismiss)
    private var dismiss
    
    
    // MARK: - State
    
    private var isReview: Bool {
        result.mode == .sectionReview
    }
    
    private var refreshedWords: Int {
        max(
            result.totalWords - result.failedWords,
            0
        )
    }
    
    
    // MARK: - Body
    
    var body: some View {
        
        ScrollView {
            
            VStack(
                spacing: AppTheme.Spacing.xl
            ) {
                
                Spacer(minLength: 44)
                
                resultIcon
                
                resultMessage
                
                statsCard
                
                if isReview {
                    reviewSummary
                }
                
                Spacer(minLength: 24)
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
        .safeAreaInset(edge: .bottom) {
            
            actionArea
        }
        .onAppear {
            
            guard !didPlayHaptic else {
                return
            }
            
            didPlayHaptic = true
            
            if result.mode == .sectionReview {
                
                if result.failedWords == 0 {
                    HapticManager.success()
                }
                
            } else if result.passed {
                
                HapticManager.success()
            }
        }
    }
    
    
    
    // MARK: - Icon
    
    private var resultIcon: some View {
        
        Image(
            systemName: resultIconName
        )
        .font(
            .system(
                size: 54,
                weight: .semibold
            )
        )
        .foregroundStyle(
            resultIconUsesAccent
            ? AppTheme.Colors.accent
            : .secondary
        )
        .frame(
            width: 92,
            height: 92
        )
        .background(
            Circle()
                .fill(
                    AppTheme.Colors.cardBackground
                )
        )
    }
    
    private var resultIconName: String {
        
        if isReview {
            return result.failedWords == 0
            ? "checkmark"
            : "arrow.clockwise"
        }
        
        return result.passed
        ? "checkmark"
        : "arrow.clockwise"
    }
    
    private var resultIconUsesAccent: Bool {
        
        if isReview {
            return result.failedWords == 0
        }
        
        return result.passed
    }
    
    
    // MARK: - Message
    
    private var resultMessage: some View {
        
        VStack(
            spacing: AppTheme.Spacing.sm
        ) {
            
            Text(resultTitle)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            Text(resultDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
        }
        .padding(
            .horizontal,
            AppTheme.Spacing.md
        )
    }
    
    private var resultTitle: String {
        
        if isReview {
            return "Review Complete"
        }
        
        return result.passed
        ? "Section Completed"
        : "Almost There"
    }
    
    private var resultDescription: String {
        
        if isReview {
            
            if result.failedWords == 0 {
                
                return result.totalWords == 1
                ? "Your reviewed word is up to date."
                : "All \(result.totalWords) reviewed words are up to date."
            }
            
            if result.failedWords == 1 {
                
                return
                "\(refreshedWords) refreshed. 1 word remains due for another review."
            }
            
            return
            "\(refreshedWords) refreshed. \(result.failedWords) words remain due for another review."
        }
        
        if result.passed {
            
            return
            "Perfect run. All \(result.totalWords) words were answered correctly on the first try."
        }
        
        return
        "You finished the section, but \(result.wrongAttempts) first-try mistake\(result.wrongAttempts == 1 ? "" : "s") kept it from being completed."
    }
    
    
    // MARK: - Stats
    
    private var statsCard: some View {
        
        AppCard {
            
            VStack(
                spacing: AppTheme.Spacing.md
            ) {
                
                resultRow(
                    "Tasks",
                    "\(result.totalTasks)"
                )
                
                Divider()
                
                resultRow(
                    "Attempts",
                    "\(result.totalAttempts)"
                )
                
                Divider()
                
                resultRow(
                    "First try",
                    "\(result.firstTryCorrectTasks) / \(result.totalTasks)"
                )
                
                if result.wrongAttempts > 0 {
                    
                    Divider()
                    
                    resultRow(
                        "Mistakes",
                        "\(result.wrongAttempts)"
                    )
                }
            }
        }
    }
    
    
    // MARK: - Review Summary
    
    private var reviewSummary: some View {
        
        AppCard {
            
            HStack(
                spacing: AppTheme.Spacing.md
            ) {
                
                Image(
                    systemName:
                        result.failedWords == 0
                    ? "checkmark.circle.fill"
                    : "clock.arrow.circlepath"
                )
                .font(.title3)
                .foregroundStyle(
                    result.failedWords == 0
                    ? AppTheme.Colors.accent
                    : .secondary
                )
                
                VStack(
                    alignment: .leading,
                    spacing: AppTheme.Spacing.xs
                ) {
                    
                    Text(
                        result.failedWords == 0
                        ? "Up to date"
                        : "Still due"
                    )
                    .font(.headline)
                    
                    Text(reviewSummaryText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
        }
    }
    
    private var reviewSummaryText: String {
        
        if result.failedWords == 0 {
            return "No more reviews are due from this session."
        }
        
        if result.failedWords == 1 {
            return "1 word will stay in your review queue."
        }
        
        return
        "\(result.failedWords) words will stay in your review queue."
    }
    
    
    // MARK: - Action
    
    private var actionArea: some View {
        
        VStack(spacing: 0) {
            
            Divider()
            
            Button {
                
                dismiss()
                
            } label: {
                
                Text(
                    isReview
                    ? "Back to Section"
                    : result.passed
                    ? "Done"
                    : "Back to Section"
                )
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
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
        .background(.bar)
    }
    
    
    // MARK: - Row
    
    private func resultRow(
        _ title: String,
        _ value: String
    ) -> some View {
        
        HStack {
            
            Text(title)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
        }
    }
}
