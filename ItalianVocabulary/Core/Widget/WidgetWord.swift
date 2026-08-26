//
//  WidgetWord.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 26.08.2026.
//

import Foundation

struct WidgetWord: Codable {
    
    let italian: String
    let english: String?
    let turkish: String?
    let italianDefinition: String?
    
    let wordId: Int
    let sequenceNo: Int
    
    let isDue: Bool
}
