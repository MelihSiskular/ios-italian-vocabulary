//
//  AnalyticsService.swift
//  ItalianVocabulary
//
//  Created by Melih Şişkular on 25.08.2026.
//
import Foundation
import Supabase


struct HistorySessionPage {
    
    let sessions: [QuizSessionRecord]
    let totalCount: Int
}


final class AnalyticsService {
    
    private let client = SupabaseManager.client
    
    private let attemptPageSize = 500
    
    
    
    
    // MARK: - Existing Progress Analytics
    
    func fetchProgress() async throws -> [WordProgress] {
        
        let session = try await client.auth.session
        
        let progress: [WordProgress] = try await client
            .from("word_progress")
            .select()
            .eq(
                "user_id",
                value: session.user.id
            )
            .execute()
            .value
        
        return progress
    }
    
    
    func fetchSessions() async throws -> [QuizSessionRecord] {
        
        let session = try await client.auth.session
        
        let sessions: [QuizSessionRecord] = try await client
            .from("quiz_sessions")
            .select()
            .eq(
                "user_id",
                value: session.user.id
            )
            .order(
                "started_at",
                ascending: false
            )
            .execute()
            .value
        
        return sessions
    }
    
    
    func fetchAttempts() async throws -> [ReviewAttemptRecord] {
        
        let session =
        try await client.auth.session
        
        var allAttempts:
        [ReviewAttemptRecord] = []
        
        var from = 0
        
        while true {
            
            let to =
            from + attemptPageSize - 1
            
            let page:
            [ReviewAttemptRecord] =
            try await client
                .from("review_attempts")
                .select()
                .eq(
                    "user_id",
                    value: session.user.id
                )
                .order(
                    "created_at",
                    ascending: false
                )
                .range(
                    from: from,
                    to: to
                )
                .execute()
                .value
            
            allAttempts.append(
                contentsOf: page
            )
            
            if page.count
                < attemptPageSize {
                break
            }
            
            from += attemptPageSize
        }
        
        return allAttempts
    }
    
    
    func fetchWords() async throws -> [Word] {
        
        let words: [Word] = try await client
            .from("words")
            .select()
            .order(
                "sequence_no",
                ascending: true
            )
            .execute()
            .value
        
        return words
    }
    
    
    // MARK: - History Pagination
    
    func fetchHistoryPage(
        page: Int,
        pageSize: Int,
        startDate: Date?,
        endDateExclusive: Date?
    ) async throws -> HistorySessionPage {
        
        let authSession =
        try await client.auth.session
        
        let userId = authSession.user.id
        
        let safePage = max(page, 1)
        
        let from =
        (safePage - 1) * pageSize
        
        let to =
        from + pageSize - 1
        
        
        // MARK: Data Query
        
        var dataQuery = client
            .from("quiz_sessions")
            .select()
            .eq(
                "user_id",
                value: userId
            )
        
        if let startDate {
            
            dataQuery = dataQuery.gte(
                "started_at",
                value: isoString(startDate)
            )
        }
        
        if let endDateExclusive {
            
            dataQuery = dataQuery.lt(
                "started_at",
                value:
                    isoString(
                        endDateExclusive
                    )
            )
        }
        
        let sessions: [QuizSessionRecord] =
        try await dataQuery
            .order(
                "started_at",
                ascending: false
            )
            .range(
                from: from,
                to: to
            )
            .execute()
            .value
        
        
        // MARK: Count Query
        
        var countQuery = client
            .from("quiz_sessions")
            .select(
                "*",
                head: true,
                count: .exact
            )
            .eq(
                "user_id",
                value: userId
            )
        
        if let startDate {
            
            countQuery = countQuery.gte(
                "started_at",
                value: isoString(startDate)
            )
        }
        
        if let endDateExclusive {
            
            countQuery = countQuery.lt(
                "started_at",
                value:
                    isoString(
                        endDateExclusive
                    )
            )
        }
        
        let response =
        try await countQuery.execute()
        
        let totalCount =
        response.count ?? 0
        
        return HistorySessionPage(
            sessions: sessions,
            totalCount: totalCount
        )
    }
    
    
    // MARK: - Attempts For Visible Sessions
    
    func fetchAttempts(
        sessionIds: [UUID]
    ) async throws -> [ReviewAttemptRecord] {
        
        guard !sessionIds.isEmpty else {
            return []
        }
        
        let authSession =
        try await client.auth.session
        
        let values =
        sessionIds.map {
            $0.uuidString
        }
        
        var allAttempts:
        [ReviewAttemptRecord] = []
        
        var from = 0
        
        while true {
            
            let to =
            from + attemptPageSize - 1
            
            let page:
            [ReviewAttemptRecord] =
            try await client
                .from("review_attempts")
                .select()
                .eq(
                    "user_id",
                    value: authSession.user.id
                )
                .in(
                    "session_id",
                    values: values
                )
                .order(
                    "created_at",
                    ascending: true
                )
                .range(
                    from: from,
                    to: to
                )
                .execute()
                .value
            
            allAttempts.append(
                contentsOf: page
            )
            
            if page.count
                < attemptPageSize {
                break
            }
            
            from += attemptPageSize
        }
        
        return allAttempts
    }
    
    // MARK: - Last 30 Days Chart
    
    func fetchAttempts(
        from startDate: Date,
        toExclusive endDate: Date
    ) async throws -> [ReviewAttemptRecord] {
        
        let authSession =
        try await client.auth.session
        
        var allAttempts:
        [ReviewAttemptRecord] = []
        
        var from = 0
        
        while true {
            
            let to =
            from + attemptPageSize - 1
            
            let page:
            [ReviewAttemptRecord] =
            try await client
                .from("review_attempts")
                .select()
                .eq(
                    "user_id",
                    value: authSession.user.id
                )
                .gte(
                    "created_at",
                    value:
                        isoString(
                            startDate
                        )
                )
                .lt(
                    "created_at",
                    value:
                        isoString(
                            endDate
                        )
                )
                .order(
                    "created_at",
                    ascending: true
                )
                .range(
                    from: from,
                    to: to
                )
                .execute()
                .value
            
            allAttempts.append(
                contentsOf: page
            )
            
            if page.count
                < attemptPageSize {
                break
            }
            
            from += attemptPageSize
        }
        
        print(
            "📊 30-day attempts fetched:",
            allAttempts.count
        )
        
        if let first =
            allAttempts.first,
           let last =
            allAttempts.last {
            
            print(
                "📅 Attempt range:",
                first.createdAt,
                "→",
                last.createdAt
            )
        }
        
        return allAttempts
    }
    
    // MARK: - Date Encoding
    
    private func isoString(
        _ date: Date
    ) -> String {
        
        ISO8601DateFormatter()
            .string(from: date)
    }
}
