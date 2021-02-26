//
//  User.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import Foundation
import Firebase

struct User {
    static let userKey = "CookingThymeCurrentUser"

    var email: String
    var forceSignout = false {
        didSet {
            
        }
    }
    
    init() {
        self.email = ""
    }
    
    init(email: String) {
        self.email = email
    }
    
    mutating func setSignedOut() {
        self = User()
        User.setCurrentUsername(nil)
    }
    
    static func createUserCollection(withUsername username: String, onCompletion: @escaping (Bool) -> Void) {
        RecipeDB.shared.createCollection(withUsername: username) { collection in
            if let collection = collection {
                RecipeDB.shared.createCategory(withName: "All", forCollectionId: collection.id) {
                    category in
                    onCompletion(category != nil)
                }
            }
        }
    }
    
    // saves current username to user defaults to keep user logged in
    static func setCurrentUsername(_ username: String?) {
        UserDefaults.standard.set(username, forKey: User.userKey)
    }
}
