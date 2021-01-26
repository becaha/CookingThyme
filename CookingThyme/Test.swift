//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct Test: View {
    
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
                        .formItem()

                    SecureField("Password", text: $password) {
//                        signin()
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
//                    signin()
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
//                        reset()
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
//                        signup()
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
//                    signup()
                }) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                }
                .formItem(backgroundColor: mainColor())

                Button(action: {
                    withAnimation {
//                        isSigningIn = true
//                        reset()
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
        
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
