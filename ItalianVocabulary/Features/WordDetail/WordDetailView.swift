//
//  WordDetailView.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 26.08.2026.
//

import SwiftUI

struct WordDetailView: View {
    
    let word: Word
    
    
    var body: some View {
        
        ScrollView {
            
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xl
            ) {
                
                wordHeader
                
                definitionSection
                
                exampleSection
            }
            .padding(
                .horizontal,
                AppTheme.Layout.horizontalPadding
            )
            .padding(
                .top,
                AppTheme.Spacing.md
            )
            .padding(
                .bottom,
                AppTheme.Spacing.xxl
            )
        }
        .navigationTitle("Word")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    // MARK: - Header
    
    private var wordHeader: some View {
        
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {
            
            Text(word.italian)
                .font(
                    .system(
                        size: 38,
                        weight: .bold,
                        design: .rounded
                    )
                )
            
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xs
            ) {
                
                if let turkish = word.turkish,
                   !turkish.isEmpty {
                    
                    Text(turkish)
                        .font(
                            .title3.weight(
                                .semibold
                            )
                        )
                }
                
                if let english = word.english,
                   !english.isEmpty {
                    
                    Text(english)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }
    
    
    // MARK: - Definition
    
    @ViewBuilder
    private var definitionSection: some View {
        
        if let definition =
            word.italianDefinition,
           !definition.isEmpty {
            
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.md
            ) {
                
                Label(
                    "Definizione",
                    systemImage:
                        "text.book.closed"
                )
                .font(.headline)
                
                AppCard {
                    
                    Text(definition)
                        .font(.body)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                }
            }
        }
    }
    
    
    // MARK: - Example
    
    @ViewBuilder
    private var exampleSection: some View {
        
        if let example = word.example1It,
           !example.isEmpty {
            
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.md
            ) {
                
                Label(
                    "Esempio",
                    systemImage:
                        "quote.opening"
                )
                .font(.headline)
                
                AppCard {
                    
                    VStack(
                        alignment: .leading,
                        spacing: AppTheme.Spacing.md
                    ) {
                        
                        Text(example)
                            .font(
                                .body.weight(
                                    .medium
                                )
                            )
                        
                        if let meaning =
                            word.example1Meaning,
                           !meaning.isEmpty {
                            
                            Divider()
                            
                            Text(meaning)
                                .font(.subheadline)
                                .foregroundStyle(
                                    .secondary
                                )
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }
            }
        }
    }
}
