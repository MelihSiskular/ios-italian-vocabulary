//
//  AuthService.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//
import Foundation
import Supabase

final class AuthService {
    
    private let client = SupabaseManager.client
    
    func signIn(
        email: String,
        password: String
    ) async throws {
        
        try await client.auth.signIn(
            email: "feis_melih@hotmail.com",
            password: "enazbirrakam1A"
        )
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func currentSession() async throws -> Session {
        try await client.auth.session
    }
}
