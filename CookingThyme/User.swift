//
//  User.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import Foundation
import GRDB

// TODO: password encryption https://cocoapods.org/pods/CryptoSwift
struct User {
    static let userKey = "CookingThymeCurrentUser"

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
    
    // saves current username to user defaults to keep user logged in
    func setCurrentUser(_ username: String?) {
        UserDefaults.standard.set(username, forKey: User.userKey)
    }
    
    
    // gets user of user if the password is correct
    func login(username: String, password: String) -> User? {
        if let user = RecipeDB.shared.getUser(withUsername: username) {
            if isCorrectPassword(user, withPassword: password) {
                setCurrentUser(user.username)
                return user
            }
        }
        // resets current user due to failed login attempt
        setCurrentUser(nil)
        return nil
    }
    
    func signup(username: String, password: String, email: String) -> User? {
        if let user = RecipeDB.shared.createUser(username: username, password: password, email: email) {
            return login(username: user.username, password: user.password)
        }
        return nil
    }
    
    func isCorrectPassword(_ user: User, withPassword password: String) -> Bool {
        if user.password == password {
            return true
        }
        return false
    }
    
    func delete(id: Int) {
        RecipeDB.shared.deleteUser(withId: id)
    }
    
    func getUserCollection() -> RecipeCollectionVM? {
        if let collection = RecipeDB.shared.getCollection(withUsername: username) {
            return RecipeCollectionVM(collection: collection)
        }
        return nil
    }
    
    func createUserCollection() {
        RecipeDB.shared.createCollection(withUsername: username)
    }
}
