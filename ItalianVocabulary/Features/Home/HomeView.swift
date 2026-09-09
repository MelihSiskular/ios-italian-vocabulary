//
//  HomeView.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import SwiftUI


private struct SelectedWidgetWord:
    Identifiable {
    
    let id: Int
}


struct HomeView: View {
    
    @StateObject private var viewModel =
    HomeViewModel()
    
    @State private var selectedWidgetWord:
    SelectedWidgetWord?
    
    @State private var notificationPath:
    [Int] = []
    
    @State private var
    showVocabularySearch = false
    
    @Binding private var
    requestedSectionNumber: Int?
    
    
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
    
    
    // MARK: - Init
    
    init(
        requestedSectionNumber:
        Binding<Int?> = .constant(nil)
    ) {
        
        self._requestedSectionNumber =
        requestedSectionNumber
    }
    
    
    // MARK: - Body
    
    var body: some View {
        
        NavigationStack(
            path: $notificationPath
        ) {
            
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
            .navigationBarTitleDisplayMode(
                .large
            )
            .toolbar {
                
                ToolbarItemGroup(
                    placement:
                            .topBarTrailing
                ) {
                    
                    Button {
                        
                        showVocabularySearch =
                        true
                        
                    } label: {
                        
                        Image(
                            systemName:
                                "magnifyingglass"
                        )
                    }
                    .accessibilityLabel(
                        "Search vocabulary"
                    )
                    
                    
                    widgetWordButton
                }
            }
            .navigationDestination(
                for: Int.self
            ) { sectionNumber in
                
                notificationSectionDestination(
                    sectionNumber
                )
            }
            .onAppear {
                
                Task {
                    
                    await ReviewNotificationManager
                        .shared
                        .requestAuthorizationIfNeeded()
                    
                    await viewModel
                        .loadSections()
                    
                    openRequestedSectionIfPossible()
                    
                }
            }
            .onChange(
                of: requestedSectionNumber
            ) { _, sectionNumber in
                
                guard sectionNumber != nil
                else {
                    return
                }
                
                Task {
                    
                    await viewModel
                        .loadSections()
                    
                    openRequestedSectionIfPossible()
                }
            }
            .refreshable {
                
                await viewModel
                    .loadSections()
            }
            .sheet(
                item:
                    $selectedWidgetWord
            ) { selected in
                
                widgetWordSheet(
                    wordId:
                        selected.id
                )
            }
            .sheet(
                isPresented:
                    $showVocabularySearch
            ) {
                
                VocabularySearchView()
                    .presentationDetents([
                        .large
                    ])
                    .presentationDragIndicator(
                        .visible
                    )
            }
        }
    }
    
    
    // MARK: - Widget Word Button
    
    private var widgetWordButton:
    some View {
        
        Button {
            
            openCurrentWidgetWord()
            
        } label: {
            
            Image(
                systemName:
                    "text.book.closed"
            )
        }
        .accessibilityLabel(
            "Open widget word"
        )
    }
    
    
    private func openCurrentWidgetWord() {
        
        guard let word =
                WidgetWordStore
            .currentDisplayedWord()
        else {
            
            return
        }
        
        selectedWidgetWord =
        SelectedWidgetWord(
            id: word.wordId
        )
    }
    
    
    // MARK: - Widget Word Sheet
    
    private func widgetWordSheet(
        wordId: Int
    ) -> some View {
        
        NavigationStack {
            
            WidgetWordDetailDestination(
                wordId: wordId
            )
            .navigationTitle("Word")
            .navigationBarTitleDisplayMode(
                .inline
            )
            .toolbar {
                
                ToolbarItem(
                    placement:
                            .topBarTrailing
                ) {
                    
                    Button("Done") {
                        
                        selectedWidgetWord =
                        nil
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
    
    
    // MARK: - Notification Routing
    
    private func
    openRequestedSectionIfPossible() {
        
        guard let sectionNumber =
                requestedSectionNumber
        else {
            
            return
        }
        
        guard let section =
                viewModel.sections
            .first(
                where: {
                    $0.number
                    == sectionNumber
                }
            )
        else {
            
            print(
                "⚠️ Notification section not found:",
                sectionNumber
            )
            
            requestedSectionNumber = nil
            
            return
        }
        
        guard section.isUnlocked
        else {
            
            print(
                "⚠️ Notification section is locked:",
                sectionNumber
            )
            
            requestedSectionNumber = nil
            
            return
        }
        
        notificationPath = [
            sectionNumber
        ]
        
        requestedSectionNumber = nil
        
        print(
            "✅ Navigated to review section:",
            sectionNumber
        )
    }
    
    
    @ViewBuilder
    private func
    notificationSectionDestination(
        _ sectionNumber: Int
    ) -> some View {
        
        if let section =
            viewModel.sections
            .first(
                where: {
                    $0.number
                    == sectionNumber
                }
            ) {
            
            let dueWords =
            viewModel.dueWords(
                for: section
            )
            
            if dueWords.isEmpty {
                
                ContentUnavailableView(
                    "Review up to date",
                    systemImage:
                        "checkmark.circle",
                    description:
                        Text(
                            "Section \(sectionNumber) no longer has words waiting for review."
                        )
                )
                .navigationTitle(
                    "Section \(sectionNumber)"
                )
                .navigationBarTitleDisplayMode(
                    .inline
                )
                
            } else {
                
                SectionDetailView(
                    section: section,
                    progress:
                        viewModel
                        .progressState(
                            for: section
                        ),
                    dueWords:
                        dueWords
                )
            }
            
        } else {
            
            ContentUnavailableView(
                "Section unavailable",
                systemImage:
                    "exclamationmark.triangle",
                description:
                    Text(
                        "Section \(sectionNumber) could not be loaded."
                    )
            )
        }
    }
    
    
    // MARK: - Content
    
    private var content:
    some View {
        
        ScrollView {
            
            VStack(
                alignment: .leading,
                spacing:
                    AppTheme.Spacing.xl
            ) {
                
                header
                
                practiceTypeSection
            }
            .padding(
                .horizontal,
                AppTheme.Layout
                    .horizontalPadding
            )
            .padding(
                .bottom,
                AppTheme.Spacing.xxl
            )
        }
    }
    
    
    // MARK: - Header
    
    private var header:
    some View {
        
        VStack(
            alignment: .leading,
            spacing:
                AppTheme.Spacing.xs
        ) {
            
            Text(
                "La tua pratica"
            )
            .font(
                .title2.bold()
            )
            
            Text(
                "Learn a little. Review often."
            )
            .font(
                .subheadline
            )
            .foregroundStyle(
                .secondary
            )
        }
        .frame(
            maxWidth:
                    .infinity,
            alignment:
                    .leading
        )
    }
    
    // MARK: - Practice Types
    
    private var practiceTypeSection:
    some View {
        
        VStack(
            spacing:
                AppTheme.Spacing.md
        ) {
            
            NavigationLink {
                
                vocabularyPracticeView
                
            } label: {
                
                practiceTypeCard(
                    title: "Vocabulary",
                    subtitle:
                        "Learn words, review them and practice freely.",
                    systemImage:
                        "text.book.closed",
                    badgeCount:
                        viewModel.dueSectionCount
                )
            }
            .buttonStyle(
                .plain
            )
            
            
            NavigationLink {
                
                ConjugationHomeView()
                
            } label: {
                
                practiceTypeCard(
                    title: "Conjugation",
                    subtitle:
                        "Practice Italian verb forms by tense.",
                    systemImage:
                        "textformat"
                )
            }
            .buttonStyle(
                .plain
            )
        }
    }
    
    
    private func practiceTypeCard(
        title: String,
        subtitle: String,
        systemImage: String,
        badgeCount: Int = 0
    ) -> some View {
        
        AppCard {
            
            HStack(
                spacing:
                    AppTheme.Spacing.md
            ) {
                
                Image(
                    systemName:
                        systemImage
                )
                .font(
                    .title2
                )
                .frame(
                    width: 40
                )
                
                
                VStack(
                    alignment: .leading,
                    spacing:
                        AppTheme.Spacing.xs
                ) {
                    
                    Text(
                        title
                    )
                    .font(
                        .headline
                    )
                    
                    Text(
                        subtitle
                    )
                    .font(
                        .subheadline
                    )
                    .foregroundStyle(
                        .secondary
                    )
                    .multilineTextAlignment(
                        .leading
                    )
                }
                
                
                Spacer()
                
                if badgeCount > 0 {
                    
                    Text(
                        badgeCount > 99
                        ? "99+"
                        : "\(badgeCount)"
                    )
                    .font(
                        .caption2.bold()
                    )
                    .foregroundStyle(
                        .white
                    )
                    .padding(
                        .horizontal,
                        7
                    )
                    .frame(
                        minWidth: 24,
                        minHeight: 24
                    )
                    .background(
                        Color.red,
                        in: Capsule()
                    )
                    .accessibilityLabel(
                        "\(badgeCount) sections due for review"
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
    
    // MARK: - Vocabulary Practice
    
    private var vocabularyPracticeView:
    some View {
        
        ScrollView {
            
            VStack(
                alignment: .leading,
                spacing:
                    AppTheme.Spacing.xl
            ) {
                
                VStack(
                    alignment: .leading,
                    spacing:
                        AppTheme.Spacing.xs
                ) {
                    
                    Text(
                        "Vocabulary"
                    )
                    .font(
                        .title2.bold()
                    )
                    
                    Text(
                        "Learn new words and review what you already know."
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
                
                
                sectionGrid
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
            "Vocabulary"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
        .onAppear {
            
            Task {
                
                await viewModel
                    .loadSections()
            }
        }
    }
    
    // MARK: - Sections
    
    private var sectionGrid:
    some View {
        
        LazyVGrid(
            columns: columns,
            spacing:
                AppTheme.Layout
                .gridSpacing
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
            .buttonStyle(
                .plain
            )
            
        } else {
            
            SectionCardView(
                section: section,
                progress: progress
            )
        }
    }
}
