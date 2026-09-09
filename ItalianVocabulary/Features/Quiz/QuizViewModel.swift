//
//  QuizViewModel.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import Foundation
internal import Combine

@MainActor
final class QuizViewModel: ObservableObject {
    
    @Published private(set) var currentQuestion: QuizQuestion?
    
    private var failedWordIds: Set<Int> = []
    
    @Published private(set) var completedTaskCount = 0
    @Published private(set) var totalTaskCount = 0
    
    @Published private(set) var totalAttempts = 0
    @Published private(set) var wrongAttempts = 0
    
    @Published private(set) var isFinished = false
    
    private var sessionFinished = false
    
    @Published var answerText = ""
    @Published var feedback: String?
    
    private let section: WordSection
    
    private let quizWords: [Word]
    private let mode: QuizMode
    
    private let quizService = QuizService()
    
    private let wordProgressService =
    WordProgressService()
    
    private var sessionId: UUID?
    
    private var attemptOrder = 0
    
    private(set) var sessionCreationError: String?
    
    private var pendingQuestions: [QuizQuestion] = []
    private var attemptsPerQuestion: [UUID: Int] = [:]
    
    private var firstTryCorrectTaskCount = 0
    
    private var lastQuestionID: UUID?
    
    init(
        section: WordSection,
        words: [Word],
        mode: QuizMode
    ) {
        
        self.section = section
        self.quizWords = words
        self.mode = mode
        
        prepareQuiz()
    }
    private func prepareQuiz() {
        
        var questions: [QuizQuestion] = []
        
        for word in quizWords {
            
            questions.append(
                QuizQuestion(
                    id: UUID(),
                    word: word,
                    clueLanguage: .turkish
                )
            )
            
            questions.append(
                QuizQuestion(
                    id: UUID(),
                    word: word,
                    clueLanguage: .english
                )
            )
        }
        
        pendingQuestions = questions.shuffled()
        totalTaskCount = questions.count
        
        chooseNextQuestion()
    }
    
    private func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .folding(
                options: [
                    .caseInsensitive,
                    .diacriticInsensitive
                ],
                locale: .current
            )
    }
    
    func submitAnswer() async {
        
        guard let question = currentQuestion else {
            return
        }
        
        guard let sessionId else {
            return
        }
        
        let rawAnswer = answerText
        
        let normalizedAnswer =
        normalize(rawAnswer)
        
        let normalizedCorrect =
        normalize(question.correctAnswer)
        
        totalAttempts += 1
        attemptOrder += 1
        
        let attemptNumber =
        (attemptsPerQuestion[question.id] ?? 0)
        + 1
        
        attemptsPerQuestion[question.id] =
        attemptNumber
        
        let isCorrect =
        normalizedAnswer == normalizedCorrect
        
        let classification =
        AnswerClassifier.classify(
            userAnswer: rawAnswer,
            correctAnswer:
                question.correctAnswer,
            allWords: section.words
        )
        
        let isFirstTryCorrect =
        isCorrect && attemptNumber == 1
        
        if isCorrect {
            
            feedback = "Esatto!"
            
            if isFirstTryCorrect {
                firstTryCorrectTaskCount += 1
            }
            
            pendingQuestions.removeAll {
                $0.id == question.id
            }
            
            completedTaskCount += 1
            
        } else {

    failedWordIds.insert(
        question.word.id
    )

    if rawAnswer
        .trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        .isEmpty {

        feedback =
            "Non ricordato — \(question.correctAnswer)"

    } else {

        feedback =
            "Sbagliato — \(question.correctAnswer)"
    }

    wrongAttempts += 1
}
        
        do {
            
            try await quizService.saveAttempt(
                sessionId: sessionId,
                wordId: question.word.id,
                clueLanguage:
                    question.clueLanguage,
                userAnswer: rawAnswer,
                isCorrect: isCorrect,
                errorType:
                    classification.errorType,
                similarityScore:
                    classification.similarityScore,
                confusedWithWordId:
                    classification.confusedWithWordId,
                attemptOrder: attemptOrder,
                attemptNumber: attemptNumber,
                isFirstTryCorrect:
                    isFirstTryCorrect
            )
            
            print(
                "✅ Attempt saved:",
                attemptOrder
            )
            
        } catch {
            
            print(
                "❌ Attempt save failed:",
                error
            )
        }
    }
    
    func continueQuiz() async {
        
        answerText = ""
        feedback = nil
        
        if pendingQuestions.isEmpty {
            
            await finishSessionIfNeeded()
            
            isFinished = true
            currentQuestion = nil
            
            return
        }
        
        chooseNextQuestion()
    }
    
    private func chooseNextQuestion() {
        
        guard !pendingQuestions.isEmpty else {
            isFinished = true
            currentQuestion = nil
            return
        }
        
        var candidates = pendingQuestions
        
        if
            let lastQuestionID,
            candidates.count > 1
        {
            
            candidates.removeAll {
                $0.id == lastQuestionID
            }
        }
        
        guard let selected =
                candidates.randomElement()
        else {
            return
        }
        
        currentQuestion = selected
        lastQuestionID = selected.id
    }
    
    var progressText: String {
        "\(completedTaskCount) / \(totalTaskCount)"
    }
    
    var sectionPassed: Bool {
        
        firstTryCorrectTaskCount
        == totalTaskCount
    }
    
    var result: QuizResult {
        
        QuizResult(
            sectionNumber: section.number,
            totalWords: quizWords.count,
            totalTasks: totalTaskCount,
            totalAttempts: totalAttempts,
            wrongAttempts: wrongAttempts,
            firstTryCorrectTasks:
                firstTryCorrectTaskCount,
            passed: sectionPassed,
            mode: mode,
            failedWords: failedWordIds.count
        )
    }
    func startSessionIfNeeded() async {
        
        guard sessionId == nil else {
            return
        }
        
        do {
            
            sessionId = try await quizService
                .createSectionSession(
                    sectionNumber: section.number,
                    totalWords: quizWords.count,
                    mode: mode
                )
            
            print(
                "✅ Quiz session created:",
                sessionId!
            )
            
        } catch {
            
            sessionCreationError =
            error.localizedDescription
            
            print(
                "❌ Session creation error:",
                error
            )
        }
    }
    
    func finishSessionIfNeeded() async {
        
        guard !sessionFinished else {
            return
        }
        
        guard let sessionId else {
            return
        }
        
        sessionFinished = true
        
        do {
            
            // 1. Quiz session'ı kapat
            try await quizService.finishSession(
                sessionId: sessionId,
                passedWords:
                    sectionPassed
                ? quizWords.count
                : 0,
                hadAnyError:
                    wrongAttempts > 0,
                passed:
                    sectionPassed
            )
            
            print("✅ Quiz session finished")
            
            
            // 2. İlk section quiz'i kusursuz geçtiyse
            // ilk progress kayıtlarını oluştur
            if sectionPassed,
               mode == .initialSection {
                
                try await wordProgressService
                    .completeInitialSection(
                        words: quizWords
                    )
                
                print(
                    "✅ Initial word progress created:",
                    quizWords.count
                )
            }
            
            
            // 3. Review ise her kelimenin
            // mastery/progress durumunu ayrı ayrı güncelle
            if mode == .sectionReview {
                
                try await updateReviewProgress()
                
                print(
                    "✅ Review progress updated:",
                    quizWords.count
                )
            }
            
            if mode == .freePractice {
                
                try await updateFreePracticeProgress()
                
                print(
                    "✅ Free practice progress checked:",
                    quizWords.count
                )
            }
            
        } catch {
            
            sessionFinished = false
            
            print(
                "❌ Quiz completion error:",
                error
            )
        }
    }
    
    private func updateReviewProgress()
    async throws {
        
        let wordIds =
        quizWords.map(\.id)
        
        let existingProgress =
        try await wordProgressService
            .fetchProgress(
                for: wordIds
            )
        
        for progress in existingProgress {
            
            let passed =
            !failedWordIds.contains(
                progress.wordId
            )
            
            try await wordProgressService
                .updateAfterReview(
                    progress: progress,
                    passed: passed
                )
            
            print(
                passed
                ? "✅ Review passed word \(progress.wordId)"
                : "🔁 Review failed word \(progress.wordId)"
            )
        }
    }
    
    private func updateFreePracticeProgress()
    async throws {
        
        let wordIds =
        quizWords.map(\.id)
        
        let existingProgress =
        try await wordProgressService
            .fetchProgress(
                for: wordIds
            )
        
        for progress in existingProgress {
            
            let failed =
            failedWordIds.contains(
                progress.wordId
            )
            
            // Doğru bilinen kelime:
            // mastery / streak / next review değişmez.
            guard failed else {
                
                print(
                    "✅ Free practice correct:",
                    "word \(progress.wordId)",
                    "— SRS unchanged"
                )
                
                continue
            }
            
            // Free Practice sırasında bir kez bile
            // yanlış yapıldıysa normal failure
            // davranışını uygula.
            try await wordProgressService
                .updateAfterReview(
                    progress: progress,
                    passed: false
                )
            
            print(
                "🔁 Free practice failed:",
                "word \(progress.wordId)",
                "— reset and due now"
            )
        }
    }
}
