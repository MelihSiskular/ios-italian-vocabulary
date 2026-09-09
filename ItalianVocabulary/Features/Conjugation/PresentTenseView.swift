//
//  PresentTenseView.swift
//  ItalianVocabulary
//

import SwiftUI


struct PresentTenseView: View {
    
    @StateObject private var viewModel =
    PresentTenseViewModel()
    
    
    var body: some View {
        
        Group {
            
            if viewModel.isLoading
                && viewModel.items.isEmpty {
                
                ProgressView(
                    "Loading verbs..."
                )
                
            } else if let errorMessage =
                        viewModel.errorMessage,
                      viewModel.items.isEmpty {
                
                ContentUnavailableView(
                    "Could not load verbs",
                    systemImage:
                        "exclamationmark.triangle",
                    description:
                        Text(errorMessage)
                )
                
            } else {
                
                content
            }
        }
        .navigationTitle(
            "Present Tense"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
        .task {
            
            await viewModel.load()
        }
        .refreshable {
            
            await viewModel.load()
        }
    }
    
    
    // MARK: - Content
    
    private var content: some View {
        
        ScrollView {
            
            VStack(
                alignment: .leading,
                spacing:
                    AppTheme.Spacing.xl
            ) {
                
                summarySection
                
                verbSection
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
    }
    
    
    // MARK: - Summary
    
    private var summarySection:
    some View {
        
        AppCard {
            
            VStack(
                alignment: .leading,
                spacing:
                    AppTheme.Spacing.md
            ) {
                
                Text(
                    "\(viewModel.totalCount) verbs"
                )
                .font(
                    .title2.bold()
                )
                
                
                Text(
                    "Add the six present-tense forms for each verb before using it in quizzes."
                )
                .font(
                    .subheadline
                )
                .foregroundStyle(
                    .secondary
                )
                
                
                Divider()
                
                
                HStack {
                    
                    summaryValue(
                        title: "Ready",
                        value:
                            viewModel.readyCount
                    )
                    
                    Spacer()
                    
                    summaryValue(
                        title: "Needs setup",
                        value:
                            viewModel
                            .needsSetupCount
                    )
                }
            }
        }
    }
    
    
    private func summaryValue(
        title: String,
        value: Int
    ) -> some View {
        
        VStack(
            alignment: .leading,
            spacing:
                AppTheme.Spacing.xs
        ) {
            
            Text(
                "\(value)"
            )
            .font(
                .title3.bold()
            )
            
            Text(
                title
            )
            .font(
                .caption
            )
            .foregroundStyle(
                .secondary
            )
        }
    }
    
    
    // MARK: - Verbs
    
    // MARK: - Sections
    
    private var verbSection:
    some View {
        
        VStack(
            alignment: .leading,
            spacing:
                AppTheme.Spacing.md
        ) {
            
            Text(
                "Sections"
            )
            .font(
                .title3.bold()
            )
            
            
            VStack(
                spacing:
                    AppTheme.Spacing.md
            ) {
                
                ForEach(
                    viewModel.sections
                ) { section in
                    
                    NavigationLink {
                        
                        ConjugationSectionDetailView(
                            section: section,
                            tense:
                                    .presentIndicative
                        )
                        .onDisappear {
                            
                            Task {
                                await viewModel.load()
                            }
                        }
                        
                    } label: {
                        
                        AppCard {
                            
                            HStack(
                                spacing:
                                    AppTheme.Spacing.md
                            ) {
                                
                                VStack(
                                    alignment: .leading,
                                    spacing:
                                        AppTheme.Spacing.xs
                                ) {
                                    
                                    Text(
                                        "Section \(section.number)"
                                    )
                                    .font(
                                        .headline
                                    )
                                    
                                    
                                    if section.isCompleteBatch {
                                        
                                        Text(
                                            "\(section.readyCount) / 5 ready"
                                        )
                                        .font(
                                            .subheadline
                                        )
                                        .foregroundStyle(
                                            .secondary
                                        )
                                        
                                    } else {
                                        
                                        Text(
                                            "\(section.totalCount) verbs • incomplete section"
                                        )
                                        .font(
                                            .subheadline
                                        )
                                        .foregroundStyle(
                                            .secondary
                                        )
                                    }
                                }
                                
                                
                                Spacer()
                                
                                
                                if section.isReadyForQuiz {
                                    
                                    Image(
                                        systemName:
                                            "checkmark.circle.fill"
                                    )
                                    .foregroundStyle(
                                        .primary
                                    )
                                }
                                
                                
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
    }
    
    
    
    private func verbRow(
        _ item:
        ConjugationVerbItem
    ) -> some View {
        
        HStack(
            spacing:
                AppTheme.Spacing.md
        ) {
            
            VStack(
                alignment: .leading,
                spacing:
                    AppTheme.Spacing.xs
            ) {
                
                Text(
                    item.word.italian
                )
                .font(
                    .headline
                )
                
                
                if let english =
                    item.word.english,
                   !english.isEmpty {
                    
                    Text(
                        english
                    )
                    .font(
                        .subheadline
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }
                
                
                if let turkish =
                    item.word.turkish,
                   !turkish.isEmpty {
                    
                    Text(
                        turkish
                    )
                    .font(
                        .caption
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }
            }
            
            
            Spacer()
            
            
            Label(
                item.isReady
                ? "Ready"
                : "Needs setup",
                systemImage:
                    item.isReady
                ? "checkmark.circle.fill"
                : "pencil.circle"
            )
            .font(
                .caption.weight(
                    .semibold
                )
            )
            .foregroundStyle(
                item.isReady
                ? .primary
                : .secondary
            )
        }
        .padding(
            .vertical,
            AppTheme.Spacing.sm
        )
    }
}
