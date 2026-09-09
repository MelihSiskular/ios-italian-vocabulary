//
//  WidgetWordStore.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 26.08.2026.
//
import Foundation
import WidgetKit

enum WidgetWordStore {
    
    static let appGroupId =
    "group.com.melih.ItalianVocabulary.shared"
    
    private static let wordKey =
    "widget_word"
    
    private static let rotationKey =
    "widget_word_rotation"
    
    private static let rotationCreatedAtKey =
    "widget_rotation_created_at"
    
    
    // MARK: - Current Word
    
    static func save(
        _ word: WidgetWord
    ) {
        
        guard let defaults =
                UserDefaults(
                    suiteName: appGroupId
                )
        else {
            return
        }
        
        do {
            
            let data =
            try JSONEncoder()
                .encode(word)
            
            defaults.set(
                data,
                forKey: wordKey
            )
            
            WidgetCenter.shared
                .reloadAllTimelines()
            
            print(
                "✅ Widget word cached:",
                word.italian
            )
            
        } catch {
            
            print(
                "❌ Widget cache error:",
                error
            )
        }
    }
    
    
    static func load()
    -> WidgetWord? {
        
        guard
            let defaults =
                UserDefaults(
                    suiteName: appGroupId
                ),
            
                let data =
                defaults.data(
                    forKey: wordKey
                )
                
        else {
            return nil
        }
        
        do {
            
            return try JSONDecoder()
                .decode(
                    WidgetWord.self,
                    from: data
                )
            
        } catch {
            
            print(
                "❌ Widget decode error:",
                error
            )
            
            return nil
        }
    }
    
    
    // MARK: - Rotation
    
    static func saveRotation(
        _ words: [WidgetWord]
    ) {
        
        guard !words.isEmpty else {
            return
        }
        
        guard let defaults =
                UserDefaults(
                    suiteName: appGroupId
                )
        else {
            return
        }
        
        do {
            
            let data =
            try JSONEncoder()
                .encode(words)
            
            defaults.set(
                data,
                forKey: rotationKey
            )
            
            defaults.set(
                Date(),
                forKey: rotationCreatedAtKey
            )
            
            // İlk kelime current fallback olarak da tutulsun.
            let firstWordData =
            try JSONEncoder()
                .encode(words[0])
            
            defaults.set(
                firstWordData,
                forKey: wordKey
            )
            
            WidgetCenter.shared
                .reloadAllTimelines()
            
            print(
                "✅ Widget rotation cached:",
                words.map(\.italian)
            )
            
        } catch {
            
            print(
                "❌ Widget rotation cache error:",
                error
            )
        }
    }
    
    
    static func loadRotation()
    -> [WidgetWord] {
        
        guard
            let defaults =
                UserDefaults(
                    suiteName: appGroupId
                ),
            
                let data =
                defaults.data(
                    forKey: rotationKey
                )
                
        else {
            return []
        }
        
        do {
            
            return try JSONDecoder()
                .decode(
                    [WidgetWord].self,
                    from: data
                )
            
        } catch {
            
            print(
                "❌ Widget rotation decode error:",
                error
            )
            
            return []
        }
    }
    
    
    static func rotationCreatedAt()
    -> Date? {
        
        UserDefaults(
            suiteName: appGroupId
        )?
            .object(
                forKey: rotationCreatedAtKey
            ) as? Date
    }
    
    // MARK: - Currently Displayed Word
    
    static func currentDisplayedWord(
        at date: Date = Date()
    ) -> WidgetWord? {
        
        let rotation =
        loadRotation()
        
        // Rotation yoksa eski current-word
        // cache'ini fallback olarak kullan.
        guard !rotation.isEmpty else {
            return load()
        }
        
        guard let createdAt =
                rotationCreatedAt()
        else {
            return load()
            ?? rotation.first
        }
        
        let rotationInterval:
        TimeInterval =
        3 * 60 * 60
        
        let elapsed =
        max(
            0,
            date.timeIntervalSince(
                createdAt
            )
        )
        
        let elapsedSlots =
        Int(
            elapsed
            / rotationInterval
        )
        
        let index =
        elapsedSlots
        % rotation.count
        
        return rotation[index]
    }
    
    
    // MARK: - Clear
    
    static func clear() {
        
        guard let defaults =
                UserDefaults(
                    suiteName: appGroupId
                )
        else {
            return
        }
        
        defaults.removeObject(
            forKey: wordKey
        )
        
        defaults.removeObject(
            forKey: rotationKey
        )
        
        defaults.removeObject(
            forKey: rotationCreatedAtKey
        )
        
        WidgetCenter.shared
            .reloadAllTimelines()
        
        print(
            "🧹 Widget cache cleared"
        )
    }
}
