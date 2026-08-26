//
//  WidgetWordDetailDestination.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 26.08.2026.
//

import SwiftUI

struct WidgetWordDetailDestination:
    View {
    
    let wordId: Int
    
    @State private var word: Word?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    private let wordService =
    WordService()
    
    
    var body: some View {
        
        Group {
            
            if isLoading {
                
                ProgressView(
                    "Loading word..."
                )
                
            } else if let word {
                
                WordDetailView(
                    word: word
                )
                
            } else {
                
                ContentUnavailableView(
                    "Word unavailable",
                    systemImage:
                        "text.book.closed",
                    description:
                        Text(
                            errorMessage
                            ?? "This word could not be loaded."
                        )
                )
            }
        }
        .task(
            id: wordId
        ) {
            
            await loadWord()
        }
    }
    
    
    @MainActor
    private func loadWord() async {
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            
            word =
            try await wordService
                .fetchWord(
                    id: wordId
                )
            
        } catch {
            
            errorMessage =
            error.localizedDescription
        }
    }
}
