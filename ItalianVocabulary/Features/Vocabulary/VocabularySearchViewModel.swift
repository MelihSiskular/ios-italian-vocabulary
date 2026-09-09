//
//  VocabularySearchViewModel.swift
//  ItalianVocabulary
//

import Foundation
internal import Combine


@MainActor
final class VocabularySearchViewModel:
    ObservableObject {
    
    @Published var query = ""
    
    @Published private(set)
    var words: [Word] = []
    
    @Published private(set)
    var isLoading = false
    
    @Published var errorMessage: String?
    
    private let wordService =
    WordService()
    
    
    // MARK: - Results
    
    var results: [Word] {
        
        let normalizedQuery =
        Self.normalize(query)
        
        guard !normalizedQuery.isEmpty
        else {
            return []
        }
        
        return words
            .compactMap { word -> (Word, Int)? in
                
                guard let score =
                        matchScore(
                            word: word,
                            query:
                                normalizedQuery
                        )
                else {
                    
                    return nil
                }
                
                return (
                    word,
                    score
                )
            }
            .sorted {
                
                if $0.1 != $1.1 {
                    
                    return $0.1 < $1.1
                }
                
                return $0.0.sequenceNo
                < $1.0.sequenceNo
            }
            .map(\.0)
    }
    
    
    // MARK: - Loading
    
    func loadWords() async {
        
        guard words.isEmpty else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            
            words =
            try await wordService
                .fetchReadyWords()
            
            print(
                "🔎 Vocabulary loaded:",
                words.count
            )
            
        } catch {
            
            errorMessage =
            error.localizedDescription
            
            print(
                "❌ Vocabulary search error:",
                error
            )
        }
    }
    
    
    // MARK: - Matching
    
    private func matchScore(
        word: Word,
        query: String
    ) -> Int? {
        
        let values: [String] = [
            
            word.italian,
            
            word.turkish ?? "",
            
            word.english ?? ""
        ]
        
        var bestScore: Int?
        
        for value in values {
            
            let normalizedValue =
            Self.normalize(value)
            
            guard !normalizedValue.isEmpty
            else {
                continue
            }
            
            let score: Int?
            
            if normalizedValue == query {
                
                // Exact match
                score = 0
                
            } else if normalizedValue
                .hasPrefix(query) {
                
                // Starts with query
                score = 1
                
            } else if wordStartsWith(
                query,
                in: normalizedValue
            ) {
                
                // Translation contains a word
                // starting with the query.
                score = 2
                
            } else if normalizedValue
                .contains(query) {
                
                // General contains
                score = 3
                
            } else {
                
                score = nil
            }
            
            
            if let score {
                
                bestScore =
                min(
                    bestScore ?? score,
                    score
                )
            }
        }
        
        return bestScore
    }
    
    
    private func wordStartsWith(
        _ query: String,
        in value: String
    ) -> Bool {
        
        value
            .components(
                separatedBy:
                    CharacterSet
                    .alphanumerics
                    .inverted
            )
            .filter {
                !$0.isEmpty
            }
            .contains {
                $0.hasPrefix(query)
            }
    }
    
    
    // MARK: - Normalization
    
    private static func normalize(
        _ value: String
    ) -> String {
        
        value
            .trimmingCharacters(
                in:
                        .whitespacesAndNewlines
            )
            .folding(
                options: [
                    .diacriticInsensitive,
                    .widthInsensitive
                ],
                locale:
                    Locale(
                        identifier:
                            "en_US_POSIX"
                    )
            )
            .lowercased(
                with:
                    Locale(
                        identifier:
                            "en_US_POSIX"
                    )
            )
            .replacingOccurrences(
                of: "ı",
                with: "i"
            )
    }
}
