//
//  QuizView.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import SwiftUI

struct QuizView: View {
    
    @StateObject private var viewModel:
    QuizViewModel
    
    @FocusState private var isAnswerFocused: Bool
    
    @State private var actionTitle = "Check"
    
    @State private var isFinalizingQuiz = false
    
    init(
        section: WordSection,
        words: [Word],
        mode: QuizMode
    ) {
        
        _viewModel = StateObject(
            wrappedValue:
                QuizViewModel(
                    section: section,
                    words: words,
                    mode: mode
                )
        )
    }
    
    
    // MARK: - Body
    
    var body: some View {
        
        ZStack {
            
            Group {
                
                if viewModel.isFinished {
                    
                    QuizResultView(
                        result: viewModel.result
                    )
                    
                } else if let question =
                            viewModel.currentQuestion {
                    
                    questionView(question)
                }
            }
            .blur(
                radius:
                    isFinalizingQuiz
                ? 3
                : 0
            )
            .allowsHitTesting(
                !isFinalizingQuiz
            )
            
            
            if isFinalizingQuiz {
                
                finalizingOverlay
                    .transition(
                        .opacity
                    )
            }
        }
        .animation(
            .easeInOut(
                duration: 0.18
            ),
            value:
                isFinalizingQuiz
        )
        .navigationBarBackButtonHidden(
            !viewModel.isFinished
        )
        .toolbar(
            .hidden,
            for: .tabBar
        )
        .task {
            
            await viewModel
                .startSessionIfNeeded()
        }
    }
    
    
    // MARK: - Question
    
    private func questionView(
        _ question: QuizQuestion
    ) -> some View {
        
        VStack(spacing: 0) {
            
            ScrollView {
                
                VStack(
                    alignment: .leading,
                    spacing: AppTheme.Spacing.xl
                ) {
                    
                    progressHeader
                    
                    promptSection(
                        question
                    )
                    
                    answerField
                    
                    if let feedback =
                        viewModel.feedback {
                        
                        feedbackCard(
                            feedback,
                            question: question
                        )
                    }
                }
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
                    AppTheme.Spacing.xxl
                )
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle(
            "Section \(question.word.sectionNumber)"
        )
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(
            edge: .bottom
        ) {
            
            actionArea
        }
        .onAppear {
            
            if viewModel.feedback == nil {
                isAnswerFocused = true
            }
        }
        .onChange(
            of: viewModel.currentQuestion?.id
        ) { _, _ in
            
            if viewModel.feedback == nil {
                
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.15
                ) {
                    isAnswerFocused = true
                }
            }
        }
    }
    
    
    // MARK: - Progress
    
    private var progressHeader: some View {
        
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {
            
            HStack {
                
                Text(
                    viewModel.progressText
                )
                .font(
                    .subheadline.weight(
                        .semibold
                    )
                )
                
                Spacer()
                
                Text("Progress")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(
                value: Double(
                    viewModel.completedTaskCount
                ),
                total: Double(
                    max(
                        viewModel.totalTaskCount,
                        1
                    )
                )
            )
            .tint(
                AppTheme.Colors.accent
            )
        }
    }
    
    
    // MARK: - Prompt
    
    private func promptSection(
        _ question: QuizQuestion
    ) -> some View {
        
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {
            
            StatusBadge(
                question.clueLanguage.title,
                systemImage:
                    question.clueLanguage == .turkish
                ? "character.book.closed"
                : "textformat"
            )
            
            Text(question.clue)
                .font(
                    .system(
                        size: 38,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
            
            Text(
                "Write the Italian word."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(
            .top,
            AppTheme.Spacing.lg
        )
    }
    
    
    // MARK: - Answer
    
    private var answerField: some View {
        
        TextField(
            "Italian word",
            text: $viewModel.answerText
        )
        .focused($isAnswerFocused)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .submitLabel(
            viewModel.feedback == nil
            ? .done
            : .next
        )
        .font(.title3)
        .padding(
            .horizontal,
            AppTheme.Spacing.md
        )
        .frame(
            minHeight: 54
        )
        .background(
            RoundedRectangle(
                cornerRadius:
                    AppTheme.Radius.medium,
                style: .continuous
            )
            .fill(
                AppTheme.Colors.cardBackground
            )
        )
        .overlay {
            
            RoundedRectangle(
                cornerRadius:
                    AppTheme.Radius.medium,
                style: .continuous
            )
            .stroke(
                answerFieldBorder,
                lineWidth: 1
            )
        }
        .disabled(
            viewModel.feedback != nil
        )
        .onSubmit {
            
            if viewModel.feedback == nil {
                
                Task {
                    await submitAnswer()
                }
                
            } else {

                Task {
                    await continueQuiz()
                }
            }
        }
    }
    
    private var answerFieldBorder: Color {
        
        guard let feedback =
                viewModel.feedback
        else {
            
            return AppTheme.Colors.border
        }
        
        if feedback.hasPrefix("Esatto") {
            
            return AppTheme.Colors.accent
                .opacity(0.35)
        }
        
        return Color.primary.opacity(0.14)
    }
    
    
    // MARK: - Feedback
    
    private func feedbackCard(
        _ feedback: String,
        question: QuizQuestion
    ) -> some View {
        
        AppCard {
            
            HStack(
                alignment: .top,
                spacing: AppTheme.Spacing.md
            ) {
                
                Image(
                    systemName:
                        feedback.hasPrefix("Esatto")
                    ? "checkmark.circle.fill"
                    : "exclamationmark.circle"
                )
                .font(.title3)
                .foregroundStyle(
                    feedback.hasPrefix("Esatto")
                    ? AppTheme.Colors.accent
                    : .secondary
                )
                
                
                VStack(
                    alignment: .leading,
                    spacing: AppTheme.Spacing.sm
                ) {
                    
                    Text(
                        feedbackTitle(
                            feedback
                        )
                    )
                    .font(.headline)
                    
                    
                    if !feedback.hasPrefix(
                        "Esatto"
                    ) {
                        
                        Text(
                            question.correctAnswer
                        )
                        .font(
                            .title3.weight(
                                .semibold
                            )
                        )
                    }
                    
                    
                    if let example =
                        question.word.example1It,
                       !example.isEmpty {
                        
                        Divider()
                        
                        Text(example)
                            .font(.subheadline)
                            .foregroundStyle(
                                .secondary
                            )
                    }
                }
                
                
                Spacer()
                
                
                Button {
                    
                    PronunciationService
                        .shared
                        .speakItalian(
                            question.word.italian
                        )
                    
                } label: {
                    
                    Image(
                        systemName:
                            "speaker.wave.2.fill"
                    )
                    .font(.title3)
                    .frame(
                        width: 44,
                        height: 44
                    )
                    .contentShape(
                        Rectangle()
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    "Pronounce \(question.word.italian)"
                )
            }
        }
    }
    
    private func feedbackTitle(
        _ feedback: String
    ) -> String {
        
        if feedback.hasPrefix(
            "Esatto"
        ) {
            return "Esatto"
        }
        
        if feedback.hasPrefix(
            "Non ricordato"
        ) {
            return "Not recalled"
        }
        
        return "Correct answer"
    }
    
    
    // MARK: - Action Area
    
    private var actionArea: some View {
        
        VStack(spacing: 0) {
            
            Divider()
            
            Button {
                
                if viewModel.feedback == nil {
                    
                    Task {
                        await submitAnswer()
                    }
                    
                } else {

                    Task {
                        await continueQuiz()
                    }
                }
                
            } label: {
                
                ZStack {
                    
                    // CHECK STATE
                    Text("Check")
                        .fontWeight(.semibold)
                        .opacity(
                            actionTitle == "Check"
                            ? 1
                            : 0
                        )
                        .scaleEffect(
                            actionTitle == "Check"
                            ? 1
                            : 0.96
                        )
                    
                    
                    // CONTINUE STATE
                    HStack(
                        spacing: AppTheme.Spacing.sm
                    ) {
                        
                        Text("Continue")
                            .fontWeight(.semibold)
                        
                        Image(
                            systemName: "arrow.right"
                        )
                    }
                    .opacity(
                        actionTitle == "Continue"
                        ? 1
                        : 0
                    )
                    .scaleEffect(
                        actionTitle == "Continue"
                        ? 1
                        : 0.96
                    )
                }
                .animation(
                    .easeInOut(duration: 0.18),
                    value: actionTitle
                )
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
    
    
    // MARK: - Actions
    
    private func submitAnswer() async {
        
        isAnswerFocused = false
        
        await viewModel.submitAnswer()
        
        if let feedback =
            viewModel.feedback {
            
            if feedback.hasPrefix(
                "Esatto"
            ) {
                
                HapticManager.success()
                
            } else {
                
                HapticManager.error()
            }
        }
        
        try? await Task.sleep(
            for: .milliseconds(260)
        )
        
        withAnimation(
            .easeInOut(duration: 0.18)
        ) {
            actionTitle = "Continue"
        }
    }
    
    private func continueQuiz() async {
        
        let isLastQuestion =
        viewModel.totalTaskCount > 0
        &&
        viewModel.completedTaskCount
        == viewModel.totalTaskCount
        
        
        if isLastQuestion {
            
            withAnimation(
                .easeInOut(
                    duration: 0.18
                )
            ) {
                
                isFinalizingQuiz = true
            }
        }
        
        
        await viewModel
            .continueQuiz()
        
        
        if viewModel.isFinished {
            
            withAnimation(
                .easeInOut(
                    duration: 0.18
                )
            ) {
                
                isFinalizingQuiz = false
            }
            
            return
        }
        
        
        DispatchQueue.main.asyncAfter(
            deadline:
                    .now() + 0.12
        ) {
            
            isAnswerFocused = true
        }
        
        
        DispatchQueue.main.asyncAfter(
            deadline:
                    .now() + 0.32
        ) {
            
            withAnimation(
                .easeInOut(
                    duration: 0.18
                )
            ) {
                
                actionTitle = "Check"
            }
        }
    }
    
    // MARK: - Finalizing
    
    private var finalizingOverlay:
    some View {
        
        VStack(
            spacing:
                AppTheme.Spacing.md
        ) {
            
            ProgressView()
                .controlSize(
                    .large
                )
            
            
            Text(
                "Updating review..."
            )
            .font(
                .headline
            )
            
            
            Text(
                "Saving your progress."
            )
            .font(
                .subheadline
            )
            .foregroundStyle(
                .secondary
            )
        }
        .padding(
            AppTheme.Spacing.xl
        )
        .background(
            .regularMaterial,
            in:
                RoundedRectangle(
                    cornerRadius: 22,
                    style: .continuous
                )
        )
    }
}
