//
//  User.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import Foundation
import GRDB
import CryptoKit

import Firebase

struct User {
    static let userKey = "CookingThymeCurrentUser"

    var email: String
    
    init() {
        self.email = ""
    }
    
    init(email: String) {
        self.email = email
    }
    
    // gets user of user if the password is correct
//    mutating func signin(email: String, password: String) {
//        Firebase.Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
//            if let error = err as NSError? {
//                self.setErrorMessage(fromInternalError: error)
//                // resets current user due to failed sign in attempt
//                User.setCurrentUsername(nil)
//                return
//            }
//
////            let user = Firebase.Auth.auth().currentUser
//
////            if !user!.isEmailVerified {
////                // please verify email
////
////                // log them out
////                try! Firebase.Auth.auth().signOut()
////                self.isLoading = false
////                return
////            }
//
//            // set logged status to true, user is logged in
//            self = User(email: email)
//            User.setCurrentUsername(email)
//        }
//    }
//
//    mutating func signup(email: String, password: String) {
//        Firebase.Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
//            if err != nil {
//                if let error = err as NSError? {
//                    self.setErrorMessage(fromInternalError: error)
//                }
//                return
//            }
//
//            // send verification link
////            result?.user.sendEmailVerification(completion: { err in
////                if err != nil {
////                     FIRAuthErrorCodeUserNotFound
////                    return
////                }
////
////                // alert user to verify email
////
////
////                // The link was successfully sent. Inform the user.
////                // Save the email locally so you don't need to ask the user for it again
////                // if they open the link on the same device.
////                UserDefaults.standard.set(email, forKey: "Email")
////
////            })
//            self.createUserCollection()
//            self.signin(email: email, password: password)
//        }
//    }
//
//    mutating func signout() {
//        try! Firebase.Auth.auth().signOut()
//        setSignedOut()
//        // FIRAuthErrorCodeKeychainError
//    }
    
    mutating func setSignedOut() {
        self = User()
        User.setCurrentUsername(nil)
    }
    
//    mutating func changePassword(oldPassword: String, newPassword: String, confirmPassword: String) {
//
//        if newPassword != confirmPassword {
//            userErrors.append("Passwords do not match.")
//            return
//        }
//
//        // TODO: confirm oldPassword is correct
//
//        Firebase.Auth.auth().currentUser?.updatePassword(to: newPassword) { err in
//            if let error = err as NSError? {
//                self.setErrorMessage(fromInternalError: error)
//                return
//            }
//        }
//    }
//
//    mutating func delete() {
//        let user = Firebase.Auth.auth().currentUser
//
//        user?.delete { err in
//            if let error = err as NSError? {
//                self.setErrorMessage(fromInternalError: error)
//                return
//            }
//            else {
//                // Account deleted, sign out.
//                self.setSignedOut()
//            }
//        }
//    }
    
//    func getUserCollection() -> RecipeCollectionVM? {
//        RecipeDB.shared.getCollection(withUsername: email) { collection in
//            if let collection = collection {
//                return RecipeCollectionVM(collection: collection)
//            }
//        }
//        return nil
//    }
    
    static func createUserCollection(withUsername username: String, onCompletion: @escaping (Bool) -> Void) {
        RecipeDB.shared.createCollection(withUsername: username) { collection in
            if let collection = collection {
                RecipeDB.shared.createCategory(withName: "All", forCollectionId: collection.id) {
                    success in
                    onCompletion(success)
                }
            }
        }
    }
    
    // saves current username to user defaults to keep user logged in
    static func setCurrentUsername(_ username: String?) {
        UserDefaults.standard.set(username, forKey: User.userKey)
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
