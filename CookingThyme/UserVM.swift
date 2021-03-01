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
    @Published var isReauthenticating: Bool = false
    @Published var collection: RecipeCollectionVM?
    @Published var isSignedIn: Bool = false
    
    @Published var isLoading: Bool?
    
    // errors
    @Published var userErrors = [String]()
    
    @Published var forcedSignout = false
    
    private var collectionCancellable: AnyCancellable?
    private var userCancellable: AnyCancellable?
    
    @AppStorage("log_status") var status = false

    init() {
        self.user = User()
        
        setUpCancellables()
    }
    
    // is called to set user that is logged in from user defaults
    init(email: String) {
        self.user = User(email: email)
        
        setUpCancellables()
        
        setUserCollection(onInit: true)
    }
    
    func setUpCancellables() {
        self.collectionCancellable = self.collection?.objectWillChange
            .sink { _ in
                self.objectWillChange.send()
            }
        
        self.userCancellable = self.$user
            .sink { user in
                if user.email != "" {
                    self.isSignedIn = true
                }
                else {
                    self.isSignedIn = false
                }
            }
    }
    
    // MARK: - Model Access
    
    var email: String {
        user.email
    }
    
    // MARK: - Intents
    
    func setUserCollection(onInit: Bool = false) {
        RecipeDB.shared.getCollection(withUsername: email) { collection, isUnauthorized in
            if isUnauthorized {
                // on init, just be signed out
                if onInit {
                    self.user.setSignedOut()
                }
                else {
                    self.forcedSignout = true
                }
            }
            if let collection = collection {
                self.collection = RecipeCollectionVM(collection: collection)
            }
        }
    }
    
    func forceSignout() {
        self.user.setSignedOut()
    }
    
    private func setSignedIn() {
        self.status = true
        self.setUserCollection()
    }
    
    func clearErrors() {
        self.userErrors = [String]()
        self.isReauthenticating = false
    }
    
    private func firebaseSignin(email: String, password: String) {
        Firebase.Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
            if let error = err as NSError? {
                self.setErrorMessage(fromInternalError: error)
                // resets current user due to failed sign in attempt
                User.setCurrentUsername(nil)
                self.isLoading = false
                return
            }
            
//            let user = Firebase.Auth.auth().currentUser

//            if !user!.isEmailVerified {
//                // please verify email
//
//                // log them out
//                try! Firebase.Auth.auth().signOut()
//                self.isLoading = false
//                return
//            }

            // set logged status to true, user is logged in
            self.user = User(email: email)
            User.setCurrentUsername(email)
            
            self.setSignedIn()
            
            self.isLoading = false
        }
    }
    
    func signin(email: String, password: String) {
        if let loading = self.isLoading, loading == true {
            return
        }
        self.isLoading = true
        clearErrors()
        
        self.firebaseSignin(email: email, password: password)
    }
    
    private func firebaseSignup(email: String, password: String) {
        Firebase.Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            if let error = err as NSError? {
                self.setErrorMessage(fromInternalError: error)
                self.isLoading = false
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
            User.createUserCollection(withUsername: email) { success in
                if !success {
                    print("error creating all category")
                }
                else {
                    self.firebaseSignin(email: email, password: password)
                }
            }
        }
    }
    
    func signup(email: String, password: String) {
        if let loading = self.isLoading, loading == true {
            return
        }
        clearErrors()
        self.isLoading = true

        firebaseSignup(email: email, password: password)
    }
    
    func signout() {
        if let loading = self.isLoading, loading == true {
            return
        }
        self.isLoading = true
        clearErrors()
        
        try! Firebase.Auth.auth().signOut()
        user.setSignedOut()
        self.collection = nil
        
//        if userErrors.count == 0 {
            status = false
//        }

        self.isLoading = false
    }
    
    private func firebaseChangePassword(oldPassword: String, newPassword: String) {
        firebaseReauthenticate(email: self.user.email, password: oldPassword) {
            // reauthentication is successful, update paassword
            Firebase.Auth.auth().currentUser?.updatePassword(to: newPassword) { err in
                if let error = err as NSError? {
                    self.setErrorMessage(fromInternalError: error)
                    self.isLoading = false
                    return
                }
                self.isLoading = false
            }
        }
    }
    
    func changePassword(oldPassword: String, newPassword: String, confirmPassword: String) {
        if let loading = self.isLoading, loading == true {
            return
        }
        self.isLoading = true
        clearErrors()
        
        if newPassword != confirmPassword {
            userErrors.append("Passwords do not match.")
            self.isLoading = false
            return
        }
                
        firebaseChangePassword(oldPassword: oldPassword, newPassword: newPassword)
    }
    
    private func firebaseDelete(password: String) {
        firebaseReauthenticate(email: self.user.email, password: password) {
            // reauthentication is successful, update paassword
            let user = Firebase.Auth.auth().currentUser

            user?.delete { err in
                if let error = err as NSError? {
                    self.setErrorMessage(fromInternalError: error)
                    self.isLoading = false
                    return
                }
                else {
                    // Account deleted, sign out.
                    self.user.setSignedOut()
//                    self.collection?.delete()
                    self.status = false
                    
                    self.isLoading = false
                }
            }
        }
    }
    
    func delete(password: String) {
        if let loading = self.isLoading, loading == true {
            return
        }
        
        clearErrors()
        self.isLoading = true
        
        self.collection?.delete() { success in
            self.firebaseDelete(password: password)
        }
    }
    
    func resetPassword(email: String) {
        clearErrors()

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
//                self.changePasswordError = "Error creating new password."
                return
            }
            
            // alert user password link has been sent to email
        }
    }
    
    private func firebaseReauthenticate(email: String, password: String, onSuccess: @escaping () -> Void) {
        let user = Firebase.Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        user?.reauthenticate(with: credential) { (result, err) in
          if let error = err as NSError? {
            self.setErrorMessage(fromInternalError: error)
            self.isLoading = false
            // An error happened.
          } else {
            // User re-authenticated.
            onSuccess()
          }
        }
    }
    
    func reauthenticate(email: String, password: String) {
        if let loading = self.isLoading, loading == true {
            return
        }
        clearErrors()
        self.isLoading = true
        
        self.firebaseReauthenticate(email: email, password: password) {
            self.isLoading = false
        }
    }
    
    static func signout() {
        
    }
    
    func setErrorMessage(fromInternalError error: NSError) {
        // reset errors
        clearErrors()
        
        switch AuthErrorCode(rawValue: error.code) {
        // all
        case .operationNotAllowed:
            // FIRAuthErrorCodeOperationNotAllowed: The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.
            self.userErrors.append("Error")
            
        // signin, change password
        case .userDisabled:
          // FIRAuthErrorCodeUserDisabled: The user account has been disabled by an administrator.
            print("Error: \(error.localizedDescription)")
            self.userErrors.append("This account has been disabled.")
            
            
        // change password
        case .invalidCredential:
            // FIRAuthErrorCodeInvalidCredential
            print("Error: \(error.localizedDescription)")
            self.userErrors.append("Wrong email or password")
            
        // change password
        case .userMismatch:
            // FIRAuthErrorCodeUserMismatch
            print("Error: \(error.localizedDescription)")
            self.userErrors.append("Wrong email or password")

        // signin
        case .wrongPassword:
          // FIRAuthErrorCodeWrongPassword: The password is invalid or the user does not have a password.
            print("Error: \(error.localizedDescription)")
            self.userErrors.append("Incorrect Password.")
        
        // signin
        case .userNotFound:
            // FIRAuthErrorCodeUserNotFound: There is no user record corresponding to this identifier. The user may have been deleted.
              print("Error: \(error.localizedDescription)")
              self.userErrors.append("User not found.")
          
        // signup, change password (why?)
        case .emailAlreadyInUse:
            // FIRAuthErrorCodeEmailAlreadyInUse: The email address is already in use by another account.
            print("Error: \(error.localizedDescription)")
            self.userErrors.append("The email address is already in use by another account.")
           
        // signup, signin
        case .invalidEmail:
            // FIRAuthErrorCodeInvalidEmail: The email address is badly formatted.
            print("Error: \(error.localizedDescription)")
            self.userErrors.append("Invalid email address.")

        // signup, change password
        case .weakPassword:
            // FIRAuthErrorCodeWeakPassword: The password must be 6 characters long or more.
            print("Error: \(error.localizedDescription)")
            self.userErrors.append("Password must be 6 characters long or more.")
        
        // delete user, change password
        case .requiresRecentLogin:
              // FIRAuthErrorCodeRequiresRecentLogin: Updating a user’s password is a security sensitive operation that requires a recent login from the user. This error indicates the user has not signed in recently enough. To resolve, reauthenticate the user by invoking reauthenticateWithCredential:completion: on FIRUser.
            self.isReauthenticating = true
            
        case .userTokenExpired:
            // user credential is no longer valid, must sign in again
            self.isReauthenticating = true
            
        case .keychainError:
            // FIRAuthErrorCodeKeychainError
            self.isReauthenticating = true

        default:
            let errorType = AuthErrorCode(rawValue: error.code)
            let errorMessage = error.localizedDescription
            print("\(String(describing: errorType)): \(errorMessage)")
            self.userErrors.append("Error")
        }
    }
}

enum InvalidSignup: String {
    case username
    case password = "The password must be 6 characters long or more."
    case email
    case usernameTaken
    case emailTaken = "The email address is already in use by another account."
    case other
}
