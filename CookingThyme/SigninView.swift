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
        VStack(spacing: 0) {
            Spacer()
            
            logo()
                .padding(.bottom, 25)
            
            if isSigningIn {
                Group {
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .formItem()

                    SecureField("Password", text: $password) {
                        signin()
                    }
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .formItem()
                }
                
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
                    HStack {
                        Spacer()
                        
                        Text("Sign In")
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                }
                .formItem(backgroundColor: mainColor())
                
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
                        .formItem()

                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                        .formItem()

                    SecureField("Password", text: $password) {
                        signup()
                    }
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .formItem()
                }

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
                    HStack {
                        Spacer()
                        
                        Text("Sign Up")
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                }
                .formItem(backgroundColor: mainColor())

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
