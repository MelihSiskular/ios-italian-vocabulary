//
//  AppDelegate.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 8.09.2026.
//

import UIKit
import UserNotifications


final class AppDelegate:
    NSObject,
    UIApplicationDelegate,
    UNUserNotificationCenterDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions
        launchOptions:
        [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        UNUserNotificationCenter
            .current()
            .delegate = self
        
        return true
    }
    
    
    // MARK: - Notification Tap
    
    func userNotificationCenter(
        _ center:
        UNUserNotificationCenter,
        didReceive response:
        UNNotificationResponse,
        withCompletionHandler
        completionHandler:
        @escaping () -> Void
    ) {
        
        let userInfo =
        response.notification
            .request
            .content
            .userInfo
        
        let sectionNumber: Int?
        
        if let value =
            userInfo[
                "sectionNumber"
            ] as? Int {
            
            sectionNumber = value
            
        } else if let value =
                    userInfo[
                        "sectionNumber"
                    ] as? NSNumber {
            
            sectionNumber =
            value.intValue
            
        } else if let value =
                    userInfo[
                        "sectionNumber"
                    ] as? String {
            
            sectionNumber =
            Int(value)
            
        } else {
            
            sectionNumber = nil
        }
        
        
        if let sectionNumber {
            
            Task { @MainActor in
                
                ReviewNotificationRouter
                    .shared
                    .openSection(
                        sectionNumber
                    )
            }
        }
        
        completionHandler()
    }
    
    
    // MARK: - Foreground Presentation
    
    func userNotificationCenter(
        _ center:
        UNUserNotificationCenter,
        willPresent notification:
        UNNotification,
        withCompletionHandler
        completionHandler:
        @escaping (
            UNNotificationPresentationOptions
        ) -> Void
    ) {
        
        completionHandler([
            .banner,
            .sound
        ])
    }
}
