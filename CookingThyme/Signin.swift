//
//  ReauthenticateView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/16/21.
//

import SwiftUI

struct Signin: View {
    @EnvironmentObject var user: UserVM
    
    var signin: (String, String) -> Void
        
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
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
                    signin(email, password)
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
                signin(email, password)
            }
        }) {
            HStack {
                Spacer()
                
                Text("Sign In")
                    .customFont(style: .subheadline)
                    .foregroundColor(.white)
                
                Spacer()
            }
        }
        .formItem(centered: true, backgroundColor: mainColor())
        .onTapGesture(count: 1, perform: {})
    }
}

//struct ReauthenticateView_Previews: PreviewProvider {
//    static var previews: some View {
//        Signin()
//    }
//}
