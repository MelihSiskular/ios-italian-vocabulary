//
//  VocabularySearchView.swift
//  ItalianVocabulary
//

import SwiftUI


struct VocabularySearchView: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    @StateObject private var viewModel =
    VocabularySearchViewModel()
    
    @State private var selectedWord:
    Word?
    
    
    var body: some View {
        
        NavigationStack {
            
            Group {
                
                if viewModel.isLoading {
                    
                    ProgressView(
                        "Loading vocabulary..."
                    )
                    
                } else if let errorMessage =
                            viewModel.errorMessage {
                    
                    ContentUnavailableView(
                        "Something went wrong",
                        systemImage:
                            "exclamationmark.triangle",
                        description:
                            Text(errorMessage)
                    )
                    
                } else if viewModel
                    .query
                    .trimmingCharacters(
                        in:
                                .whitespacesAndNewlines
                    )
                        .isEmpty {
                    
                    emptySearchView
                    
                } else if viewModel
                    .results
                    .isEmpty {
                    
                    noResultsView
                    
                } else {
                    
                    resultsList
                }
            }
            .navigationTitle(
                "Vocabulary"
            )
            .navigationBarTitleDisplayMode(
                .inline
            )
            .searchable(
                text:
                    $viewModel.query,
                placement:
                        .navigationBarDrawer(
                            displayMode:
                                    .always
                        ),
                prompt:
                    "Italian, Turkish or English"
            )
            .toolbar {
                
                ToolbarItem(
                    placement:
                            .confirmationAction
                ) {
                    
                    Button("Done") {
                        
                        dismiss()
                    }
                }
            }
            .task {
                
                await viewModel
                    .loadWords()
            }
            .sheet(
                item:
                    $selectedWord
            ) { word in
                
                wordDetailSheet(
                    word: word
                )
            }
        }
    }
    
    
    // MARK: - Results
    
    private var resultsList:
    some View {
        
        List(
            viewModel.results
        ) { word in
            
            Button {
                
                selectedWord =
                word
                
            } label: {
                
                wordRow(
                    word
                )
            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
    }
    
    
    private func wordRow(
        _ word: Word
    ) -> some View {
        
        HStack(
            spacing: 14
        ) {
            
            VStack(
                alignment: .leading,
                spacing: 5
            ) {
                
                Text(
                    word.italian
                )
                .font(
                    .headline
                )
                .foregroundStyle(
                    .primary
                )
                
                
                let subtitle =
                translationText(
                    for: word
                )
                
                if !subtitle.isEmpty {
                    
                    Text(
                        subtitle
                    )
                    .font(
                        .subheadline
                    )
                    .foregroundStyle(
                        .secondary
                    )
                    .lineLimit(2)
                }
            }
            
            
            Spacer()
            
            
            VStack(
                alignment: .trailing,
                spacing: 4
            ) {
                
                Text(
                    "S\(word.sectionNumber)"
                )
                .font(
                    .caption
                )
                .foregroundStyle(
                    .tertiary
                )
                
                Image(
                    systemName:
                        "chevron.right"
                )
                .font(
                    .caption
                        .weight(.semibold)
                )
                .foregroundStyle(
                    .tertiary
                )
            }
        }
        .padding(
            .vertical,
            5
        )
        .contentShape(
            Rectangle()
        )
    }
    
    
    private func translationText(
        for word: Word
    ) -> String {
        
        [
            word.turkish,
            word.english
        ]
            .compactMap { value in
                
                guard let value else {
                    return nil
                }
                
                let trimmed =
                value
                    .trimmingCharacters(
                        in:
                                .whitespacesAndNewlines
                    )
                
                return trimmed.isEmpty
                ? nil
                : trimmed
            }
            .joined(
                separator: " · "
            )
    }
    
    
    // MARK: - Empty States
    
    private var emptySearchView:
    some View {
        
        ContentUnavailableView(
            "Search your vocabulary",
            systemImage:
                "magnifyingglass",
            description:
                Text(
                    "Find a word in Italian, Turkish or English."
                )
        )
    }
    
    
    private var noResultsView:
    some View {
        
        ContentUnavailableView.search(
            text:
                viewModel.query
        )
    }
    
    
    // MARK: - Word Detail
    
    private func wordDetailSheet(
        word: Word
    ) -> some View {
        
        NavigationStack {
            
            WordDetailView(
                word: word
            )
            .navigationTitle(
                "Word"
            )
            .navigationBarTitleDisplayMode(
                .inline
            )
            .toolbar {
                
                ToolbarItem(
                    placement:
                            .confirmationAction
                ) {
                    
                    Button("Done") {
                        
                        selectedWord = nil
                    }
                }
            }
        }
        .presentationDetents([
            .large
        ])
        .presentationDragIndicator(
            .visible
        )
    }
}
