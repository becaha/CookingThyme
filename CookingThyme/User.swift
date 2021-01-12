//
//  Account.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import Foundation
import GRDB

// TODO: password encryption https://cocoapods.org/pods/CryptoSwift
struct User {
    struct Table {
        static let databaseTableName = "User"
        static let id = "Id"
        static let username = "Username"
        static let password = "Password"
        static let email = "Email"
    }
    
    var id: Int
    var username: String
    var password: String
    var email: String
    
    init() {
        self.id = 0
        self.username = ""
        self.password = ""
        self.email = ""
    }
    
    init(id: Int, username: String, password: String, email: String) {
        self.id = id
        self.username = username
        self.password = password
        self.email = email
    }
    
    init(username: String, password: String, email: String) {
        self.username = username
        self.password = password
        self.email = email
        self.id = 0
    }
    
    init(row: Row) {
        self.id = row[Table.id]
        self.username = row[Table.username]
        self.password = row[Table.password]
        self.email = row[Table.email]
    }
    
    // gets account of user if the password is correct
    func login(username: String, password: String) -> User? {
        if let account = RecipeDB.shared.getAccount(withUsername: username) {
            if isCorrectPassword(account, withPassword: password) {
                return account
            }
        }
        return nil
    }
    
    func signup(username: String, password: String, email: String) -> User? {
        if let account = RecipeDB.shared.createAccount(username: username, password: password, email: email) {
            return login(username: account.username, password: account.password)
        }
        return nil
    }
    
    func isCorrectPassword(_ account: User, withPassword password: String) -> Bool {
        if account.password == password {
            return true
        }
        return false
    }
    
    func delete(id: Int) {
        RecipeDB.shared.deleteAccount(withId: id)
    }
}
