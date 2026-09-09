//
//  ReviewNotificationRouter.swift
//  ItalianVocabulary
//

import Foundation
internal import Combine


final class ReviewNotificationRouter:
    ObservableObject {
    
    static let shared =
    ReviewNotificationRouter()
    
    @Published var pendingSectionNumber:
    Int?
    
    private init() {}
    
    
    func openSection(
        _ sectionNumber: Int
    ) {
        
        pendingSectionNumber =
        sectionNumber
        
        print(
            "🔔 Opening review section:",
            sectionNumber
        )
    }
}
