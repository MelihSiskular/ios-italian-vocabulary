//
//  HardWordStat.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import Foundation

struct HardWordStat: Identifiable {
    
    let word: Word
    
    let totalAttempts: Int
    let wrongAttempts: Int
    
    let spellingErrors: Int
    let noRecallErrors: Int
    let confusionErrors: Int
    let wrongWordFormErrors: Int
    let semanticErrors: Int
    
    var id: Int {
        word.id
    }
    
    var difficultyScore: Int {
        
        spellingErrors
        + noRecallErrors * 3
        + confusionErrors * 2
        + wrongWordFormErrors * 2
        + semanticErrors * 3
    }
}
