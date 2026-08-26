//
//  HomeView.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel =
    HomeViewModel()
    
    private let columns = [
        
        GridItem(
            .flexible(),
            spacing:
                AppTheme.Layout.gridSpacing
        ),
        
        GridItem(
            .flexible(),
            spacing:
                AppTheme.Layout.gridSpacing
        )
    ]
    
    
    var body: some View {
        
        NavigationStack {
            
            Group {
                
                if viewModel.isLoading {
                    
                    ProgressView(
                        "Preparing your vocabulary..."
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
                    
                } else {
                    
                    content
                }
            }
            .navigationTitle("Italiano")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadSections()           
            }
            .refreshable {
                await viewModel.loadSections()
            }
        }
    }
    
    
    // MARK: - Content
    
    private var content: some View {
        
        ScrollView {
            
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xl
            ) {
                
                header
                
                sectionGrid
            }
            .padding(
                .horizontal,
                AppTheme.Layout.horizontalPadding
            )
            .padding(
                .bottom,
                AppTheme.Spacing.xxl
            )
        }
    }
    
    
    // MARK: - Header
    
    private var header: some View {
        
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.xs
        ) {
            
            Text("La tua pratica")
                .font(.title2.bold())
            
            Text(
                "Learn a little. Review often."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }
    
    
    // MARK: - Sections
    
    private var sectionGrid: some View {
        
        LazyVGrid(
            columns: columns,
            spacing:
                AppTheme.Layout.gridSpacing
        ) {
            
            ForEach(
                viewModel.sections
            ) { section in
                
                sectionDestination(
                    section
                )
            }
        }
    }
    
    
    // MARK: - Section Destination
    
    @ViewBuilder
    private func sectionDestination(
        _ section: WordSection
    ) -> some View {
        
        let progress =
        viewModel.progressState(
            for: section
        )
        
        if section.isUnlocked {
            
            NavigationLink {
                
                SectionDetailView(
                    section: section,
                    progress: progress,
                    dueWords:
                        viewModel.dueWords(
                            for: section
                        )
                )
                
            } label: {
                
                SectionCardView(
                    section: section,
                    progress: progress
                )
            }
            .buttonStyle(.plain)
            
        } else {
            
            SectionCardView(
                section: section,
                progress: progress
            )
        }
    }
}
