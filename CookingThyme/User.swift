//
//  User.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import Foundation
import GRDB
import CryptoKit

struct User {
    static let userKey = "CookingThymeCurrentUser"

    struct Table {
        static let databaseTableName = "User"
        static let id = "Id"
        static let username = "Username"
        static let salt = "Salt"
        static let hashedPassword = "HashedPassword"
        static let email = "Email"
    }
    
    var id: Int
    var username: String
    var salt: String
    var hashedPassword: String
    var email: String
    
    init() {
        self.id = 0
        self.username = ""
        self.salt = ""
        self.hashedPassword = ""
        self.email = ""
    }
    
    init(id: Int, username: String, salt: String, hashedPassword: String, email: String) {
        self.id = id
        self.username = username
        self.salt = salt
        self.hashedPassword = hashedPassword
        self.email = email
    }
    
    init(username: String, salt: String, hashedPassword: String, email: String) {
        self.username = username
        self.salt = salt
        self.hashedPassword = hashedPassword
        self.email = email
        self.id = 0
    }
    
    init(row: Row) {
        self.id = row[Table.id]
        self.username = row[Table.username]
        self.salt = row[Table.salt]
        self.hashedPassword = row[Table.hashedPassword]
        self.email = row[Table.email]
    }
    
    // saves current username to user defaults to keep user logged in
    static func setCurrentUsername(_ username: String?) {
        UserDefaults.standard.set(username, forKey: User.userKey)
    }
    
    // gets user of user if the password is correct
    mutating func signin(username: String, password: String) throws -> User? {
        if let user = RecipeDB.shared.getUser(withUsername: username) {
            if isCorrectPassword(user, withPassword: password) {
                self = user
                User.setCurrentUsername(user.username)
                return user
            }
        }
        // resets current user due to failed sign in attempt
        User.setCurrentUsername(nil)
        throw UserError.badSignin
    }
    
    mutating func signup(username: String, password: String, email: String) throws -> User? {
        do {
            let salt = UUID().uuidString
            let hashedPassword = hashPassword(password, withSalt: salt)
            if let user = try RecipeDB.shared.createUser(username: username, salt: salt, hashedPassword: hashedPassword, email: email) {
                return try signin(username: user.username, password: password)
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
    
    mutating func changePassword(oldPassword: String, newPassword: String) throws {
        if isCorrectPassword(self, withPassword: oldPassword) {
            let hashedPassword = hashPassword(newPassword, withSalt: self.salt)
            if !RecipeDB.shared.updateUser(withId: id, username: username, salt: salt, hashedPassword: hashedPassword, email: email) {
                throw ChangePasswordError.badNewPassword
            }
            self.hashedPassword = hashedPassword
            return
        }
        throw ChangePasswordError.incorrectOldPassword
    }

    func hashPassword(_ password: String, withSalt salt: String) -> String {
        var passwordString = password
        passwordString.append(salt)

        let inputData = Data(passwordString.utf8)

        let hashed = SHA256.hash(data: inputData)
        
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func hashPassword(_ password: String) -> String {
        var passwordString = password
        passwordString.append(self.salt)

        let inputData = Data(passwordString.utf8)

        let hashed = SHA256.hash(data: inputData)
        
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func isCorrectPassword(_ user: User, withPassword password: String) -> Bool {
        if user.hashedPassword == hashPassword(password, withSalt: user.salt) {
            return true
        }
        return false
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
    
    // deletes current auth and user defaults and resets to blank user
    static func signout(_ userId: Int) {
        RecipeDB.shared.deleteAuth(withUserId: userId)
        User.setCurrentUsername(nil)
    }
    
    static func delete(_ userId: Int) {
        RecipeDB.shared.deleteUser(withId: userId)
        signout(userId)
    }
}

enum UserError: Error {
    case badSignin
    case badSignup(taken: String)
}

enum ChangePasswordError: Error {
    case incorrectOldPassword
    case badNewPassword
}
