//
//  WordService.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import Foundation
import Supabase

final class WordService {
    
    private let client = SupabaseManager.client
    
    func fetchReadyWords() async throws -> [Word] {
        
        let words: [Word] = try await client
            .from("words")
            .select()
            .eq("is_ready", value: true)
            .order(
                "sequence_no",
                ascending: true
            )
            .execute()
            .value
        
        return words
    }
    
    func fetchAllWords() async throws -> [Word] {
        let words: [Word] = try await client
            .from("words")
            .select()
            .order("sequence_no", ascending: true)
            .execute()
            .value
        
        return words
    }
    func fetchWord(
        id: Int
    ) async throws -> Word {
        
        let words: [Word] = try await client
            .from("words")
            .select()
            .eq(
                "id",
                value: id
            )
            .limit(1)
            .execute()
            .value
        
        guard let word = words.first else {
            throw WordServiceError.wordNotFound
        }
        
        return word
    }
}

enum WordServiceError: LocalizedError {
    
    case wordNotFound
    
    var errorDescription: String? {
        
        switch self {
            
        case .wordNotFound:
            return "The requested word could not be found."
        }
    }
}
