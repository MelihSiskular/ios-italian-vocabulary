//
//  WordSection.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

struct WordSection: Identifiable {
    let id: Int
    let number: Int
    let words: [Word]
    
    var readyWords: [Word] {
        words.filter { $0.isReady }
    }
    
    var wordCount: Int {
        words.count
    }
    
    var readyCount: Int {
        readyWords.count
    }
    
    var isUnlocked: Bool {
        wordCount == 15 && readyCount == 15
    }
}


enum SectionBuilder {
    
    static func build(
        from words: [Word]
    ) -> [WordSection] {
        
        let grouped = Dictionary(
            grouping: words
        ) { word in
            ((word.sequenceNo - 1) / 15) + 1
        }
        
        return grouped
            .map { sectionNumber, sectionWords in
                WordSection(
                    id: sectionNumber,
                    number: sectionNumber,
                    words: sectionWords.sorted {
                        $0.sequenceNo < $1.sequenceNo
                    }
                )
            }
            .sorted {
                $0.number < $1.number
            }
    }
}
