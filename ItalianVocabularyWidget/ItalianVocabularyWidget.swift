//
//  ItalianVocabularyWidget.swift
//  ItalianVocabularyWidget
//
//  Created by Melih Şişkular on 26.08.2026.
//
import WidgetKit
import SwiftUI


// MARK: - Timeline Entry

struct VocabularyEntry: TimelineEntry {
    
    let date: Date
    let word: WidgetWord?
}


// MARK: - Provider
struct Provider: TimelineProvider {
    
    private let rotationIntervalHours =
    3
    
    private let rotationWordCount =
    8
    
    
    // MARK: - Placeholder
    
    func placeholder(
        in context: Context
    ) -> VocabularyEntry {
        
        VocabularyEntry(
            date: Date(),
            word: previewWord
        )
    }
    
    
    // MARK: - Snapshot
    
    func getSnapshot(
        in context: Context,
        completion:
        @escaping (
            VocabularyEntry
        ) -> Void
    ) {
        
        let rotation =
        WidgetWordStore
            .loadRotation()
        
        let word =
        rotation.first
        ?? WidgetWordStore.load()
        ?? previewWord
        
        completion(
            VocabularyEntry(
                date: Date(),
                word: word
            )
        )
    }
    
    
    // MARK: - Timeline
    
    func getTimeline(
        in context: Context,
        completion:
        @escaping (
            Timeline<VocabularyEntry>
        ) -> Void
    ) {
        
        let currentDate =
        Date()
        
        let rotation =
        WidgetWordStore
            .loadRotation()
        
        
        let availableWords:
        [WidgetWord]
        
        if !rotation.isEmpty {
            
            availableWords =
            rotation
            
        } else if let fallback =
                    WidgetWordStore.load() {
            
            availableWords =
            [fallback]
            
        } else {
            
            availableWords =
            [previewWord]
        }
        
        
        var entries:
        [VocabularyEntry] = []
        
        
        // 8 entry:
        // now
        // +3h
        // +6h
        // ...
        // +21h
        
        for index
                in 0..<rotationWordCount {
            
            let word =
            availableWords[
                index
                % availableWords.count
            ]
            
            let entryDate =
            Calendar.current.date(
                byAdding: .hour,
                value:
                    index
                * rotationIntervalHours,
                to: currentDate
            )
            ?? currentDate
                .addingTimeInterval(
                    Double(
                        index
                        * rotationIntervalHours
                        * 60
                        * 60
                    )
                )
            
            entries.append(
                VocabularyEntry(
                    date: entryDate,
                    word: word
                )
            )
        }
        
        
        // 24 saat sonra WidgetKit
        // yeniden timeline isteyecek.
        
        let nextRefreshDate =
        Calendar.current.date(
            byAdding: .hour,
            value: 24,
            to: currentDate
        )
        ?? currentDate
            .addingTimeInterval(
                24 * 60 * 60
            )
        
        
        let timeline =
        Timeline(
            entries: entries,
            policy:
                    .after(
                        nextRefreshDate
                    )
        )
        
        
        completion(
            timeline
        )
    }
    
    
    // MARK: - Preview
    
    private var previewWord:
    WidgetWord {
        
        WidgetWord(
            italian: "Riuscire",
            english:
                "To succeed / manage",
            turkish:
                "Başarmak",
            italianDefinition:
                "Riuscire a fare qualcosa",
            wordId: 309,
            sequenceNo: 309,
            isDue: false
        )
    }
}



// MARK: - Widget View

struct ItalianVocabularyWidgetEntryView:
    View {
    
    let entry: VocabularyEntry
    
    
    var body: some View {
        
        Group {
            
            if let word =
                entry.word {
                
                vocabularyView(
                    word
                )
                
            } else {
                
                emptyView
            }
        }
        .containerBackground(
            for: .widget
        ) {
            Color.clear
        }
    }
    
    
    // MARK: - Vocabulary
    
    private func vocabularyView(
        _ word: WidgetWord
    ) -> some View {
        
        VStack(
            alignment: .leading,
            spacing: 4
        ) {
            
            Text(word.italian)
                .font(
                    .system(
                        size: 21,
                        weight: .bold
                    )
                )
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            
            if let definition =
                word.italianDefinition,
               !definition.isEmpty {
                
                Text(definition)
                    .font(
                        .system(
                            size: 13,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.primary)
                    .opacity(0.82)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            }
            
            Spacer(minLength: 0)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .widgetURL(
            URL(
                string:
                    "italianvocabulary://word/\(word.wordId)"
            )
        )
    }
    
    // MARK: - Empty State
    
    private var emptyView:
    some View {
        
        VStack(
            alignment: .leading,
            spacing: 3
        ) {
            
            Text("Italiano")
                .font(
                    .headline.bold()
                )
            
            Text(
                "Open the app to prepare a word."
            )
            .font(.caption)
            .foregroundStyle(.primary)
            .opacity(0.72)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
    }
}


// MARK: - Widget

struct ItalianVocabularyWidget:
    Widget {
    
    let kind: String =
    "ItalianVocabularyWidget"
    
    
    var body:
    some WidgetConfiguration {
        
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            
            ItalianVocabularyWidgetEntryView(
                entry: entry
            )
        }
        .configurationDisplayName(
            "Italian Word"
        )
        .description(
            "Keep an Italian word visible on your Lock Screen."
        )
        .supportedFamilies(
            [
                .accessoryRectangular
            ]
        )
        .contentMarginsDisabled()
    }
}


// MARK: - Preview

#Preview(
    as: .accessoryRectangular
) {
    
    ItalianVocabularyWidget()
    
} timeline: {
    
    VocabularyEntry(
        date: .now,
        word:
            WidgetWord(
                italian:
                    "Riuscire",
                english:
                    "To succeed / manage",
                turkish:
                    "Başarmak",
                italianDefinition:
                    "Riuscire a fare qualcosa",
                wordId: 309,
                sequenceNo: 309,
                isDue: false
            )
    )
}
