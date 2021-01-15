//
//  SigninView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import SwiftUI

// TODO: take care of switching before exiting sheet
// TODO: no capitalization, keyboards
// TODO: error when signed in user, restart sim, sign out, try to sign in
// TODO: get it wrong once, is wrong forever
struct SigninView: View {
    @EnvironmentObject var user: UserVM
    
    @Binding var isPresented: Bool
    
    @State var email: String = ""
    @State var username: String = ""
    @State var password: String = ""
    @State var isSigningIn: Bool = true
    
    @State var signinErrorMessage = ""
    @State var signupErrorMessage = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            if isSigningIn {
                Group {
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    SecureField("Password", text: $password) {
                        signin()
                    }
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                        
                }
                .formed()
                
                HStack {
                    Text("\(signinErrorMessage)")
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(0)
                    
                    Spacer()
                }
                
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
                        reset()
                    }
                }) {
                    Text("Sign Up")
                }

            }
            else {
                Group {
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password) {
                        signup()
                    }
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                }
                .formed()
                
                HStack {
                    Text("\(signupErrorMessage)")
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(0)
                    
                    Spacer()
                }
                    
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
                        reset()
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
    
    func reset() {
        username = ""
        password = ""
        email = ""
        signupErrorMessage = ""
        signinErrorMessage = ""
    }
    
    func signin() {
        user.signin(username: username, password: password)
        if user.signinError {
            signinErrorMessage = "Username or password incorrect."
        }
        else {
            reset()
            isPresented = false
        }
    }
    
    func signup() {
        user.signup(username: username, password: password, email: email)
        signupErrorMessage = ""
        if user.signupErrors.count == 0 {
            isPresented = false
        }
        
        if user.signupErrors.contains(InvalidSignup.usernameTaken) {
            signupErrorMessage += "Username already taken. "
        }
        if user.signupErrors.contains(InvalidSignup.emailTaken) {
            signupErrorMessage += "Email already taken. "
        }
        
        if user.signupErrors.contains(InvalidSignup.username) {
            signupErrorMessage += "Invalid username. "
        }
        if user.signupErrors.contains(InvalidSignup.password) {
            signupErrorMessage += "Invalid password. "
        }
        if user.signupErrors.contains(InvalidSignup.email) {
            signupErrorMessage += "Invalid email."
        }
    }
}

//struct SigninView_Previews: PreviewProvider {
//    static var previews: some View {
//        SigninView()
//    }
//}
