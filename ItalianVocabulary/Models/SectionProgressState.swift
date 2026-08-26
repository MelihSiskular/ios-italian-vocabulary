//
//  SectionProgressState.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import Foundation

struct SectionProgressState {
    
    let completedCount: Int
    let dueCount: Int
    let completedOnceCount: Int
    
    var isCompletedOnce: Bool {
        completedOnceCount == 15
    }
    
    var isUpToDate: Bool {
        completedCount == 15
    }
    
    var hasDueReviews: Bool {
        dueCount > 0
    }
}
