//
//  HapticManager.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 26.08.2026.
//

import UIKit

enum HapticManager {
    
    static func success() {
        
        let generator =
        UINotificationFeedbackGenerator()
        
        generator.prepare()
        
        generator.notificationOccurred(
            .success
        )
    }
    
    
    static func error() {
        
        let generator =
        UINotificationFeedbackGenerator()
        
        generator.prepare()
        
        generator.notificationOccurred(
            .error
        )
    }
    
    
    static func selection() {
        
        let generator =
        UISelectionFeedbackGenerator()
        
        generator.prepare()
        
        generator.selectionChanged()
    }
    
    
    static func impact() {
        
        let generator =
        UIImpactFeedbackGenerator(
            style: .light
        )
        
        generator.prepare()
        
        generator.impactOccurred()
    }
}
