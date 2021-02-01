//
//  SigninView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import SwiftUI

struct SigninView: View {
    @EnvironmentObject var sheetNavigator: SheetNavigator
    @EnvironmentObject var user: UserVM
        
    @State var email: String = ""
    @State var username: String = ""
    @State var password: String = ""
    @State var isSignIn: Bool = true
    
    @State var signinErrorMessage = ""
    @State var signupErrorMessages = [String]()
    
    @State var isSigningIn = false

    var body: some View {
        ZStack {
            if isSigningIn {
                UIControls.Loading()
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                logo()
                    .padding(.bottom, 25)
                
                if isSignIn {
                    Group {
                        TextField("Username", text: $username)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .formItem()

                        SecureField("Password", text: $password) {
                            withAnimation {
                                isSigningIn = true
                                signin()
                            }
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
                    .padding([.leading, .bottom])
                    
                    Button(action: {
                        withAnimation {
                            isSigningIn = true
                            signin()
                        }
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
                            isSignIn = false
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
                            withAnimation {
                                isSigningIn = true
                                signup()
                            }
                        }
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .formItem()
                    }

                    VStack {
                        ForEach(signupErrorMessages, id: \.self) { message in
                            HStack {
                                Text("\(message)")
                                    .font(.footnote)
                                    .foregroundColor(.red)
                                    .padding(0)

                                Spacer()
                            }
                        }
                    }
                    .padding([.leading, .bottom])

                    Button(action: {
                        withAnimation {
                            isSigningIn = true
                            signup()
                        }
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
                            isSignIn = true
                            reset()
                        }
                    }) {
                        Text("Sign In")
                    }
                }
                
                Spacer()
                
            }
            .padding()
            .opacity(isSigningIn ? 0.5 : 1)
        }
        .accentColor(mainColor())
        .background(formBackgroundColor())
        .ignoresSafeArea()
    }
    
    func reset() {
        username = ""
        password = ""
        email = ""
        signupErrorMessages = [String]()
        signinErrorMessage = ""
    }
    
    func signin() {
        user.signin(username: username, password: password)
        if user.signinError {
            isSigningIn = false
            signinErrorMessage = "Username or password incorrect."
        }
        else {
            sheetNavigator.showSheet = false
        }
    }
    
    func signup() {
        user.signup(username: username, password: password, email: email)
        withAnimation {
            signupErrorMessages = [String]()
            
            if user.signupErrors.count == 0 {
                sheetNavigator.showSheet = false
            }
            else {
                isSigningIn = false
            }
            if user.signupErrors.contains(InvalidSignup.usernameTaken) {
                signupErrorMessages.append("Username already taken.")
            }
            if user.signupErrors.contains(InvalidSignup.emailTaken) {
                signupErrorMessages.append("Email already taken.")
            }
            
            if user.signupErrors.contains(InvalidSignup.username) {
                signupErrorMessages.append("Invalid username.")
            }
            if user.signupErrors.contains(InvalidSignup.password) {
                signupErrorMessages.append("Invalid password.")
            }
            if user.signupErrors.contains(InvalidSignup.email) {
                signupErrorMessages.append("Invalid email.")
            }
        }
    }
}

//struct SigninView_Previews: PreviewProvider {
//    static var previews: some View {
//        SigninView()
//    }
//}
