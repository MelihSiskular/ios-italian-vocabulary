//
//  QuizResult.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import Foundation

struct QuizResult {
    
    let sectionNumber: Int
    
    let totalWords: Int
    let totalTasks: Int
    
    let totalAttempts: Int
    let wrongAttempts: Int
    
    let firstTryCorrectTasks: Int
    
    let passed: Bool
    
    let mode: QuizMode
    let failedWords: Int
}
