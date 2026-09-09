//
//  ConjugationSectionDetailView.swift
//  ItalianVocabulary
//

import SwiftUI


struct ConjugationSectionDetailView:
    View {
    
    let section:
    ConjugationSection
    
    let tense:
    ConjugationTense
    
    
    @State private var items:
    [ConjugationVerbItem]
    
    @State private var isRefreshing =
    false
    
    
    private let service =
    ConjugationService()
    
    // MARK: - Quiz Action
    
    private var quizActionArea:
    some View {
        
        VStack(
            spacing: 0
        ) {
            
            Divider()
            
            
            NavigationLink {
                
                ConjugationQuizView(
                    sectionNumber:
                        section.number,
                    items:
                        items,
                    tense:
                        tense
                )
                
            } label: {
                
                HStack(
                    spacing:
                        AppTheme.Spacing.sm
                ) {
                    
                    Image(
                        systemName:
                            isReadyForQuiz
                        ? "play.fill"
                        : "lock.fill"
                    )
                    
                    Text(
                        isReadyForQuiz
                        ? "Start 30 Questions"
                        : "Complete \(items.count - readyCount) Verbs"
                    )
                    .fontWeight(
                        .semibold
                    )
                }
                .frame(
                    maxWidth:
                            .infinity
                )
            }
            .buttonStyle(
                .borderedProminent
            )
            .controlSize(
                .large
            )
            .disabled(
                !isReadyForQuiz
            )
            .padding(
                .horizontal,
                AppTheme.Layout
                    .horizontalPadding
            )
            .padding(
                .vertical,
                AppTheme.Spacing.md
            )
        }
        .background(
            .bar
        )
    }
    
    init(
        section: ConjugationSection,
        tense: ConjugationTense
    ) {
        
        self.section = section
        self.tense = tense
        
        _items = State(
            initialValue:
                section.items
        )
    }
    
    
    private var readyCount: Int {
        
        items.filter {
            $0.isReady
        }
        .count
    }
    
    
    private var isCompleteBatch: Bool {
        items.count == 5
    }
    
    
    private var isReadyForQuiz: Bool {
        
        isCompleteBatch
        && readyCount == items.count
    }
    
    
    var body: some View {
        
        ScrollView {
            
            VStack(
                alignment: .leading,
                spacing:
                    AppTheme.Spacing.xl
            ) {
                
                summaryCard
                
                verbList
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
            "Section \(section.number)"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
        .task {
            
            await refresh()
        }
        .safeAreaInset(
            edge: .bottom
        ) {
            
            if isCompleteBatch {
                
                quizActionArea
            }
        }
    }
    
    
    // MARK: - Summary
    
    private var summaryCard:
    some View {
        
        AppCard {
            
            VStack(
                alignment: .leading,
                spacing:
                    AppTheme.Spacing.md
            ) {
                
                Text(
                    "\(readyCount) of \(items.count) ready"
                )
                .font(
                    .title2.bold()
                )
                
                
                if isReadyForQuiz {
                    
                    Text(
                        "All verb forms are ready. This section contains 30 conjugation questions."
                    )
                    .font(
                        .subheadline
                    )
                    .foregroundStyle(
                        .secondary
                    )
                    
                } else if !isCompleteBatch {
                    
                    Text(
                        "This section currently contains \(items.count) verbs. Five verbs are required for a full quiz."
                    )
                    .font(
                        .subheadline
                    )
                    .foregroundStyle(
                        .secondary
                    )
                    
                } else {
                    
                    Text(
                        "Complete all six forms for every verb to unlock the quiz."
                    )
                    .font(
                        .subheadline
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }
            }
        }
    }
    
    
    // MARK: - Verbs
    
    private var verbList:
    some View {
        
        AppCard {
            
            VStack(
                spacing: 0
            ) {
                
                ForEach(
                    Array(
                        items.enumerated()
                    ),
                    id: \.element.id
                ) { index, item in
                    
                    NavigationLink {
                        
                        ConjugationEditView(
                            item: item,
                            tense: tense
                        )
                        .onDisappear {
                            
                            Task {
                                await refresh()
                            }
                        }
                        
                    } label: {
                        
                        verbRow(
                            item
                        )
                    }
                    .buttonStyle(
                        .plain
                    )
                    
                    
                    if index
                        < items.count - 1 {
                        
                        Divider()
                    }
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
            
            
            Image(
                systemName:
                    item.isReady
                ? "checkmark.circle.fill"
                : "pencil.circle"
            )
            .foregroundStyle(
                item.isReady
                ? .primary
                : .secondary
            )
            
            
            Image(
                systemName:
                    "chevron.right"
            )
            .font(
                .caption
            )
            .foregroundStyle(
                .tertiary
            )
        }
        .padding(
            .vertical,
            AppTheme.Spacing.sm
        )
    }
    
    
    // MARK: - Refresh
    
    @MainActor
    private func refresh() async {
        
        guard !isRefreshing else {
            return
        }
        
        isRefreshing = true
        
        defer {
            isRefreshing = false
        }
        
        
        do {
            
            let conjugations =
            try await service
                .fetchConjugations(
                    tense: tense
                )
            
            
            let byWordId =
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
            section.items.map {
                item in
                
                ConjugationVerbItem(
                    word:
                        item.word,
                    conjugation:
                        byWordId[
                            item.word.id
                        ]
                )
            }
            
        } catch {
            
            print(
                "❌ Conjugation section refresh failed:",
                error
            )
        }
    }
}
