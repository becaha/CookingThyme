//
//  AccountHandler.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import Foundation

class AccountHandler: ObservableObject {
    @Published var user: User
    @Published var authToken: String?
    @Published var loginPresented: Bool = false
    @Published var collection: RecipeCollectionVM?
    
    init() {
        self.user = User()
    }
    
    init(username: String) {
        self.user = User()
        if let user = RecipeDB.shared.getAccount(withUsername: username) {
            setAuthToken(withUserId: user.id)
        }
        setUserCollection()
    }
    
    init(user: User) {
        self.user = user
        setUserCollection()
    }
    
    // MARK: - Model Access
    
    var username: String {
        user.username
    }
    
    var email: String {
        user.email
    }
    
    // MARK: - Intents
    
    func login(username: String, password: String) {
        if let user = user.login(username: username, password: password) {
            setAuthToken(withUserId: user.id)
        }
    }
    
    func setAuthToken(withUserId userId: Int) {
        if let authToken = Auth.login(withUserId: userId) {
            self.authToken = authToken
        }
    }
    
    func signup(username: String, password: String, email: String) {
        if let user = user.signup(username: username, password: password, email: email) {
            setAuthToken(withUserId: user.id)
        }
    }
    
    func setUserCollection() {
        if let collection = RecipeDB.shared.getCollection(withUsername: username) {
            self.collection = RecipeCollectionVM(collection: collection)
        }
    }
}
