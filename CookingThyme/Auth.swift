//
//  Auth.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import Foundation
import GRDB

struct Auth {
    // TODO: allow a sign in for a year?
    let signinDuration: TimeInterval = 31536000
    static let formatter = DateFormatter()
    
    struct Table {
        static let databaseTableName = "Auth"
        static let id = "Id"
        static let userId = "UserId"
        static let authToken = "AuthToken"
        static let timestamp = "Timestamp"
    }
    
    var id: Int
    var userId: Int
    var authToken: String
    var timestamp: String
    
    init() {
        id = 0
        userId = 0
        authToken = ""
        timestamp = ""
    }
    
    init(userId: Int) {
        self.id = 0
        self.userId = userId
        self.authToken = ""
        self.timestamp = ""
        self.authToken = ""
        self.timestamp = ""
    }
    
    init(id: Int, userId: Int, authToken: String, timestamp: String) {
        self.id = id
        self.userId = userId
        self.authToken = authToken
        self.timestamp = timestamp
    }
    
    init(row: Row) {
        self.id = row[Table.id]
        self.userId = row[Table.userId]
        self.authToken = row[Table.authToken]
        self.timestamp = row[Table.timestamp]
    }
    
    // logs the user in and returns the auth token
    static func signin(withUserId userId: Int) -> String? {
        if let auth = RecipeDB.shared.createAuth(withUserId: userId, authToken: createAuthToken(), timestamp: createTimestamp()) {
            if auth.isValid() {
                return auth.authToken
            }
        }
        return nil
    }
    
    static func createAuthToken() -> String {
        return UUID().uuidString
    }
    
    static func createTimestamp() -> String {
        return formatter.string(from: Date())
    }
    
    func isValid() -> Bool {
        if let timestamp = Auth.formatter.date(from: timestamp) {
            if Date().distance(to: timestamp) < signinDuration {
                return true
            }
        }
        return false
    }
    
    func signout(withUserId userId: Int) {
        RecipeDB.shared.deleteAuth(withUserId: userId)
    }
}
