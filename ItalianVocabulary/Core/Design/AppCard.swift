//
//  AppCard.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 26.08.2026.
//

import SwiftUI

struct AppCard<Content: View>: View {
    
    let content: Content
    
    init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }
    
    var body: some View {
        
        content
            .padding(
                AppTheme.Layout.cardPadding
            )
            .background(
                RoundedRectangle(
                    cornerRadius:
                        AppTheme.Radius.large,
                    style: .continuous
                )
                .fill(
                    AppTheme.Colors.cardBackground
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius:
                        AppTheme.Radius.large,
                    style: .continuous
                )
                .stroke(
                    AppTheme.Colors.border,
                    lineWidth: 1
                )
            }
    }
}
