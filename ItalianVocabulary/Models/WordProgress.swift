//
//  WordProgress.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import Foundation

struct WordProgress: Codable {
    
    let userId: UUID
    let wordId: Int
    
    let completedOnce: Bool
    
    let masteryLevel: Int
    let correctStreak: Int
    
    let totalCorrect: Int
    let totalWrong: Int
    
    let firstCompletedAt: Date?
    let lastReviewAt: Date?
    let nextReviewAt: Date?
    
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
