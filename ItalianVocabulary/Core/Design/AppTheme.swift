//
//  AppTheme.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 26.08.2026.
//

import SwiftUI

enum AppTheme {
    
    // MARK: - Spacing
    
    enum Spacing {
        static let xs: CGFloat = 6
        static let sm: CGFloat = 10
        static let md: CGFloat = 16
        static let lg: CGFloat = 22
        static let xl: CGFloat = 30
        static let xxl: CGFloat = 40
    }
    
    
    // MARK: - Radius
    
    enum Radius {
        static let small: CGFloat = 12
        static let medium: CGFloat = 18
        static let large: CGFloat = 24
    }
    
    
    // MARK: - Layout
    
    enum Layout {
        static let horizontalPadding: CGFloat = 18
        static let cardPadding: CGFloat = 18
        static let gridSpacing: CGFloat = 14
    }
    
    
    // MARK: - Colors
    
    enum Colors {
        
        static let cardBackground =
        Color(.secondarySystemBackground)
        
        static let subtleBackground =
        Color(.tertiarySystemBackground)
        
        static let primaryText =
        Color.primary
        
        static let secondaryText =
        Color.secondary
        
        static let divider =
        Color.primary.opacity(0.08)
        
        static let border =
        Color.primary.opacity(0.06)
        
        static let accent =
        Color.accentColor
    }
}
