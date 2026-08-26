//
//  QuizQuestion.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//
import Foundation

enum ClueLanguage: String, Codable {
    case turkish = "tr"
    case english = "en"
    
    var title: String {
        switch self {
        case .turkish:
            return "Türkçe"
        case .english:
            return "English"
        }
    }
}

struct QuizQuestion: Identifiable {
    
    let id: UUID
    let word: Word
    let clueLanguage: ClueLanguage
    
    var clue: String {
        switch clueLanguage {
        case .turkish:
            return word.turkish ?? ""
        case .english:
            return word.english ?? ""
        }
    }
    
    var correctAnswer: String {
        word.italian
    }
}

enum QuizMode: Equatable {
    case initialSection
    case sectionReview
    
    var databaseValue: String {
        switch self {
        case .initialSection:
            return "initial_section"
            
        case .sectionReview:
            return "section_review"
        }
    }
}
