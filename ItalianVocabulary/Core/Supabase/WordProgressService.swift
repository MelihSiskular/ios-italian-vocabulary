//
//  WordProgressService.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import Foundation
import Supabase

final class WordProgressService {
    
    private let client = SupabaseManager.client
    
    
    struct InitialProgressPayload: Encodable {
        
        let userId: UUID
        let wordId: Int
        
        let completedOnce: Bool
        
        let masteryLevel: Int
        let correctStreak: Int
        
        let totalCorrect: Int
        let totalWrong: Int
        
        let firstCompletedAt: Date
        let lastReviewAt: Date
        let nextReviewAt: Date
        
        let updatedAt: Date
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case wordId = "word_id"
            
            case completedOnce = "completed_once"
            
            case masteryLevel = "mastery_level"
            case correctStreak = "correct_streak"
            
            case totalCorrect = "total_correct"
            case totalWrong = "total_wrong"
            
            case firstCompletedAt = "first_completed_at"
            case lastReviewAt = "last_review_at"
            case nextReviewAt = "next_review_at"
            
            case updatedAt = "updated_at"
        }
    }
    
    struct ReviewProgressUpdatePayload: Encodable {
        
        let masteryLevel: Int
        let correctStreak: Int
        
        let totalCorrect: Int
        let totalWrong: Int
        
        let lastReviewAt: Date
        let nextReviewAt: Date
        
        let updatedAt: Date
        
        enum CodingKeys: String, CodingKey {
            case masteryLevel = "mastery_level"
            case correctStreak = "correct_streak"
            
            case totalCorrect = "total_correct"
            case totalWrong = "total_wrong"
            
            case lastReviewAt = "last_review_at"
            case nextReviewAt = "next_review_at"
            
            case updatedAt = "updated_at"
        }
    }
    
    func updateAfterReview(
        progress: WordProgress,
        passed: Bool
    ) async throws {
        
        let now = Date()
        
        let newMasteryLevel: Int
        let newCorrectStreak: Int
        let newTotalCorrect: Int
        let newTotalWrong: Int
        let nextReviewDate: Date
        
        if passed {
            
            newMasteryLevel =
            progress.masteryLevel + 1
            
            newCorrectStreak =
            progress.correctStreak + 1
            
            newTotalCorrect =
            progress.totalCorrect + 1
            
            newTotalWrong =
            progress.totalWrong
            
            guard let calculatedDate =
                    Calendar.current.date(
                        byAdding: .day,
                        value: newMasteryLevel,
                        to: now
                    )
            else {
                throw WordProgressError
                    .dateCalculationFailed
            }
            
            nextReviewDate = calculatedDate
            
        } else {
            
            newMasteryLevel =
            max(
                1,
                progress.masteryLevel - 1
            )
            
            newCorrectStreak = 0
            
            newTotalCorrect =
            progress.totalCorrect
            
            newTotalWrong =
            progress.totalWrong + 1
            
            // Başarısız kelime due olarak kalır.
            nextReviewDate = now
        }
        
        let payload =
        ReviewProgressUpdatePayload(
            masteryLevel:
                newMasteryLevel,
            
            correctStreak:
                newCorrectStreak,
            
            totalCorrect:
                newTotalCorrect,
            
            totalWrong:
                newTotalWrong,
            
            lastReviewAt: now,
            nextReviewAt:
                nextReviewDate,
            
            updatedAt: now
        )
        
        let session =
        try await client.auth.session
        
        try await client
            .from("word_progress")
            .update(payload)
            .eq(
                "user_id",
                value: session.user.id
            )
            .eq(
                "word_id",
                value: progress.wordId
            )
            .execute()
    }
    
    func fetchProgress(
        for wordIds: [Int]
    ) async throws -> [WordProgress] {
        
        guard !wordIds.isEmpty else {
            return []
        }
        
        let session =
        try await client.auth.session
        
        let progress: [WordProgress] =
        try await client
            .from("word_progress")
            .select()
            .eq(
                "user_id",
                value: session.user.id
            )
            .in(
                "word_id",
                values: wordIds
            )
            .execute()
            .value
        
        return progress
    }
    
    func completeInitialSection(
        words: [Word]
    ) async throws {
        
        let session = try await client.auth.session
        let userId = session.user.id
        
        let now = Date()
        
        guard let nextReviewDate =
                Calendar.current.date(
                    byAdding: .day,
                    value: 1,
                    to: now
                )
        else {
            throw WordProgressError.dateCalculationFailed
        }
        
        let payloads = words.map { word in
            
            InitialProgressPayload(
                userId: userId,
                wordId: word.id,
                
                completedOnce: true,
                
                masteryLevel: 1,
                correctStreak: 1,
                
                totalCorrect: 1,
                totalWrong: 0,
                
                firstCompletedAt: now,
                lastReviewAt: now,
                nextReviewAt: nextReviewDate,
                
                updatedAt: now
            )
        }
        
        try await client
            .from("word_progress")
            .upsert(
                payloads,
                onConflict: "user_id,word_id"
            )
            .execute()
    }
    func fetchAllProgress() async throws -> [WordProgress] {
        
        let session = try await client.auth.session
        
        let progress: [WordProgress] = try await client
            .from("word_progress")
            .select()
            .eq(
                "user_id",
                value: session.user.id
            )
            .execute()
            .value
        
        return progress
    }
}

enum WordProgressError: Error {
    case dateCalculationFailed
}
