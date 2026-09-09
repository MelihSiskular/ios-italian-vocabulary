//
//  HomeViewModel.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import Foundation
internal import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var sections: [WordSection] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published private(set)
    var progressByWordId: [Int: WordProgress] = [:]
    
    private let wordProgressService =
    WordProgressService()
    
    private let wordService = WordService()
    
    private let widgetCoordinator =
    WidgetWordCoordinator()
    
    var dueSectionCount: Int {
        
        sections.filter { section in
            
            !dueWords(
                for: section
            ).isEmpty
        }
        .count
    }
    
    func loadSections() async {
        
        
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            
            async let wordsTask =
            wordService.fetchAllWords()
            
            async let progressTask =
            wordProgressService.fetchAllProgress()
            
            let (words, progress) =
            try await (
                wordsTask,
                progressTask
            )
            
            sections = SectionBuilder.build(
                from: words
            )
            
            progressByWordId = Dictionary(
                uniqueKeysWithValues:
                    progress.map {
                        ($0.wordId, $0)
                    }
            )           
            
            widgetCoordinator.refreshWidgetWord(
                words: words,
                progress: progress
            )
            
            await AppBadgeManager
                .setCount(
                    dueSectionCount
                )
            
            await ReviewNotificationManager
                .shared
                .synchronizeReviewNotifications(
                    sections: sections,
                    progressByWordId:
                        progressByWordId
                )
            
            print(
                "✅ Sections loaded:",
                sections.count
            )
            
            print(
                "✅ Progress loaded:",
                progress.count
            )
            
        } catch {
            
            errorMessage =
            error.localizedDescription
            
            print(
                "❌ Home loading error:",
                error
            )
        }
    }
    
    func progressState(
        for section: WordSection
    ) -> SectionProgressState {
        
        let now = Date()
        
        var currentCount = 0
        var dueCount = 0
        var completedOnceCount = 0
        
        for word in section.words {
            
            guard let progress =
                    progressByWordId[word.id]
            else {
                continue
            }
            
            if progress.completedOnce {
                completedOnceCount += 1
            }
            
            guard progress.completedOnce else {
                continue
            }
            
            if let nextReviewAt =
                progress.nextReviewAt {
                
                if nextReviewAt <= now {
                    
                    dueCount += 1
                    
                } else {
                    
                    currentCount += 1
                }
                
            } else {
                
                currentCount += 1
            }
        }
        
        return SectionProgressState(
            completedCount: currentCount,
            dueCount: dueCount,
            completedOnceCount:
                completedOnceCount
        )
    }
    
    func dueWords(
        for section: WordSection
    ) -> [Word] {
        
        let now = Date()
        
        return section.words.filter { word in
            
            guard let progress =
                    progressByWordId[word.id]
            else {
                return false
            }
            
            guard progress.completedOnce else {
                return false
            }
            
            guard let nextReviewAt =
                    progress.nextReviewAt
            else {
                return false
            }
            
            return nextReviewAt <= now
        }
    }
}
