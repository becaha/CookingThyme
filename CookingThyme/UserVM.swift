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

//https://medium.com/firebase-developers/ios-firebase-authentication-sdk-email-and-password-login-6a3bb27e0536

class UserVM: ObservableObject {
    @Published var user: User
    @Published var authToken: String?
    @Published var signinPresented: Bool = false
    @Published var collection: RecipeCollectionVM?
    @Published var isSignedIn: Bool = false
    
    @Published var isLoading: Bool? {
        didSet {
            let loading = isLoading
            print("")
        }
    }
    
    // errors
    @Published var userErrors = [String]()
    
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
        
        setUserCollection()
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
    
    func setUserCollection() {
        if let collection = self.user.getUserCollection() {
            self.collection = collection
        }
    }
    
    private func setSignedIn() {
        self.status = true
        self.setUserCollection()
    }
    
    func clearErrors() {
        self.userErrors = [String]()
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
            User.createUserCollection(withUsername: email)
            self.firebaseSignin(email: email, password: password)
        }
    }
    
    func signup(email: String, password: String) {
        clearErrors()
        self.isLoading = true

        firebaseSignup(email: email, password: password)
    }
    
    func signout() {
        clearErrors()
        self.isLoading = true
        
        try! Firebase.Auth.auth().signOut()
        user.setSignedOut()
        
//        if userErrors.count == 0 {
            status = false
//        }

        self.isLoading = false
    }
    
    private func firebaseChangePassword(newPassword: String) {
        Firebase.Auth.auth().currentUser?.updatePassword(to: newPassword) { err in
            if let error = err as NSError? {
                self.setErrorMessage(fromInternalError: error)
                return
            }
        }
    }
    
    // TODO change throws to be specific/exhaustive
    func changePassword(oldPassword: String, newPassword: String, confirmPassword: String) {
        clearErrors()
        self.isLoading = true
        
        if newPassword != confirmPassword {
            userErrors.append("Passwords do not match.")
            return
        }
        
        // TODO: confirm oldPassword is correct
        
        firebaseChangePassword(newPassword: newPassword)
        
        self.isLoading = false
    }
    
    private func firebaseDelete() {
        let user = Firebase.Auth.auth().currentUser

        user?.delete { err in
            if let error = err as NSError? {
                self.setErrorMessage(fromInternalError: error)
                return
            }
            else {
                // Account deleted, sign out.
                self.user.setSignedOut()
            }
        }
    }
    
    func delete() {
        clearErrors()
        self.isLoading = true
        
        firebaseDelete()
        
        collection?.delete()
        status = false
        
        self.isLoading = false
    }
    
    func isValidUser(email: String, password: String) -> Bool {
//        self.signupErrors = []
////        if RecipeDB.shared.getUser(withUsername: username) != nil {
////            self.signupErrors.append(InvalidSignup.usernameTaken)
////        }
//
//        // TODO 3: confirm email
//        if email == "" || !email.contains("@") || !email.contains(".") {
//            self.signupErrors.append(InvalidSignup.email)
//        }
//        if !isValidPassword(password) {
//            self.signupErrors.append(InvalidSignup.password)
//        }
//        if self.signupErrors.count > 0 {
//            return false
//        }
//        return true
        return true
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return password != ""
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
    
    func reauthenticate() {
        clearErrors()

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
    
    func setErrorMessage(fromInternalError error: NSError) {
        // reset errors
        userErrors = [String]()
        
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

        // signin
        case .wrongPassword:
          // FIRAuthErrorCodeWrongPassword: The password is invalid or the user does not have a password.
            print("Error: \(error.localizedDescription)")
            self.userErrors.append("Incorrect Password.")
            
        case .userNotFound:
            // FIRAuthErrorCodeUserNotFound: There is no user record corresponding to this identifier. The user may have been deleted.
              print("Error: \(error.localizedDescription)")
              self.userErrors.append("User not found.")
          
        // signup
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
            self.userErrors.append("Must confirm sign in to delete the account.")
            
        case .userTokenExpired:
            // user credential is no longer valid, must sign in again
            self.userErrors.append("Must sign in again.")
            
        case .keychainError:
            // FIRAuthErrorCodeKeychainError
            self.userErrors.append("Must sign in again.")

        default:
            let errorType = AuthErrorCode(rawValue: error.code)
            let errorMessage = error.localizedDescription
            print("\(errorType): \(errorMessage)")
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
