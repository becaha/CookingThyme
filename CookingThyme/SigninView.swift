//
//  SigninView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import SwiftUI

struct SigninView: View {
    @ObservedObject var user = UserVM()
    
    @Binding var isPresented: Bool
    
    @State var email: String = ""
    @State var username: String = ""
    @State var password: String = ""
    @State var isSigningIn: Bool = true
    
    var body: some View {
        VStack {
            Spacer()
            
            if isSigningIn {
                Group {
                    TextField("Username", text: $username)

                    SecureField("Password", text: $password)
                        
                }
                .formed()
                
                Button(action: {
                    signin()
                }) {
                    Text("Sign In")
                        .foregroundColor(.white)
                }
                .formed(backgroundColor: mainColor())
                .padding(.top)
                
                Button(action: {
                    withAnimation {
                        isSigningIn = false
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
                        isSigningIn = true
                    }
                }) {
                    Text("Sign In")
                }
            }
            
            Spacer()
            
        }
        .padding()
        .accentColor(mainColor())
        .background(formBackgroundColor())
        .ignoresSafeArea()
    }
    
    func signin() {
        user.signin(username: username, password: password)
        isPresented = false
    }
    
    func signup() {
        user.signup(username: username, password: password, email: email)
        isPresented = false
    }
}

//struct SigninView_Previews: PreviewProvider {
//    static var previews: some View {
//        SigninView()
//    }
//}
