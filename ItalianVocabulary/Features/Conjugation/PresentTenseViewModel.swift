//
//  PresentTenseViewModel.swift
//  ItalianVocabulary
//

import Foundation
internal import Combine


struct ConjugationVerbItem:
    Identifiable {
    
    let word: Word
    let conjugation: VerbConjugation?
    
    
    var id: Int {
        word.id
    }
    
    
    var isReady: Bool {
        conjugation?.isReady == true
    }
}


@MainActor
final class PresentTenseViewModel:
    ObservableObject {
    
    @Published private(set) var items:
    [ConjugationVerbItem] = []
    
    @Published private(set) var isLoading =
    false
    
    @Published private(set) var errorMessage:
    String?
    
    
    private let service =
    ConjugationService()
    
    
    var totalCount: Int {
        items.count
    }
    
    
    var readyCount: Int {
        
        items.filter {
            $0.isReady
        }
        .count
    }
    
    
    var needsSetupCount: Int {
        totalCount - readyCount
    }
    
    
    var sections:
    [ConjugationSection] {
        
        let chunks =
        stride(
            from: 0,
            to: items.count,
            by: 5
        )
        .map { start in
            
            let end =
            min(
                start + 5,
                items.count
            )
            
            return Array(
                items[start..<end]
            )
        }
        
        
        return chunks
            .enumerated()
            .map { index, items in
                
                ConjugationSection(
                    number: index + 1,
                    items: items
                )
            }
    }
    
    func load() async {
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        
        do {
            
            async let wordsTask =
            service.fetchVerbCandidates()
            
            async let conjugationsTask =
            service.fetchConjugations(
                tense:
                        .presentIndicative
            )
            
            
            let (
                words,
                conjugations
            ) = try await (
                wordsTask,
                conjugationsTask
            )
            
            
            let conjugationByWordId =
            Dictionary(
                uniqueKeysWithValues:
                    conjugations.map {
                        (
                            $0.wordId,
                            $0
                        )
                    }
            )
            
            
            items =
            words.map { word in
                
                ConjugationVerbItem(
                    word: word,
                    conjugation:
                        conjugationByWordId[
                            word.id
                        ]
                )
            }
            
            
            print(
                "🧩 Present tense:",
                "\(totalCount) verbs,",
                "\(readyCount) ready,",
                "\(needsSetupCount) need setup"
            )
            
        } catch {
            
            errorMessage =
            error.localizedDescription
            
            print(
                "❌ Present tense load error:",
                error
            )
        }
    }
}
