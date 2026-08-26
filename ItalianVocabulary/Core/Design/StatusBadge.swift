//
//  StatusBadge.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 26.08.2026.
//

import SwiftUI

struct StatusBadge: View {
    
    let title: String
    let systemImage: String?
    
    init(
        _ title: String,
        systemImage: String? = nil
    ) {
        self.title = title
        self.systemImage = systemImage
    }
    
    var body: some View {
        
        HStack(
            spacing: AppTheme.Spacing.xs
        ) {
            
            if let systemImage {
                Image(
                    systemName: systemImage
                )
            }
            
            Text(title)
        }
        .font(
            .caption.weight(.semibold)
        )
        .foregroundStyle(.secondary)
        .padding(
            .horizontal,
            AppTheme.Spacing.sm
        )
        .padding(
            .vertical,
            AppTheme.Spacing.xs
        )
        .background(
            Capsule()
                .fill(
                    Color.primary.opacity(0.06)
                )
        )
    }
}
