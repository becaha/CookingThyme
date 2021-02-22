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
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)
                .formItem()

            SecureField("Password", text: $password) {
                withAnimation {
                    signin(email, password)
                }
            }
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .formItem()
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
                    .foregroundColor(.white)
                
                Spacer()
            }
        }
        .simultaneousGesture(
            TapGesture().onEnded { _ in
                unfocusEditable()
            }
        )
        .formItem(backgroundColor: mainColor())
    }
}

//struct ReauthenticateView_Previews: PreviewProvider {
//    static var previews: some View {
//        Signin()
//    }
//}
