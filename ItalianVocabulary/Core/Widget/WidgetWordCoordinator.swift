//
//  WidgetWordCoordinator.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 26.08.2026.
//
import Foundation

@MainActor
final class WidgetWordCoordinator {
    
    private let rotationWordCount = 8
    
    private let rotationLifetime:
    TimeInterval =
    24 * 60 * 60
    
    
    func refreshWidgetWord(
        words: [Word],
        progress: [WordProgress]
    ) {
        
        guard !words.isEmpty else {
            return
        }
        
        let now = Date()
        
        let progressByWordId =
        Dictionary(
            uniqueKeysWithValues:
                progress.map {
                    ($0.wordId, $0)
                }
        )
        
        
        // MARK: - Due Words
        
        let dueWords =
        words.filter { word in
            
            guard let item =
                    progressByWordId[word.id],
                  item.completedOnce,
                  let nextReviewAt =
                    item.nextReviewAt
            else {
                return false
            }
            
            return nextReviewAt <= now
        }
        
        
        // MARK: - Existing Rotation
        
        let existingRotation =
        WidgetWordStore
            .loadRotation()
        
        let rotationCreatedAt =
        WidgetWordStore
            .rotationCreatedAt()
        
        
        let rotationIsFresh: Bool = {
            
            guard
                !existingRotation.isEmpty,
                let rotationCreatedAt
            else {
                return false
            }
            
            return now.timeIntervalSince(
                rotationCreatedAt
            ) < rotationLifetime
        }()
        
        
        // Eğer yeni due kelimeler oluştuysa
        // mevcut 24 saatlik rotation'ı erken yenileyelim.
        
        let rotationWordIds =
        Set(
            existingRotation.map {
                $0.wordId
            }
        )
        
        let hasUnscheduledDueWord =
        dueWords.contains {
            !rotationWordIds
                .contains($0.id)
        }
        
        
        if rotationIsFresh,
           !hasUnscheduledDueWord {
            
            print(
                "ℹ️ Widget rotation still fresh"
            )
            
            return
        }
        
        
        // MARK: - Learned Words
        
        let learnedWords =
        words.filter { word in
            
            guard let item =
                    progressByWordId[word.id]
            else {
                return false
            }
            
            return item.completedOnce
        }
        
        
        // MARK: - Ready Words
        
        let readyWords =
        words.filter {
            $0.isReady
        }
        
        
        // MARK: - Build Priority Pool
        
        let dueIds =
        Set(
            dueWords.map(\.id)
        )
        
        let learnedWithoutDue =
        learnedWords.filter {
            !dueIds.contains($0.id)
        }
        
        
        let learnedIds =
        Set(
            learnedWords.map(\.id)
        )
        
        let readyFallback =
        readyWords.filter {
            !learnedIds.contains($0.id)
        }
        
        
        // Önce due,
        // sonra learned,
        // sonra ready fallback.
        
        var orderedPool =
        dueWords.shuffled()
        
        orderedPool.append(
            contentsOf:
                learnedWithoutDue
                .shuffled()
        )
        
        orderedPool.append(
            contentsOf:
                readyFallback
                .shuffled()
        )
        
        
        // ID bazında duplicate temizliği.
        
        var seenIds =
        Set<Int>()
        
        let uniquePool =
        orderedPool.filter { word in
            
            guard !seenIds
                .contains(word.id)
            else {
                return false
            }
            
            seenIds.insert(
                word.id
            )
            
            return true
        }
        
        
        guard !uniquePool.isEmpty else {
            return
        }
        
        
        // MARK: - Avoid Same First Word
        
        let previousWordId =
        existingRotation.first?
            .wordId
        
        var candidates =
        uniquePool
        
        if candidates.count > 1,
           let previousWordId {
            
            candidates.sort { lhs, rhs in
                
                if lhs.id == previousWordId {
                    return false
                }
                
                if rhs.id == previousWordId {
                    return true
                }
                
                return false
            }
        }
        
        
        let selectedWords =
        Array(
            candidates.prefix(
                rotationWordCount
            )
        )
        
        
        // MARK: - Widget Models
        
        let widgetWords =
        selectedWords.map {
            selected in
            
            let isDue =
            dueIds.contains(
                selected.id
            )
            
            return WidgetWord(
                italian:
                    selected.italian,
                english:
                    selected.english,
                turkish:
                    selected.turkish,
                italianDefinition:
                    selected
                    .italianDefinition,
                wordId:
                    selected.id,
                sequenceNo:
                    selected.sequenceNo,
                isDue:
                    isDue
            )
        }
        
        
        guard !widgetWords.isEmpty else {
            return
        }
        
        
        WidgetWordStore
            .saveRotation(
                widgetWords
            )
        
        
        print(
            "✅ Widget rotation selected:",
            widgetWords.map(\.italian)
        )
    }
}
