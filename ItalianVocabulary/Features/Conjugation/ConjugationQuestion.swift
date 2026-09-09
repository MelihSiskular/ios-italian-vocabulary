//
//  ConjugationQuestion.swift
//  ItalianVocabulary
//

import Foundation


enum ConjugationPerson:
    String,
    CaseIterable,
    Identifiable {
    
    case io
    case tu
    case luiLei
    case noi
    case voi
    case loro
    
    
    var id: String {
        rawValue
    }
    
    
    var title: String {
        
        switch self {
            
        case .io:
            return "io"
            
        case .tu:
            return "tu"
            
        case .luiLei:
            return "lui / lei"
            
        case .noi:
            return "noi"
            
        case .voi:
            return "voi"
            
        case .loro:
            return "loro"
        }
    }
    
    
    func answer(
        from conjugation:
        VerbConjugation
    ) -> String? {
        
        switch self {
            
        case .io:
            return conjugation.io
            
        case .tu:
            return conjugation.tu
            
        case .luiLei:
            return conjugation.luiLei
            
        case .noi:
            return conjugation.noi
            
        case .voi:
            return conjugation.voi
            
        case .loro:
            return conjugation.loro
        }
    }
}


struct ConjugationQuestion:
    Identifiable {
    
    let id: UUID
    
    let word: Word
    
    let person:
    ConjugationPerson
    
    let correctAnswer: String
}
