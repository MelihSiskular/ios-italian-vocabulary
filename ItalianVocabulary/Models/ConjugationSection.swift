//
//  ConjugationSection.swift
//  ItalianVocabulary
//

import Foundation


struct ConjugationSection:
    Identifiable {
    
    let number: Int
    let items:
    [ConjugationVerbItem]
    
    
    var id: Int {
        number
    }
    
    
    var readyCount: Int {
        
        items.filter {
            $0.isReady
        }
        .count
    }
    
    
    var totalCount: Int {
        items.count
    }
    
    
    var isCompleteBatch: Bool {
        items.count == 5
    }
    
    
    var isReadyForQuiz: Bool {
        
        isCompleteBatch
        && readyCount == items.count
    }
    
    
    var questionCount: Int {
        items.count * 6
    }
}
