//
//  ConjugationHomeView.swift
//  ItalianVocabulary
//

import SwiftUI


struct ConjugationHomeView: View {
    
    var body: some View {
        
        ScrollView {
            
            VStack(
                alignment: .leading,
                spacing:
                    AppTheme.Spacing.xl
            ) {
                
                header
                
                tenseSection
            }
            .padding(
                .horizontal,
                AppTheme.Layout
                    .horizontalPadding
            )
            .padding(
                .top,
                AppTheme.Spacing.sm
            )
            .padding(
                .bottom,
                AppTheme.Spacing.xxl
            )
        }
        .navigationTitle(
            "Conjugation"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }
    
    
    // MARK: - Header
    
    private var header: some View {
        
        VStack(
            alignment: .leading,
            spacing:
                AppTheme.Spacing.xs
        ) {
            
            Text(
                "Verb conjugation"
            )
            .font(
                .title2.bold()
            )
            
            Text(
                "Practice Italian verbs by tense."
            )
            .font(
                .subheadline
            )
            .foregroundStyle(
                .secondary
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }
    
    
    // MARK: - Tenses
    
    private var tenseSection: some View {
        
        VStack(
            alignment: .leading,
            spacing:
                AppTheme.Spacing.md
        ) {
            
            Text(
                "Tenses"
            )
            .font(
                .headline
            )
            
            
            NavigationLink {
                
                PresentTenseView()
                
            } label: {
                
                AppCard {
                    
                    HStack(
                        spacing:
                            AppTheme.Spacing.md
                    ) {
                        
                        Image(
                            systemName:
                                "textformat"
                        )
                        .font(
                            .title2
                        )
                        .frame(
                            width: 36
                        )
                        
                        
                        VStack(
                            alignment: .leading,
                            spacing:
                                AppTheme.Spacing.xs
                        ) {
                            
                            Text(
                                "Present Tense"
                            )
                            .font(
                                .headline
                            )
                            
                            Text(
                                "Indicativo presente"
                            )
                            .font(
                                .subheadline
                            )
                            .foregroundStyle(
                                .secondary
                            )
                        }
                        
                        
                        Spacer()
                        
                        
                        Image(
                            systemName:
                                "chevron.right"
                        )
                        .font(
                            .footnote.weight(
                                .semibold
                            )
                        )
                        .foregroundStyle(
                            .tertiary
                        )
                    }
                }
            }
            .buttonStyle(
                .plain
            )
        }
    }
}
