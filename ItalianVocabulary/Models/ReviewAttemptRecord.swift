//
//  ReviewAttemptRecord.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import Foundation

struct ReviewAttemptRecord: Codable, Identifiable {
    
    let id: Int
    
    let sessionId: UUID
    let wordId: Int
    
    let clueLanguage: String
    
    let userAnswer: String
    let isCorrect: Bool
    
    let errorType: String
    let similarityScore: Double?
    
    let attemptOrder: Int
    let attemptNumber: Int
    
    let isFirstTryCorrect: Bool
    
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        
        case id
        
        case sessionId = "session_id"
        case wordId = "word_id"
        
        case clueLanguage = "clue_language"
        
        case userAnswer = "user_answer"
        case isCorrect = "is_correct"
        
        case errorType = "error_type"
        case similarityScore = "similarity_score"
        
        case attemptOrder = "attempt_order"
        case attemptNumber = "attempt_number"
        
        case isFirstTryCorrect = "is_first_try_correct"
        
        case createdAt = "created_at"
    }
}
