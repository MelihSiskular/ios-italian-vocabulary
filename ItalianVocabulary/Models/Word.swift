//
//  Word.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import Foundation

struct Word: Codable, Identifiable {
    
    let id: Int
    let sequenceNo: Int
    
    let italian: String
    let english: String?
    let turkish: String?
    
    let italianDefinition: String?
    
    let example1It: String?
    let example1Meaning: String?
    
    let example2It: String?
    let example2Meaning: String?
    
    let isReady: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case sequenceNo = "sequence_no"
        
        case italian
        case english
        case turkish
        
        case italianDefinition = "italian_definition"
        
        case example1It = "example_1_it"
        case example1Meaning = "example_1_meaning"
        
        case example2It = "example_2_it"
        case example2Meaning = "example_2_meaning"
        
        case isReady = "is_ready"
    }
}

extension Word {
    
    var sectionNumber: Int {
        ((sequenceNo - 1) / 15) + 1
    }
}
