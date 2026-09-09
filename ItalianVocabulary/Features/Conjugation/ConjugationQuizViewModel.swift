//
//  ConjugationQuizViewModel.swift
//  ItalianVocabulary
//

import Foundation
internal import Combine


@MainActor
final class ConjugationQuizViewModel:
    ObservableObject {
    
    @Published private(set) var
currentQuestion:
    ConjugationQuestion?
    
    @Published private(set) var
    completedTaskCount = 0
    
    @Published private(set) var
    totalTaskCount = 0
    
    @Published private(set) var
    totalAttempts = 0
    
    @Published private(set) var
    wrongAttempts = 0
    
    @Published private(set) var
    firstTryCorrectTaskCount = 0
    
    @Published private(set) var
    isFinished = false
    
    @Published var answerText = ""
    
    @Published var feedback:
    String?
    
    
    let sectionNumber: Int
    let tense:
    ConjugationTense
    
    
    private var pendingQuestions:
    [ConjugationQuestion] = []
    
    private var attemptsPerQuestion:
    [UUID: Int] = [:]
    
    private var lastQuestionID:
    UUID?
    
    
    init(
        sectionNumber: Int,
        items: [ConjugationVerbItem],
        tense: ConjugationTense
    ) {
        
        self.sectionNumber =
        sectionNumber
        
        self.tense =
        tense
        
        prepareQuiz(
            items: items
        )
    }
    
    
    // MARK: - Prepare
    
    private func prepareQuiz(
        items: [ConjugationVerbItem]
    ) {
        
        var questions:
        [ConjugationQuestion] = []
        
        
        for item in items {
            
            guard
                item.isReady,
                let conjugation =
                    item.conjugation
            else {
                continue
            }
            
            
            for person in
                    ConjugationPerson
                .allCases {
                
                guard let answer =
                        person.answer(
                            from:
                                conjugation
                        )?
                    .trimmingCharacters(
                        in:
                                .whitespacesAndNewlines
                    ),
                      !answer.isEmpty
                else {
                    continue
                }
                
                
                questions.append(
                    ConjugationQuestion(
                        id: UUID(),
                        word:
                            item.word,
                        person:
                            person,
                        correctAnswer:
                            answer
                    )
                )
            }
        }
        
        
        pendingQuestions =
        questions.shuffled()
        
        totalTaskCount =
        questions.count
        
        
        chooseNextQuestion()
    }
    
    
    // MARK: - Answer
    
    func submitAnswer() {
        
        guard let question =
                currentQuestion
        else {
            return
        }
        
        
        let attemptNumber =
        (
            attemptsPerQuestion[
                question.id
            ]
            ?? 0
        ) + 1
        
        attemptsPerQuestion[
            question.id
        ] = attemptNumber
        
        
        totalAttempts += 1
        
        
        let isCorrect =
        normalize(
            answerText
        )
        ==
        normalize(
            question.correctAnswer
        )
        
        
        if isCorrect {
            
            feedback =
            "Esatto!"
            
            if attemptNumber == 1 {
                
                firstTryCorrectTaskCount += 1
            }
            
            
            pendingQuestions
                .removeAll {
                    
                    $0.id ==
                    question.id
                }
            
            
            completedTaskCount += 1
            
        } else {
            
            wrongAttempts += 1
            
            feedback =
            "Sbagliato — \(question.correctAnswer)"
        }
    }
    
    
    func continueQuiz() {
        
        answerText = ""
        feedback = nil
        
        
        if pendingQuestions.isEmpty {
            
            currentQuestion = nil
            isFinished = true
            
            return
        }
        
        
        chooseNextQuestion()
    }
    
    
    // MARK: - Question Selection
    
    private func chooseNextQuestion() {
        
        guard !pendingQuestions
            .isEmpty
        else {
            
            currentQuestion = nil
            isFinished = true
            
            return
        }
        
        
        var candidates =
        pendingQuestions
        
        
        if let lastQuestionID,
           candidates.count > 1 {
            
            candidates.removeAll {
                
                $0.id ==
                lastQuestionID
            }
        }
        
        
        guard let selected =
                candidates.randomElement()
        else {
            return
        }
        
        
        currentQuestion =
        selected
        
        lastQuestionID =
        selected.id
    }
    
    
    // MARK: - Normalization
    
    private func normalize(
        _ value: String
    ) -> String {
        
        value
            .trimmingCharacters(
                in:
                        .whitespacesAndNewlines
            )
            .folding(
                options: [
                    .caseInsensitive,
                    .diacriticInsensitive
                ],
                locale:
                    Locale(
                        identifier:
                            "it_IT"
                    )
            )
    }
    
    
    // MARK: - Display
    
    var progressText: String {
        
        "\(completedTaskCount) / \(totalTaskCount)"
    }
    
    
    var isPerfectRun: Bool {
        
        totalTaskCount > 0
        && firstTryCorrectTaskCount
        == totalTaskCount
    }
}
