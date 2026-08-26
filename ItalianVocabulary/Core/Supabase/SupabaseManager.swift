//
//  SupabaseManager.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//

import Foundation
import Supabase

enum SupabaseManager {
    
    static let client = SupabaseClient(
        supabaseURL: URL(
            string: "https://orjzatinnnhuhrctpiue.supabase.co"
        )!,
        supabaseKey: "sb_publishable_9CxQiJQdzTo6Fc49jJUCnA_1QrUoqN6",
        options: .init(
            auth: .init(
                emitLocalSessionAsInitialSession: true
            )
        )
    )
}
