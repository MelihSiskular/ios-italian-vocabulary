//
//  ConjugationService.swift
//  ItalianVocabulary
//

import Foundation
import Supabase


final class ConjugationService {
    
    private let client =
    SupabaseManager.client
    
    private let wordService =
    WordService()
    
    
    // MARK: - Verb Candidates
    
    func fetchVerbCandidates()
    async throws -> [Word] {
        
        let words =
        try await wordService
            .fetchReadyWords()
        
        return words.filter { word in
            
            guard let english =
                    word.english?
                .trimmingCharacters(
                    in:
                            .whitespacesAndNewlines
                ),
                  !english.isEmpty
            else {
                return false
            }
            
            return english
                .lowercased()
                .hasPrefix("to ")
        }
    }
    
    
    // MARK: - Fetch Conjugations
    
    func fetchConjugations(
        tense: ConjugationTense
    ) async throws
    -> [VerbConjugation] {
        
        let conjugations:
        [VerbConjugation] =
        try await client
            .from(
                "verb_conjugations"
            )
            .select()
            .eq(
                "tense",
                value:
                    tense.rawValue
            )
            .order(
                "word_id",
                ascending: true
            )
            .execute()
            .value
        
        return conjugations
    }
    
    
    // MARK: - Fetch Single
    
    func fetchConjugation(
        wordId: Int,
        tense: ConjugationTense
    ) async throws
    -> VerbConjugation? {
        
        let conjugations:
        [VerbConjugation] =
        try await client
            .from(
                "verb_conjugations"
            )
            .select()
            .eq(
                "word_id",
                value: wordId
            )
            .eq(
                "tense",
                value:
                    tense.rawValue
            )
            .limit(1)
            .execute()
            .value
        
        return conjugations.first
    }
    
    
    // MARK: - Save
    
    func saveConjugation(
        wordId: Int,
        tense: ConjugationTense,
        io: String,
        tu: String,
        luiLei: String,
        noi: String,
        voi: String,
        loro: String
    ) async throws {
        
        let session =
        try await client.auth.session
        
        let payload =
        ConjugationPayload(
            userId:
                session.user.id,
            wordId:
                wordId,
            tense:
                tense.rawValue,
            io:
                normalized(io),
            tu:
                normalized(tu),
            luiLei:
                normalized(luiLei),
            noi:
                normalized(noi),
            voi:
                normalized(voi),
            loro:
                normalized(loro)
        )
        
        try await client
            .from(
                "verb_conjugations"
            )
            .upsert(
                payload,
                onConflict:
                    "user_id,word_id,tense"
            )
            .execute()
    }
    
    
    // MARK: - Helpers
    
    private func normalized(
        _ value: String
    ) -> String? {
        
        let trimmed =
        value.trimmingCharacters(
            in:
                    .whitespacesAndNewlines
        )
        
        return trimmed.isEmpty
        ? nil
        : trimmed
    }
    
    
    // MARK: - Payload
    
    private struct
ConjugationPayload:
    Encodable {
        
        let userId: UUID
        let wordId: Int
        let tense: String
        
        let io: String?
        let tu: String?
        let luiLei: String?
        let noi: String?
        let voi: String?
        let loro: String?
        
        
        enum CodingKeys:
            String,
            CodingKey {
            
            case userId =
                    "user_id"
            
            case wordId =
                    "word_id"
            
            case tense
            
            case io
            case tu
            
            case luiLei =
                    "lui_lei"
            
            case noi
            case voi
            case loro
        }
    }
}
