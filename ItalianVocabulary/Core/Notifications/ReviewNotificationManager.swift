//
//  ReviewNotificationManager 2.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 8.09.2026.
//


//
//  ReviewNotificationManager.swift
//  ItalianVocabulary
//

import Foundation
import UserNotifications


@MainActor
final class ReviewNotificationManager {

    static let shared =
        ReviewNotificationManager()

    private let center =
        UNUserNotificationCenter.current()

    private let identifierPrefix =
        "review-section-"

    private init() {}


    // MARK: - Permission

    func requestAuthorizationIfNeeded()
    async {

        let settings =
            await center
                .notificationSettings()

        guard settings.authorizationStatus
                == .notDetermined
        else {

            print(
                "🔔 Notification status:",
                settings.authorizationStatus.rawValue
            )

            return
        }

        do {

            let granted =
                try await center
                    .requestAuthorization(
                        options: [
                            .alert,
                            .badge,
                            .sound
                        ]
                    )

            print(
                granted
                ? "✅ Notification permission granted"
                : "⚠️ Notification permission denied"
            )

        } catch {

            print(
                "❌ Notification permission error:",
                error
            )
        }
    }


    // MARK: - Synchronize
    
    func synchronizeReviewNotifications(
        
        sections: [WordSection],
        
        progressByWordId:
        [Int: WordProgress]
        
    ) async {
        
        let settings =
        await center
            .notificationSettings()
        
        guard notificationPermissionIsUsable(
            settings.authorizationStatus
        ) else {
            
            print(
                "ℹ️ Notifications unavailable"
            )
            
            return
        }
        
        
        // Sadece bizim oluşturduğumuz
        // review notification'larını kaldır.
        let pending =
        await center
            .pendingNotificationRequests()
        
        let oldIdentifiers =
        pending
            .map(\.identifier)
            .filter {
                
                $0.hasPrefix(
                    identifierPrefix
                )
            }
        
        
        if !oldIdentifiers.isEmpty {
            
            center
                .removePendingNotificationRequests(
                    withIdentifiers:
                        oldIdentifiers
                )
        }
        
        
        let now = Date()
        
        
        struct FutureReview {
            
            let sectionNumber: Int
            let date: Date
            let wordCount: Int
        }
        
        
        var currentDueSectionCount = 0
        
        var futureReviews:
        [FutureReview] = []
        
        
        for section in sections {
            
            let reviewDates =
            section.words
                .compactMap { word
                    -> Date? in
                    
                    guard
                        let progress =
                            progressByWordId[
                                word.id
                            ],
                        progress.completedOnce,
                        let nextReviewAt =
                            progress.nextReviewAt
                    else {
                        
                        return nil
                    }
                    
                    return nextReviewAt
                }
            
            
            // Section'ın en az bir kelimesi
            // şu anda due ise section badge'e
            // yalnızca 1 olarak katkı sağlar.
            let sectionIsDueNow =
            reviewDates.contains {
                
                $0 <= now
            }
            
            
            if sectionIsDueNow {
                
                currentDueSectionCount += 1
                
                // Bu section zaten due.
                // Aynı section içindeki gelecekteki
                // kelimeler badge sayısını artırmaz.
                continue
            }
            
            
            // Section henüz due değilse
            // ilk gelecek review tarihi,
            // section'ın due olacağı tarihtir.
            guard let nextReviewDate =
                    reviewDates.min()
            else {
                
                continue
            }
            
            
            guard nextReviewDate > now
            else {
                
                continue
            }
            
            
            let dueWordCount =
            reviewDates.filter {
                
                abs(
                    $0.timeIntervalSince(
                        nextReviewDate
                    )
                ) < 60
            }
            .count
            
            
            futureReviews.append(
                FutureReview(
                    sectionNumber:
                        section.number,
                    date:
                        nextReviewDate,
                    wordCount:
                        max(
                            dueWordCount,
                            1
                        )
                )
            )
        }
        
        
        // Şu anki app icon badge'i
        // mevcut due section sayısıyla eşitle.
        await AppBadgeManager
            .setCount(
                currentDueSectionCount
            )
        
        
        let sortedFutureReviews =
        futureReviews.sorted {
            
            $0.date < $1.date
        }
        
        
        var scheduledCount = 0
        
        
        for review in sortedFutureReviews {
            
            // Bu notification geldiği anda
            // kaç section due olmuş olacak?
            //
            // Aynı anda due olan section'larda
            // hepsi aynı final badge sayısını alır.
            let futureDueSectionCount =
            sortedFutureReviews.filter {
                
                $0.date <= review.date
            }
            .count
            
            
            let badgeCount =
            currentDueSectionCount
            + futureDueSectionCount
            
            
            do {
                
                try await schedule(
                    sectionNumber:
                        review.sectionNumber,
                    wordCount:
                        review.wordCount,
                    date:
                        review.date,
                    badgeCount:
                        badgeCount
                )
                
                scheduledCount += 1
                
            } catch {
                
                print(
                    "❌ Section",
                    review.sectionNumber,
                    "notification error:",
                    error
                )
            }
        }
        
        
        print(
            "🔴 Current due sections:",
            currentDueSectionCount
        )
        
        print(
            "🔔 Review notifications scheduled:",
            scheduledCount
        )
    }

    // MARK: - Schedule

    private func schedule(
        sectionNumber: Int,
        wordCount: Int,
        date: Date,
        badgeCount: Int
    ) async throws {

        let content =
            UNMutableNotificationContent()

        content.title =
            "Section \(sectionNumber) review is ready"

        if wordCount == 1 {

            content.body =
                "1 word is ready for review."

        } else {

            content.body =
                "\(wordCount) words are ready for review."
        }

        content.sound = .default
        
        content.badge =
        NSNumber(
            value:
                badgeCount
        )

        // Daha sonra notification'a
        // basınca ilgili section'ı açmak için.
        content.userInfo = [
            "sectionNumber":
                sectionNumber
        ]

        content.threadIdentifier =
            "review-reminders"


        let components =
            Calendar.current
                .dateComponents(
                    [
                        .year,
                        .month,
                        .day,
                        .hour,
                        .minute,
                        .second
                    ],
                    from: date
                )

        let trigger =
            UNCalendarNotificationTrigger(
                dateMatching:
                    components,
                repeats: false
            )

        let request =
            UNNotificationRequest(
                identifier:
                    "\(identifierPrefix)\(sectionNumber)",
                content:
                    content,
                trigger:
                    trigger
            )

        try await center.add(
            request
        )


        print(
            "✅ Notification scheduled:",
            "Section \(sectionNumber)",
            "→",
            date
        )
    }


    // MARK: - Helpers

    private func notificationPermissionIsUsable(
        _ status: UNAuthorizationStatus
    ) -> Bool {

        switch status {

        case .authorized,
             .provisional,
             .ephemeral:

            return true

        case .notDetermined,
             .denied:

            return false

        @unknown default:

            return false
        }
    }
    
#if DEBUG
    
    func scheduleDebugNotification(
        sectionNumber: Int,
        after seconds: TimeInterval = 10
    ) async {
        
        let date =
        Date()
            .addingTimeInterval(seconds)
        
        do {
            
            try await schedule(
                sectionNumber:
                    sectionNumber,
                wordCount: 1,
                date: date,
                badgeCount: 1
            )
            
            print(
                "🧪 Debug notification scheduled:",
                "Section \(sectionNumber)",
                "in \(Int(seconds)) seconds"
            )
            
        } catch {
            
            print(
                "❌ Debug notification error:",
                error
            )
        }
    }
    
#endif
}
