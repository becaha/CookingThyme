//
//  UserVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import Foundation
import Combine

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
    
    func signin(username: String, password: String) {
        do {
            if let user = try user.signin(username: username, password: password) {
                self.signinError = false
                setAuthToken(withUserId: user.id)
                setUserCollection()
            }
        }
        catch UserError.badSignin {
            self.signinError = true
        }
        catch {
            
        }
    }
    
    func setAuthToken(withUserId userId: Int) {
        if let authToken = Auth.signin(withUserId: userId) {
            self.authToken = authToken
        }
    }
    
    func signup(username: String, password: String, email: String) {
        do {
            if isValidUser(username: username, password: password, email: email) {
                if let user = try user.signup(username: username, password: password, email: email) {
                    setAuthToken(withUserId: user.id)
                    user.createUserCollection()
                    setUserCollection()
                }
            }
        }
        catch UserError.badSignup(let taken) {
            if taken.contains("username") {
                self.signupErrors.append(InvalidSignup.usernameTaken)
            }
            if taken.contains("email") {
                self.signupErrors.append(InvalidSignup.emailTaken)
            }
        }
        catch {
            
        }
    }
    
    func isValidUser(username: String, password: String, email: String) -> Bool {
        self.signupErrors = []
        if username == "" {
            self.signupErrors.append(InvalidSignup.username)
        }
        if RecipeDB.shared.getUser(withUsername: username) != nil {
            self.signupErrors.append(InvalidSignup.usernameTaken)
        }
        if !isValidPassword(password) {
            self.signupErrors.append(InvalidSignup.password)
        }
        // TODO 3: confirm email
        if email == "" || !email.contains("@") || !email.contains(".") {
            self.signupErrors.append(InvalidSignup.email)
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
        let id = user.id
        self.user = User()
        DispatchQueue.global(qos: .userInitiated).async {
            User.signout(id)
        }
    }
    
    func delete() {
        let id = user.id
        self.user = User()
        DispatchQueue.global(qos: .userInitiated).async {
            User.delete(id)
        }
    }
    
    // TODO change throws to be specific/exhaustive
    func changePassword(oldPassword: String, newPassword: String, confirmPassword: String) {
        changePasswordError = ""
        do {
            if !isValidPassword(newPassword) {
                changePasswordError = "Invalid password."
            }
            if newPassword != confirmPassword {
                changePasswordError = "Passwords do not match."
            }
            if changePasswordError == "" {
                try user.changePassword(oldPassword: oldPassword, newPassword: newPassword)
            }
        }
        catch ChangePasswordError.incorrectOldPassword {
            changePasswordError = "Incorrect password."
        }
        catch ChangePasswordError.badNewPassword {
            changePasswordError = "Invalid password."
        }
        catch {
            changePasswordError = "Error creating new password."
        }
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
