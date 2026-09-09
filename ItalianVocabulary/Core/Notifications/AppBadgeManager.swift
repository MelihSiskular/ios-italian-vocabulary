//
//  AppBadgeManager.swift
//  ItalianVocabulary
//

import Foundation
import UserNotifications


enum AppBadgeManager {
    
    static func setCount(
        _ count: Int
    ) async {
        
        let safeCount =
        max(
            count,
            0
        )
        
        do {
            
            try await
            UNUserNotificationCenter
                .current()
                .setBadgeCount(
                    safeCount
                )
            
            print(
                "🔴 App badge:",
                safeCount
            )
            
        } catch {
            
            print(
                "❌ App badge update failed:",
                error
            )
        }
    }
}
