//
//  SigninView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import SwiftUI
import Combine

struct SigninView: View {
    @EnvironmentObject var sheetNavigator: SheetNavigator
    @EnvironmentObject var user: UserVM
        
    @State var email: String = ""
    @State var password: String = ""
    @State var isSignIn: Bool = true
    
    @State var keyboardPresented = false
        
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            logo()
                .padding(.bottom, 25)
            
            if isSignIn {
                Signin() { email, password in
                    signin(email: email, password: password)
                }
                
                Button(action: {
                    withAnimation {
                        isSignIn = false
                        reset()
                    }
                }) {
                    HStack {
                        Spacer()
                        
                        Text("Sign Up")
                            .customFont(style: .subheadline)

                        Spacer()
                    }
                }
                .onTapGesture(count: 1, perform: {})
            }
            else {
                Group {
                    TextField("Email", text: $email)
                        .customFont(style: .subheadline)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                        .formItem()
                        .onTapGesture(count: 1, perform: {})

                    SecureField("Password", text: $password) {
                        withAnimation {
                            signup()
                        }
                    }
                    .customFont(style: .subheadline)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .formItem()
                    .onTapGesture(count: 1, perform: {})
                }

                UserErrorsView(userErrors: user.userErrors)

                Button(action: {
                    withAnimation {
                        signup()
                    }
                }) {
                    HStack {
                        Spacer()
                        
                        Text("Sign Up")
                            .customFont(style: .subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                }
                .formItem(centered: true, backgroundColor: mainColor())
                .onTapGesture(count: 1, perform: {})

                Button(action: {
                    withAnimation {
                        isSignIn = true
                        reset()
                    }
                }) {
                    HStack {
                        Spacer()
                        
                        Text("Sign In")
                            .customFont(style: .subheadline, weight: .bold)
                        
                        Spacer()
                    }
                }
                .onTapGesture(count: 1, perform: {})
            }
            
            Spacer()
            
        }
        .padding()
        .background(formBackgroundColor().edgesIgnoringSafeArea(.all))
        .loadable(isLoading: $user.isLoading)
        .onAppear {
            user.clearErrors()
            user.isLoading = nil
        }
        .onChange(of: user.isLoading, perform: { isLoading in
            if let isLoading = isLoading, !isLoading {
                user.isLoading = nil
                onLoadingComplete()
            }
        })
        .onReceive(Publishers.keyboardHeight) { height in
            keyboardPresented = height == 0 ? false : true
        }
        .gesture(keyboardPresented ?
                    TapGesture(count: 1).onEnded {
            withAnimation {
                unfocusEditable()
            }
        } : nil)
        .accentColor(mainColor())
        .navigationBarColor(UIColor(navBarColor()), text: "", style: .headline, textColor: UIColor(formItemFont()))    }
    
    func reset() {
        password = ""
        email = ""
        user.userErrors = [String]()
    }
    
    func signin(email: String, password: String) {
        user.signin(email: email, password: password)
    }
    
    func signup() {
        user.signup(email: email, password: password)
    }
    
    func onLoadingComplete() {
        withAnimation {
            if user.userErrors.count == 0 {
                sheetNavigator.showSheet = false
            }
            else if user.isReauthenticating {
                sheetNavigator.sheetDestination = .signin
            }
        }
    }
}

//struct SigninView_Previews: PreviewProvider {
//    static var previews: some View {
//        SigninView()
//    }
//}
