//
//  LoginView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var account = AccountHandler()
    
    @State var email: String = ""
    @State var username: String = ""
    @State var password: String = ""
    @State var isLoggingIn: Bool = true
    
    var body: some View {
        VStack {
            Spacer()
            
            if isLoggingIn {
                Group {
                    TextField("Username", text: $username)

                    SecureField("Password", text: $password)
                        
                }
                .formed()
                
                Button(action: {
                    login()
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                }
                .formed(backgroundColor: mainColor())
                .padding(.top)
                
                Button(action: {
                    withAnimation {
                        isLoggingIn = false
                    }
                }) {
                    Text("Sign Up")
                }

            }
            else {
                Group {
                    TextField("Username", text: $username)
                    
                    TextField("Email", text: $email)
                    
                    SecureField("Password", text: $password)
                }
                .formed()
                    
                Button(action: {
                    signup()
                }) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                }
                .formed(backgroundColor: mainColor())
                
                Button(action: {
                    withAnimation {
                        isLoggingIn = true
                    }
                }) {
                    Text("Login")
                }
            }
            
            Spacer()
            
        }
        .padding()
        .accentColor(mainColor())
        .background(formBackgroundColor())
        .ignoresSafeArea()
    }
    
    func login() {
        account.login(username: username, password: password)
    }
    
    func signup() {
        account.signup(username: username, password: password, email: email)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
