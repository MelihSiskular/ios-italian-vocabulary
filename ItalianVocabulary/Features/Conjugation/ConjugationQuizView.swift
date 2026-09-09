//
//  ConjugationQuizView.swift
//  ItalianVocabulary
//

import SwiftUI


struct ConjugationQuizView:
    View {
    
    @StateObject private var
viewModel:
    ConjugationQuizViewModel
    
    @FocusState private var
    isAnswerFocused: Bool
    
    @Environment(\.dismiss)
    private var dismiss
    
    init(
        sectionNumber: Int,
        items: [ConjugationVerbItem],
        tense: ConjugationTense
    ) {
        
        _viewModel =
        StateObject(
            wrappedValue:
                ConjugationQuizViewModel(
                    sectionNumber:
                        sectionNumber,
                    items:
                        items,
                    tense:
                        tense
                )
        )
    }
    
    
    var body: some View {
        
        Group {
            
            if viewModel.isFinished {
                
                resultView
                
            } else if let question =
                        viewModel
                .currentQuestion {
                
                questionView(
                    question
                )
            }
        }
        .toolbar(
            .hidden,
            for: .tabBar
        )
    }
    
    
    // MARK: - Question
    
    private func questionView(
        _ question:
        ConjugationQuestion
    ) -> some View {
        
        VStack(
            spacing: 0
        ) {
            
            ScrollView {
                
                VStack(
                    alignment: .leading,
                    spacing:
                        AppTheme.Spacing.xl
                ) {
                    
                    progressHeader
                    
                    verbPrompt(
                        question
                    )
                    
                    answerField
                    
                    if let feedback =
                        viewModel.feedback {
                        
                        feedbackCard(
                            feedback
                        )
                    }
                }
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
                    AppTheme.Spacing.xxl
                )
            }
            .scrollDismissesKeyboard(
                .interactively
            )
        }
        .navigationTitle(
            viewModel.tense.title
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
        .navigationBarBackButtonHidden(
            true
        )
        .safeAreaInset(
            edge: .bottom
        ) {
            
            actionArea
        }
        .onAppear {
            
            if viewModel.feedback == nil {
                
                isAnswerFocused =
                true
            }
        }
        .onChange(
            of:
                viewModel
                .currentQuestion?.id
        ) { _, _ in
            
            if viewModel.feedback == nil {
                
                DispatchQueue
                    .main
                    .asyncAfter(
                        deadline:
                                .now() + 0.15
                    ) {
                        
                        isAnswerFocused =
                        true
                    }
            }
        }
    }
    
    
    // MARK: - Progress
    
    private var progressHeader:
    some View {
        
        VStack(
            spacing:
                AppTheme.Spacing.sm
        ) {
            
            HStack {
                
                Text(
                    viewModel
                        .progressText
                )
                .font(
                    .subheadline.weight(
                        .semibold
                    )
                )
                
                Spacer()
                
                Text(
                    "Progress"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            
            ProgressView(
                value:
                    Double(
                        viewModel
                            .completedTaskCount
                    ),
                total:
                    Double(
                        max(
                            viewModel
                                .totalTaskCount,
                            1
                        )
                    )
            )
        }
    }
    
    
    // MARK: - Prompt
    
    private func verbPrompt(
        _ question:
        ConjugationQuestion
    ) -> some View {
        
        VStack(
            alignment: .leading,
            spacing:
                AppTheme.Spacing.lg
        ) {
            
            VStack(
                alignment: .leading,
                spacing:
                    AppTheme.Spacing.xs
            ) {
                
                Text(
                    question.word.italian
                )
                .font(
                    .system(
                        size: 36,
                        weight: .bold,
                        design: .rounded
                    )
                )
                
                
                if let english =
                    question.word.english,
                   !english.isEmpty {
                    
                    Text(english)
                        .font(.title3)
                        .foregroundStyle(
                            .secondary
                        )
                }
                
                
                if let turkish =
                    question.word.turkish,
                   !turkish.isEmpty {
                    
                    Text(turkish)
                        .font(
                            .subheadline
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
                    "Conjugate for"
                )
                .font(
                    .caption.weight(
                        .semibold
                    )
                )
                .foregroundStyle(
                    .secondary
                )
                
                
                Text(
                    question
                        .person
                        .title
                )
                .font(
                    .system(
                        size: 30,
                        weight: .bold,
                        design: .rounded
                    )
                )
            }
            .frame(
                maxWidth:
                        .infinity,
                alignment:
                        .leading
            )
            .padding(
                AppTheme.Spacing.lg
            )
            .background(
                RoundedRectangle(
                    cornerRadius: 22,
                    style: .continuous
                )
                .fill(
                    Color(
                        .secondarySystemBackground
                    )
                )
            )
        }
    }
    
    
    // MARK: - Answer
    
    private var answerField:
    some View {
        
        VStack(
            alignment: .leading,
            spacing:
                AppTheme.Spacing.xs
        ) {
            
            Text(
                "Your answer"
            )
            .font(
                .caption.weight(
                    .semibold
                )
            )
            .foregroundStyle(
                .secondary
            )
            
            
            TextField(
                "Italian conjugation",
                text:
                    $viewModel.answerText
            )
            .textInputAutocapitalization(
                .never
            )
            .autocorrectionDisabled()
            .textFieldStyle(
                .roundedBorder
            )
            .font(
                .title3
            )
            .focused(
                $isAnswerFocused
            )
            .submitLabel(
                .done
            )
            .disabled(
                viewModel.feedback
                != nil
            )
            .onSubmit {
                
                guard viewModel.feedback
                        == nil
                else {
                    return
                }
                
                viewModel.submitAnswer()
                
                isAnswerFocused =
                false
            }
        }
    }
    
    
    // MARK: - Feedback
    
    private func feedbackCard(
        _ feedback: String
    ) -> some View {
        
        AppCard {
            
            Text(feedback)
                .font(
                    .headline
                )
                .frame(
                    maxWidth:
                            .infinity,
                    alignment:
                            .leading
                )
        }
    }
    
    
    // MARK: - Action
    
    private var actionArea:
    some View {
        
        VStack(
            spacing: 0
        ) {
            
            Divider()
            
            
            Button {
                
                if viewModel.feedback
                    == nil {
                    
                    viewModel
                        .submitAnswer()
                    
                    isAnswerFocused =
                    false
                    
                } else {
                    
                    viewModel
                        .continueQuiz()
                }
                
            } label: {
                
                Text(
                    viewModel.feedback
                    == nil
                    ? "Check"
                    : "Continue"
                )
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
            .controlSize(
                .large
            )
            .disabled(
                viewModel.feedback
                == nil
                &&
                viewModel.answerText
                    .trimmingCharacters(
                        in:
                                .whitespacesAndNewlines
                    )
                    .isEmpty
            )
            .padding(
                .horizontal,
                AppTheme.Layout
                    .horizontalPadding
            )
            .padding(
                .vertical,
                AppTheme.Spacing.md
            )
        }
        .background(
            .bar
        )
    }
    
    
    // MARK: - Result
    
    private var resultView:
    some View {
        
        VStack(
            spacing:
                AppTheme.Spacing.xl
        ) {
            
            Spacer()
            
            
            Image(
                systemName:
                    viewModel
                    .isPerfectRun
                ? "checkmark.circle.fill"
                : "checkmark.circle"
            )
            .font(
                .system(
                    size: 70
                )
            )
            
            
            Text(
                viewModel
                    .isPerfectRun
                ? "Perfect Run"
                : "Practice Completed"
            )
            .font(
                .largeTitle.bold()
            )
            
            
            Text(
                viewModel
                    .isPerfectRun
                ? "All 30 conjugations were correct on the first try."
                : "You completed all conjugation questions."
            )
            .font(
                .subheadline
            )
            .foregroundStyle(
                .secondary
            )
            
            
            AppCard {
                
                VStack(
                    spacing:
                        AppTheme.Spacing.md
                ) {
                    
                    resultRow(
                        "Questions",
                        "\(viewModel.totalTaskCount)"
                    )
                    
                    Divider()
                    
                    resultRow(
                        "Attempts",
                        "\(viewModel.totalAttempts)"
                    )
                    
                    Divider()
                    
                    resultRow(
                        "First try",
                        "\(viewModel.firstTryCorrectTaskCount) / \(viewModel.totalTaskCount)"
                    )
                    
                    Divider()
                    
                    resultRow(
                        "Mistakes",
                        "\(viewModel.wrongAttempts)"
                    )
                }
            }
            
            Button {
                
                dismiss()
                
            } label: {
                
                Text(
                    "Back to Section"
                )
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
            .controlSize(
                .large
            )
            
            
            Spacer()
        }
        .padding(
            AppTheme.Layout
                .horizontalPadding
        )
        .navigationTitle(
            "Results"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
        .navigationBarBackButtonHidden()
    }
    
    
    private func resultRow(
        _ title: String,
        _ value: String
    ) -> some View {
        
        HStack {
            
            Text(title)
                .foregroundStyle(
                    .secondary
                )
            
            Spacer()
            
            Text(value)
                .fontWeight(
                    .semibold
                )
        }
    }
}
