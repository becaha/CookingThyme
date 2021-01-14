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
    @Published var sheetPresented: Bool = false // TODO move
    @Published var signinPresented: Bool = false
    @Published var collection: RecipeCollectionVM?
    @Published var isSignedIn: Bool = false
    
    private var collectionCancellable: AnyCancellable?
    private var signinPresentedCancellable: AnyCancellable?
    private var userCancellable: AnyCancellable?

        
    init() {
        self.user = User()
        
        self.collectionCancellable = self.collection?.objectWillChange
            .sink { _ in
                self.objectWillChange.send()
            }
        
        self.signinPresentedCancellable = self.$signinPresented
            .sink { signinPresented in
                self.sheetPresented = signinPresented
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
    
    // is called to set user that is logged in from user defaults
    init(username: String) {
        self.user = User()
        
        self.collectionCancellable = self.collection?.objectWillChange
            .sink { _ in
                self.objectWillChange.send()
            }
        
        self.signinPresentedCancellable = self.$signinPresented
            .sink { signinPresented in
                self.sheetPresented = signinPresented
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
        
        if let user = RecipeDB.shared.getUser(withUsername: username) {
            self.user = user
            if let collection = self.user.getUserCollection() {
                self.collection = collection
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
    
    func signin(username: String, password: String) {
        if let user = user.signin(username: username, password: password) {
            setAuthToken(withUserId: user.id)
        }
    }
    
    func setAuthToken(withUserId userId: Int) {
        if let authToken = Auth.signin(withUserId: userId) {
            self.authToken = authToken
        }
    }
    
    func signup(username: String, password: String, email: String) {
        if let user = user.signup(username: username, password: password, email: email) {
            setAuthToken(withUserId: user.id)
            user.createUserCollection()
        }
    }
    
    func signout() {
        user.signout()
    }
}
