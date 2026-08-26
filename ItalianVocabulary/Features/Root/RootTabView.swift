//
//  RootTabView.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//
import SwiftUI

struct RootTabView: View {
    
    @Binding var widgetWordId: Int?
    
    
    var body: some View {
        
        TabView {
            
            HomeView()
                .tabItem {
                    Label(
                        "Practice",
                        systemImage:
                            "square.grid.2x2"
                    )
                }
            
            LearningProgressView()
                .tabItem {
                    Label(
                        "Progress",
                        systemImage:
                            "chart.bar"
                    )
                }
            
            HistoryView()
                .tabItem {
                    Label(
                        "History",
                        systemImage:
                            "clock.arrow.circlepath"
                    )
                }
        }
        .sheet(
            isPresented:
                widgetDetailPresented
        ) {
            
            widgetDetailSheet
        }
    }
    
    
    // MARK: - Presentation
    
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
    private var widgetDetailSheet: some View {
        
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
