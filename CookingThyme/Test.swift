//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/18/20.
//

import SwiftUI

struct Test: View {
    @ObservedObject var account = UserVM()
    
    @State var email: String = ""
    @State var username: String = ""
    @State var password: String = ""
    @State var isLoggingIn: Bool = true
    
    var body: some View {
        VStack {
            if isLoggingIn {
                Group {
                    TextField("Username", text: $username)

                    TextField("Password", text: $password)
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
                    
                    TextField("Password", text: $email)
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
            
        }
        .padding()
        .foregroundColor(mainColor())
        .background(formBackgroundColor())
    }
    
    func login() {
        account.login(username: username, password: password)
    }
    
    func signup() {
        account.signup(username: username, password: password, email: email)
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
