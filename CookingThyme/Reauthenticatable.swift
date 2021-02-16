//
//  Reauthenticatable.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/16/21.
//

import SwiftUI

struct Reauthenticatable: ViewModifier {
    @EnvironmentObject var user: UserVM
    
    @Binding var isReauthenticating: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .opacity(isReauthenticating ? 0.2 : 1)
                .disabled(isReauthenticating)
            
            if isReauthenticating {
                VStack {
                    Spacer()
                    
                    VStack {
                        Text("Must Reauthenticate")
                        
                        Signin() { email, password in
                            user.reauthenticate(email: email, password: password)
                        }
                    }
                    .padding()
                    .background(lightFormBackgroundColor())
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(formBorderColor())
                            .shadow(color: Color.black, radius: 0.5)
                    )
                    .padding()
                    
                    Spacer()
                }
                
            }
        }
    }
}

extension View {
    func reauthenticatable(isReauthenticating: Binding<Bool>) -> some View {
        modifier(Reauthenticatable(isReauthenticating: isReauthenticating))
    }
}
