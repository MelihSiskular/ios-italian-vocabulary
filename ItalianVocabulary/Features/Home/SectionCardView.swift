//
//  SectionCardView.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//
import SwiftUI

struct SectionCardView: View {
    
    let section: WordSection
    let progress: SectionProgressState
    
    
    // MARK: - State
    
    private var statusText: String {
        
        if !section.isUnlocked {
            return "Coming soon"
        }
        
        if progress.hasDueReviews {
            return "\(progress.dueCount) due"
        }
        
        if progress.isUpToDate {
            return "Up to date"
        }
        
        return "Start"
    }
    
    private var statusIcon: String {
        
        if !section.isUnlocked {
            return "lock.fill"
        }
        
        if progress.hasDueReviews {
            return "arrow.clockwise"
        }
        
        if progress.isUpToDate {
            return "checkmark"
        }
        
        return "play.fill"
    }
    
    private var displayedCount: Int {
        
        section.isUnlocked
        ? progress.completedCount
        : section.readyCount
    }
    
    
    // MARK: - Body
    
    var body: some View {
        
        AppCard {
            
            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.md
            ) {
                
                header
                
                Spacer(minLength: 4)
                
                progressContent
            }
            .frame(
                maxWidth: .infinity,
                minHeight: 112,
                alignment: .leading
            )
        }
        .background {
            dueHighlight
        }
        .accessibilityElement(
            children: .ignore
        )
        .accessibilityLabel(
            accessibilityTitle
        )
    }
    
    
    // MARK: - Header
    
    private var header: some View {
        
        HStack(spacing: AppTheme.Spacing.sm) {
            
            Text("Section \(section.number)")
                .font(.headline)
            
            Spacer()
            
            if !section.isUnlocked {
                
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
            } else if progress.isUpToDate {
                
                Image(
                    systemName: "checkmark.circle.fill"
                )
                .font(.subheadline)
                .foregroundStyle(
                    AppTheme.Colors.accent
                )
            }
        }
    }
    
    
    // MARK: - Progress
    
    private var progressContent: some View {
        
        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {
            
            HStack(
                alignment: .firstTextBaseline,
                spacing: 3
            ) {
                
                Text("\(displayedCount)")
                    .font(
                        .system(
                            size: 30,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                
                Text("/ 15")
                    .font(
                        .system(
                            size: 17,
                            weight: .medium,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(.secondary)
            }
            
            StatusBadge(
                statusText,
                systemImage: statusIcon
            )
        }
    }
    
    
    // MARK: - Due Highlight
    
    @ViewBuilder
    private var dueHighlight: some View {
        
        if section.isUnlocked,
           progress.hasDueReviews {
            
            RoundedRectangle(
                cornerRadius:
                    AppTheme.Radius.large,
                style: .continuous
            )
            .stroke(
                AppTheme.Colors.accent
                    .opacity(0.22),
                lineWidth: 1
            )
        }
    }
    
    // MARK: - Helper
    private var accessibilityTitle: String {
        
        if !section.isUnlocked {
            
            return
            "Section \(section.number). \(section.readyCount) of 15 words ready. Coming soon."
        }
        
        if progress.hasDueReviews {
            
            return
            "Section \(section.number). \(progress.completedCount) of 15 up to date. \(progress.dueCount) due for review."
        }
        
        if progress.isUpToDate {
            
            return
            "Section \(section.number). 15 of 15. Up to date."
        }
        
        return
        "Section \(section.number). Not started."
    }
}
