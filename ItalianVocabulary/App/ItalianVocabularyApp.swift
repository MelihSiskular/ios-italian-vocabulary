//
//  ItalianVocabularyApp.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import SwiftUI


@main
struct ItalianVocabularyApp: App {
    
    @UIApplicationDelegateAdaptor(
        AppDelegate.self
    )
    private var appDelegate
    
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView()
        }
    }
}
