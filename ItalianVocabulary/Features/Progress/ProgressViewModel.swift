//
//  ProgressViewModel.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import Foundation
internal import Combine

@MainActor
final class ProgressViewModel: ObservableObject {
    
    @Published private(set) var progress: [WordProgress] = []
    @Published private(set) var sessions: [QuizSessionRecord] = []
    @Published private(set) var attempts: [ReviewAttemptRecord] = []
    
    @Published private(set)
    var words: [Word] = []
    
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    private let analyticsService = AnalyticsService()
    
    var hardestWords: [HardWordStat] {
        
        let wordsById = Dictionary(
            uniqueKeysWithValues:
                words.map {
                    ($0.id, $0)
                }
        )
        
        let attemptsByWord =
        Dictionary(
            grouping: attempts
        ) {
            $0.wordId
        }
        
        var result: [HardWordStat] = []
        
        for (wordId, wordAttempts)
                in attemptsByWord {
            
            guard let word =
                    wordsById[wordId]
            else {
                continue
            }
            
            let wrongAttempts =
            wordAttempts.filter {
                !$0.isCorrect
            }
            
            guard !wrongAttempts.isEmpty else {
                continue
            }
            
            let stat = HardWordStat(
                word: word,
                
                totalAttempts:
                    wordAttempts.count,
                
                wrongAttempts:
                    wrongAttempts.count,
                
                spellingErrors:
                    wrongAttempts.filter {
                        $0.errorType
                        == "spelling_error"
                    }.count,
                
                noRecallErrors:
                    wrongAttempts.filter {
                        $0.errorType
                        == "no_recall"
                    }.count,
                
                confusionErrors:
                    wrongAttempts.filter {
                        $0.errorType
                        == "confused_with_another_word"
                    }.count,
                
                wrongWordFormErrors:
                    wrongAttempts.filter {
                        $0.errorType
                        == "wrong_word_form"
                    }.count,
                
                semanticErrors:
                    wrongAttempts.filter {
                        $0.errorType
                        == "unknown_or_semantic_error"
                    }.count
            )
            
            result.append(stat)
        }
        
        return result.sorted {
            
            if $0.difficultyScore
                == $1.difficultyScore {
                
                return $0.wrongAttempts
                > $1.wrongAttempts
            }
            
            return $0.difficultyScore
            > $1.difficultyScore
        }
    }
    
    func load() async {
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            
            async let progressTask =
            analyticsService.fetchProgress()
            
            async let sessionsTask =
            analyticsService.fetchSessions()
            
            async let attemptsTask =
            analyticsService.fetchAttempts()
            
            async let wordsTask =
            analyticsService.fetchWords()
            
            let (
                progress,
                sessions,
                attempts,
                words
            ) = try await (
                progressTask,
                sessionsTask,
                attemptsTask,
                wordsTask
            )
            
            self.progress = progress
            self.sessions = sessions
            self.attempts = attempts
            self.words = words
            
        } catch {
            
            errorMessage = error.localizedDescription
            
            print(
                "❌ Progress load error:",
                error
            )
        }
    }
    
    
    // MARK: - Core Metrics
    
    var learnedWords: Int {
        progress.filter {
            $0.completedOnce
        }.count
    }
    
    var dueWords: Int {
        
        let now = Date()
        
        return progress.filter { item in
            
            guard item.completedOnce,
                  let nextReviewAt =
                    item.nextReviewAt
            else {
                return false
            }
            
            return nextReviewAt <= now
        }
        .count
    }
    
    var masteredWords: Int {
        progress.filter {
            $0.masteryLevel >= 10
        }.count
    }
    
    var averageMastery: Double {
        
        guard !progress.isEmpty else {
            return 0
        }
        
        let total = progress.reduce(0) {
            $0 + $1.masteryLevel
        }
        
        return Double(total)
        / Double(progress.count)
    }
    
    var totalSessions: Int {
        sessions.count
    }
    
    var totalAttempts: Int {
        attempts.count
    }
    
    var totalMistakes: Int {
        attempts.filter {
            !$0.isCorrect
        }.count
    }
    
    var accuracy: Double {
        
        guard !attempts.isEmpty else {
            return 0
        }
        
        let correct = attempts.filter {
            $0.isCorrect
        }.count
        
        return Double(correct)
        / Double(attempts.count)
        * 100
    }
    
    
    // MARK: - Error Intelligence
    
    var errorCounts: [(String, Int)] {
        
        let wrongAttempts = attempts.filter {
            !$0.isCorrect
        }
        
        let grouped = Dictionary(
            grouping: wrongAttempts
        ) {
            $0.errorType
        }
        
        return grouped
            .map {
                ($0.key, $0.value.count)
            }
            .sorted {
                $0.1 > $1.1
            }
    }
    
    
    // MARK: - Mastery Distribution
    
    var masteryDistribution: [(Int, Int)] {
        
        let grouped = Dictionary(
            grouping: progress
        ) {
            $0.masteryLevel
        }
        
        return grouped
            .map {
                ($0.key, $0.value.count)
            }
            .sorted {
                $0.0 < $1.0
            }
    }
}
