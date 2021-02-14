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
        
    var body: some View {
        ZStack {
            if user.isLoading != nil, user.isLoading! {
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
                                signin()
                            }
                        }
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .formItem()
                    }
                    
                    UserErrorsView(userErrors: user.userErrors)

                    Button(action: {
                        withAnimation {
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
                                signup()
                            }
                        }
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .formItem()
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
            .opacity(user.isLoading != nil && user.isLoading! ? 0.5 : 1)
        }
        .onAppear {
            user.clearErrors()
            user.isLoading = nil
        }
        .onReceive(user.$isLoading) { isLoading in
            if let isLoading = isLoading, !isLoading {
                user.isLoading = nil
                onLoadingComplete()
            }
        }
        .accentColor(mainColor())
        .background(formBackgroundColor().edgesIgnoringSafeArea(.all))
    }
    
    func reset() {
        password = ""
        email = ""
        user.userErrors = [String]()
    }
    
    func signin() {
        user.signin(email: email, password: password)
    }
    
    func signup() {
        user.signup(email: email, password: password)
    }
    
    // TODO: why is on loading complete called on first opening of signin view,
    // signout, change password are in settings, have on receive in settings to do aa loadingcomplete
    func onLoadingComplete() {
        withAnimation {
            if user.userErrors.count == 0 {
                sheetNavigator.showSheet = false
            }
        }
    }
}

//struct SigninView_Previews: PreviewProvider {
//    static var previews: some View {
//        SigninView()
//    }
//}
