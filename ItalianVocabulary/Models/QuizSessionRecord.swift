//
//  QuizSessionRecord.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import Foundation

struct QuizSessionRecord: Codable, Identifiable {
    
    let id: UUID
    let sectionNumber: Int?
    let mode: String
    
    let startedAt: Date
    let endedAt: Date?
    
    let totalWords: Int
    let passedWords: Int
    
    let hadAnyError: Bool
    let passed: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        
        case sectionNumber = "section_number"
        case mode
        
        case startedAt = "started_at"
        case endedAt = "ended_at"
        
        case totalWords = "total_words"
        case passedWords = "passed_words"
        
        case hadAnyError = "had_any_error"
        case passed
    }
}
