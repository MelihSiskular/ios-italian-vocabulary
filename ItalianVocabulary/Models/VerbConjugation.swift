//
//  VerbConjugation.swift
//  ItalianVocabulary
//

import Foundation


enum ConjugationTense:
    String,
    CaseIterable,
    Identifiable {
    
    case presentIndicative =
            "present_indicative"
    
    
    var id: String {
        rawValue
    }
    
    
    var title: String {
        
        switch self {
            
        case .presentIndicative:
            return "Present Tense"
        }
    }
}


struct VerbConjugation:
    Codable,
    Identifiable {
    
    let id: Int
    
    let userId: UUID
    let wordId: Int
    
    let tense: String
    
    let io: String?
    let tu: String?
    let luiLei: String?
    let noi: String?
    let voi: String?
    let loro: String?
    
    let isReady: Bool
    
    let createdAt: Date
    let updatedAt: Date
    
    
    enum CodingKeys:
        String,
        CodingKey {
        
        case id
        
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
        
        case isReady =
                "is_ready"
        
        case createdAt =
                "created_at"
        
        case updatedAt =
                "updated_at"
    }
}
