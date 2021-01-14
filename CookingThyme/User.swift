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
    func setCurrentUsername(_ username: String?) {
        UserDefaults.standard.set(username, forKey: User.userKey)
    }
    
    
    // gets user of user if the password is correct
    mutating func signin(username: String, password: String) throws -> User? {
        if let user = RecipeDB.shared.getUser(withUsername: username) {
            if isCorrectPassword(user, withPassword: password) {
                self = user
                setCurrentUsername(user.username)
                return user
            }
        }
        // resets current user due to failed sign in attempt
        setCurrentUsername(nil)
        throw UserError.badSignin
    }
    
    mutating func signup(username: String, password: String, email: String) throws -> User? {
        do {
            if let user = try RecipeDB.shared.createUser(username: username, password: password, email: email) {
                return try signin(username: user.username, password: user.password)
            }
        }
        catch CreateUserError.usernameTaken {
            throw UserError.badSignup(taken: "username")
        }
        catch CreateUserError.emailTaken {
            throw UserError.badSignup(taken: "email")
        }
        throw UserError.badSignup(taken: "")
    }
    
    // deletes current auth and user defaults and resets to blank user
    mutating func signout() {
        RecipeDB.shared.deleteAuth(withUserId: id)
        setCurrentUsername(nil)
        self = User()
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
        if let collection = RecipeDB.shared.createCollection(withUsername: username) {
            RecipeDB.shared.createCategory(withName: "All", forCollectionId: collection.id)
        }
    }
}

enum UserError: Error {
    case badSignin
    case badSignup(taken: String)
}
