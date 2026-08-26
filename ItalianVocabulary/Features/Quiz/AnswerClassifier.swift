//
//  AnswerClassifier.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import Foundation

struct AnswerClassification {
    
    let errorType: String
    let similarityScore: Double
    let confusedWithWordId: Int?
}

enum AnswerClassifier {
    
    static func classify(
        userAnswer: String,
        correctAnswer: String,
        allWords: [Word]
    ) -> AnswerClassification {
        
        let user = normalize(userAnswer)
        let correct = normalize(correctAnswer)
        
        if user.isEmpty {
            return AnswerClassification(
                errorType: "no_recall",
                similarityScore: 0,
                confusedWithWordId: nil
            )
        }
        
        if user == correct {
            return AnswerClassification(
                errorType: "correct",
                similarityScore: 1,
                confusedWithWordId: nil
            )
        }
        
        let similarity = similarity(
            user,
            correct
        )
        
        if let confusedWord = allWords.first(
            where: {
                normalize($0.italian) == user
            }
        ) {
            return AnswerClassification(
                errorType: "confused_with_another_word",
                similarityScore: similarity,
                confusedWithWordId: confusedWord.id
            )
        }
        
        if similarity >= 0.75 {
            return AnswerClassification(
                errorType: "spelling_error",
                similarityScore: similarity,
                confusedWithWordId: nil
            )
        }
        
        return AnswerClassification(
            errorType: "unknown_or_semantic_error",
            similarityScore: similarity,
            confusedWithWordId: nil
        )
    }
    
    private static func normalize(
        _ value: String
    ) -> String {
        
        value
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .folding(
                options: [
                    .caseInsensitive,
                    .diacriticInsensitive
                ],
                locale: Locale(identifier: "it_IT")
            )
    }
    
    private static func similarity(
        _ first: String,
        _ second: String
    ) -> Double {
        
        if first == second {
            return 1
        }
        
        if first.isEmpty || second.isEmpty {
            return 0
        }
        
        let distance = levenshtein(
            Array(first),
            Array(second)
        )
        
        let longest = max(
            first.count,
            second.count
        )
        
        return 1 - (
            Double(distance) / Double(longest)
        )
    }
    
    private static func levenshtein(
        _ first: [Character],
        _ second: [Character]
    ) -> Int {
        
        var previous = Array(
            0...second.count
        )
        
        for (i, char1) in first.enumerated() {
            
            var current = [i + 1]
            
            for (j, char2) in second.enumerated() {
                
                let insertCost =
                current[j] + 1
                
                let deleteCost =
                previous[j + 1] + 1
                
                let replaceCost =
                previous[j]
                + (char1 == char2 ? 0 : 1)
                
                current.append(
                    min(
                        insertCost,
                        deleteCost,
                        replaceCost
                    )
                )
            }
            
            previous = current
        }
        
        return previous.last ?? 0
    }
}
