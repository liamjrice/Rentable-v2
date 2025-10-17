//
//  SupabaseManager.swift
//  Rentable v2
//
//  Created by Liam Rice on 17/10/2025.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()

    // MARK: - Client setup
    let client: SupabaseClient

    private init() {
        let supabaseUrl = URL(string: "https://chiiqjwlhwnchkaygivx.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNoaWlxandsaHduY2hrYXlnaXZ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2NTk4NDMsImV4cCI6MjA3NjIzNTg0M30.2fpKvEaCHzExjg_I1JudBKtsDuaXeOnjouhXARJWJZk"

        client = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
    }
}

