//
//  SigninView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import SwiftUI
import Firebase

struct SigninView: View {
    @EnvironmentObject var sheetNavigator: SheetNavigator
    @EnvironmentObject var user: UserVM
        
    @State var email: String = ""
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
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.emailAddress)
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
        .background(formBackgroundColor().edgesIgnoringSafeArea(.all))
    }
    
    func reset() {
        password = ""
        email = ""
        signupErrorMessages = [String]()
        signinErrorMessage = ""
    }
    
    func signin() {
        user.signin(email: email, password: password)
        if user.signinError {
            isSigningIn = false
            signinErrorMessage = "Username or password incorrect."
        }
        else {
            sheetNavigator.showSheet = false
        }
    }
    
    func signup() {
        user.signup(email: email, password: password)
        withAnimation {
            signupErrorMessages = [String]()
            
            if user.signupErrors.count == 0 {
                sheetNavigator.showSheet = false
            }
            else {
                isSigningIn = false
            }
            if user.signupErrors.contains(InvalidSignup.emailTaken) {
                signupErrorMessages.append("Email already taken.")
            }
            
            if user.signupErrors.contains(InvalidSignup.email) {
                signupErrorMessages.append("Invalid email.")
            }
            if user.signupErrors.contains(InvalidSignup.password) {
                signupErrorMessages.append("Invalid password.")
            }
        }
    }
}

//struct SigninView_Previews: PreviewProvider {
//    static var previews: some View {
//        SigninView()
//    }
//}
