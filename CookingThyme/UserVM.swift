//
//  UserVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import Foundation
import Combine

import SwiftUI
import Firebase

class UserVM: ObservableObject {
    @Published var user: User
    @Published var authToken: String?
    @Published var signinPresented: Bool = false
    @Published var collection: RecipeCollectionVM?
    @Published var isSignedIn: Bool = false
    
    // errors
    @Published var signinError: Bool = false
    @Published var signupErrors = [InvalidSignup]()
    @Published var changePasswordError: String = ""
    
    private var collectionCancellable: AnyCancellable?
    private var userCancellable: AnyCancellable?
    
    @AppStorage("log_status") var status = false

    init() {
        self.user = User()
        
        setUpCancellables()
    }
    
    // is called to set user that is logged in from user defaults
    init(username: String) {
        self.user = User()
        
        setUpCancellables()
        
        if let user = RecipeDB.shared.getUser(withUsername: username) {
            self.user = user
            setUserCollection()
        }
    }
    
    func setUpCancellables() {
        self.collectionCancellable = self.collection?.objectWillChange
            .sink { _ in
                self.objectWillChange.send()
            }
        
        self.userCancellable = self.$user
            .sink { user in
                if user.username != "" {
                    self.isSignedIn = true
                }
                else {
                    self.isSignedIn = false
                }
            }
    }
    
    // MARK: - Model Access
    
    var username: String {
        user.username
    }
    
    var email: String {
        user.email
    }
    
    // MARK: - Intents
    
    func setUserCollection() {
        if let collection = self.user.getUserCollection() {
            self.collection = collection
        }
    }
    
    func signin(email: String, password: String) {
        // is loading = true
        
        Firebase.Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
            // is loading = false
            if err != nil {
                // FIRAuthErrorCodeInvalidEmail
                // FIRAuthErrorCodeWrongPassword
                // FIRAuthErrorCodeUserDisabled
                // FIRAuthErrorCodeOperationNotAllowed
                self.signinError = true
                return
            }
            let user = Firebase.Auth.auth().currentUser
            
            if !user!.isEmailVerified {
                // please verify email
                
                // log them out
                try! Firebase.Auth.auth().signOut()
                return
            }
            
            // set logged status to true, user is logged in
            self.status = true
            self.signinError = false
            self.setUserCollection()

            
        }
        
        
//        do {
//            if let user = try user.signin(username: username, password: password) {
//                self.signinError = false
//                setAuthToken(withUserId: user.id)
//                setUserCollection()
//            }
//        }
//        catch UserError.badSignin {
//            self.signinError = true
//        }
//        catch {
//
//        }
    }
    
    func setAuthToken(withUserId userId: Int) {
        if let authToken = Auth.signin(withUserId: userId) {
            self.authToken = authToken
        }
    }
    
    func signup(email: String, password: String) {
        // is loading = true
        
        if !isValidUser(email: email, password: password) {
            return
        }

        Firebase.Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            // is loading = false
            
            if err != nil {
                // FIRAuthErrorCodeInvalidEmail
                // FIRAuthErrorCodeEmailAlreadyInUse
                // FIRAuthErrorCodeWeakPassword
                // FIRAuthErrorCodeOperationNotAllowed
                
//                if err?.localizedDescription.contains("username") ?? false {
//                    self.signupErrors.append(InvalidSignup.usernameTaken)
//                }
//                if err?.localizedDescription.contains("email") ?? false {
//                    self.signupErrors.append(InvalidSignup.emailTaken)
//                }
                self.signupErrors.append(InvalidSignup.emailTaken)
                return
            }
            
            // send verification link
//            result?.user.sendEmailVerification(completion: { err in
//                if err != nil {
//                     FIRAuthErrorCodeUserNotFound
//                    return
//                }
//
//                // alert user to verify email
//
//
//                // The link was successfully sent. Inform the user.
//                // Save the email locally so you don't need to ask the user for it again
//                // if they open the link on the same device.
//                UserDefaults.standard.set(email, forKey: "Email")
//
//            })
            self.signin(email: email, password: password)
        }
        
        
//        do {
//            if isValidUser(username: username, password: password, email: email) {
//                if let user = try user.signup(username: username, password: password, email: email) {
//                    setAuthToken(withUserId: user.id)
//                    user.createUserCollection()
//                    setUserCollection()
//                }
//            }
//        }
//        catch UserError.badSignup(let taken) {
//            if taken.contains("username") {
//                self.signupErrors.append(InvalidSignup.usernameTaken)
//            }
//            if taken.contains("email") {
//                self.signupErrors.append(InvalidSignup.emailTaken)
//            }
//        }
//        catch {
//
//        }
    }
    
    func isValidUser(email: String, password: String) -> Bool {
        self.signupErrors = []
//        if RecipeDB.shared.getUser(withUsername: username) != nil {
//            self.signupErrors.append(InvalidSignup.usernameTaken)
//        }
        
        // TODO 3: confirm email
        if email == "" || !email.contains("@") || !email.contains(".") {
            self.signupErrors.append(InvalidSignup.email)
        }
        if !isValidPassword(password) {
            self.signupErrors.append(InvalidSignup.password)
        }
        if self.signupErrors.count > 0 {
            return false
        }
        return true
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return password != ""
    }
    
    func signout() {
        try! Firebase.Auth.auth().signOut()
        
        // FIRAuthErrorCodeKeychainError
        
        status = false
        
        
//        let id = user.id
        self.user = User()
//        DispatchQueue.global(qos: .userInitiated).async {
//            User.signout(id)
//        }
    }
    
    func delete() {
        let user = Firebase.Auth.auth().currentUser

        user?.delete { error in
          if let error = error {
            // FIRAuthErrorCodeRequiresRecentLogin
            // An error happened.
          } else {
            // Account deleted.
            self.user = User()
          }
        }
        
//        let id = user.id
//        self.user = User()
//        DispatchQueue.global(qos: .userInitiated).async {
//            User.delete(id)
//        }
    }
    
    // TODO change throws to be specific/exhaustive
    func changePassword(oldPassword: String, newPassword: String, confirmPassword: String) {
        // is loading = true
        changePasswordError = ""

        if !isValidPassword(newPassword) {
            changePasswordError = "Invalid password."
        }
        if newPassword != confirmPassword {
            changePasswordError = "Passwords do not match."
        }
        
        if changePasswordError != "" {
            return
        }
        
        Firebase.Auth.auth().currentUser?.updatePassword(to: newPassword) { err in
            if err != nil {
                // FIRAuthErrorCodeRequiresRecentLogin
                // FIRAuthErrorCodeWeakPassword
                // FIRAuthErrorCodeOperationNotAllowed
                return
            }
        }
        
        
//        changePasswordError = ""
//        do {
//            if !isValidPassword(newPassword) {
//                changePasswordError = "Invalid password."
//            }
//            if newPassword != confirmPassword {
//                changePasswordError = "Passwords do not match."
//            }
//            if changePasswordError == "" {
//                try user.changePassword(oldPassword: oldPassword, newPassword: newPassword)
//            }
//        }
//        catch ChangePasswordError.incorrectOldPassword {
//            changePasswordError = "Incorrect password."
//        }
//        catch ChangePasswordError.badNewPassword {
//            changePasswordError = "Invalid password."
//        }
//        catch {
//            changePasswordError = "Error creating new password."
//        }
    }
    
    func resetPassword(email: String) {
        Firebase.Auth.auth().sendPasswordReset(withEmail: email) { err in
            // is laoding = false
            
            if err != nil {
                // FIRAuthErrorCodeWeakPassword
                // FIRAuthErrorCodeRequiresRecentLogin
                // FIRAuthErrorCodeOperationNotAllowed
                
//                catch ChangePasswordError.incorrectOldPassword {
//                    changePasswordError = "Incorrect password."
//                }
//                catch ChangePasswordError.badNewPassword {
//                    changePasswordError = "Invalid password."
//                }
                self.changePasswordError = "Error creating new password."
                return
            }
            
            // alert user password link has been sent to email
        }
    }
    
    func reauthenticate() {
//        let user = Firebase.Auth.auth().currentUser
//        var credential: AuthCredential
//
//        // Prompt the user to re-provide their sign-in credentials
//
//        user?.reauthenticate(with: credential) { (result, error) in
//          if let error = error {
                // FIRAuthErrorCodeInvalidCredential
        // FIRAuthErrorCodeInvalidEmail
        // FIRAuthErrorCodeWrongPassword
        // FIRAuthErrorCodeUserMismatch
        // FIRAuthErrorCodeUserDisabled
        // FIRAuthErrorCodeEmailAlreadyInUse
        // FIRAuthErrorCodeOperationNotAllowed
//            // An error happened.
//          } else {
//            // User re-authenticated.
//          }
//        }
    }
}

enum InvalidSignup: Error {
    case username
    case password
    case email
    case usernameTaken
    case emailTaken
    case other
}
