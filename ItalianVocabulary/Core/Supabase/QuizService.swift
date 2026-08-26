//
//  QuizService.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import Foundation
import Supabase

final class QuizService {
    
    private let client = SupabaseManager.client
    
    // MARK: - Session
    
    struct CreateSessionPayload: Encodable {
        let userId: UUID
        let sectionNumber: Int
        let mode: String
        let totalWords: Int
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case sectionNumber = "section_number"
            case mode
            case totalWords = "total_words"
        }
    }
    
    struct CreatedSession: Decodable {
        let id: UUID
    }
    
    func createSectionSession(
        sectionNumber: Int,
        totalWords: Int,
        mode: QuizMode
    ) async throws -> UUID {
        
        let session = try await client.auth.session
        
        let payload = CreateSessionPayload(
            userId: session.user.id,
            sectionNumber: sectionNumber,
            mode: mode.databaseValue,
            totalWords: totalWords
        )
        
        let created: CreatedSession = try await client
            .from("quiz_sessions")
            .insert(payload)
            .select("id")
            .single()
            .execute()
            .value
        
        return created.id
    }
    // MARK: - Attempt
    
    struct AttemptPayload: Encodable {
        
        let sessionId: UUID
        let userId: UUID
        let wordId: Int
        
        let clueLanguage: String
        
        let userAnswer: String
        let isCorrect: Bool
        
        let errorType: String
        let similarityScore: Double?
        let confusedWithWordId: Int?
        
        let attemptOrder: Int
        let attemptNumber: Int
        
        let isFirstTryCorrect: Bool
        
        enum CodingKeys: String, CodingKey {
            case sessionId = "session_id"
            case userId = "user_id"
            case wordId = "word_id"
            case clueLanguage = "clue_language"
            case userAnswer = "user_answer"
            case isCorrect = "is_correct"
            case errorType = "error_type"
            case similarityScore = "similarity_score"
            case confusedWithWordId = "confused_with_word_id"
            case attemptOrder = "attempt_order"
            case attemptNumber = "attempt_number"
            case isFirstTryCorrect = "is_first_try_correct"
        }
    }
    
    func saveAttempt(
        sessionId: UUID,
        wordId: Int,
        clueLanguage: ClueLanguage,
        userAnswer: String,
        isCorrect: Bool,
        errorType: String,
        similarityScore: Double?,
        confusedWithWordId: Int?,
        attemptOrder: Int,
        attemptNumber: Int,
        isFirstTryCorrect: Bool
    ) async throws {
        
        let session = try await client.auth.session
        
        let payload = AttemptPayload(
            sessionId: sessionId,
            userId: session.user.id,
            wordId: wordId,
            clueLanguage: clueLanguage.rawValue,
            userAnswer: userAnswer,
            isCorrect: isCorrect,
            errorType: errorType,
            similarityScore: similarityScore,
            confusedWithWordId: confusedWithWordId,
            attemptOrder: attemptOrder,
            attemptNumber: attemptNumber,
            isFirstTryCorrect: isFirstTryCorrect
        )
        
        try await client
            .from("review_attempts")
            .insert(payload)
            .execute()
    }
    
    
    // MARK: - Finish Session
    
    struct FinishSessionPayload: Encodable {
        
        let endedAt: Date
        let passedWords: Int
        let hadAnyError: Bool
        let passed: Bool
        
        enum CodingKeys: String, CodingKey {
            case endedAt = "ended_at"
            case passedWords = "passed_words"
            case hadAnyError = "had_any_error"
            case passed
        }
    }
    
    func finishSession(
        sessionId: UUID,
        passedWords: Int,
        hadAnyError: Bool,
        passed: Bool
    ) async throws {
        
        let payload = FinishSessionPayload(
            endedAt: Date(),
            passedWords: passedWords,
            hadAnyError: hadAnyError,
            passed: passed
        )
        
        try await client
            .from("quiz_sessions")
            .update(payload)
            .eq("id", value: sessionId)
            .execute()
    }
}
