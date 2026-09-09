//
//  RootTabView.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import SwiftUI


private enum RootTab:
    Hashable {
    
    case practice
    case progress
    case history
}


struct RootTabView: View {
    
    @Binding var widgetWordId: Int?
    
    @ObservedObject private var
    reviewRouter =
    ReviewNotificationRouter.shared
    
    @State private var selectedTab:
    RootTab = .practice
    
    
    var body: some View {
        
        TabView(
            selection: $selectedTab
        ) {
            
            HomeView(
                requestedSectionNumber:
                    $reviewRouter
                    .pendingSectionNumber
            )
            .tabItem {
                
                Label(
                    "Practice",
                    systemImage:
                        "square.grid.2x2"
                )
            }
            .tag(
                RootTab.practice
            )
            
            
            LearningProgressView()
                .tabItem {
                    
                    Label(
                        "Progress",
                        systemImage:
                            "chart.bar"
                    )
                }
                .tag(
                    RootTab.progress
                )
            
            
            HistoryView()
                .tabItem {
                    
                    Label(
                        "History",
                        systemImage:
                            "clock.arrow.circlepath"
                    )
                }
                .tag(
                    RootTab.history
                )
        }
        .onAppear {
            
            if reviewRouter
                .pendingSectionNumber
                != nil {
                
                selectedTab =
                    .practice
            }
        }
        .onChange(
            of:
                reviewRouter
                .pendingSectionNumber
        ) { _, sectionNumber in
            
            guard sectionNumber
                    != nil
            else {
                return
            }
            
            selectedTab =
                .practice
        }
        .sheet(
            isPresented:
                widgetDetailPresented
        ) {
            
            widgetDetailSheet
        }
    }
    
    
    // MARK: - Widget Presentation
    
    private var widgetDetailPresented:
    Binding<Bool> {
        
        Binding(
            
            get: {
                
                widgetWordId != nil
            },
            
            set: { isPresented in
                
                if !isPresented {
                    
                    widgetWordId = nil
                }
            }
        )
    }
    
    
    @ViewBuilder
    private var widgetDetailSheet:
    some View {
        
        if let wordId =
            widgetWordId {
            
            NavigationStack {
                
                WidgetWordDetailDestination(
                    wordId: wordId
                )
                .toolbar {
                    
                    ToolbarItem(
                        placement:
                                .confirmationAction
                    ) {
                        
                        Button("Done") {
                            
                            widgetWordId = nil
                        }
                    }
                }
            }
        }
    }
}
