//
//  LoginPromptView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import SwiftUI

struct LoginPromptView: View {
    @EnvironmentObject var user: UserVM
    
    var message: String
    
    var body: some View {
        VStack {
            Spacer()
            
            Button(action: {
                user.loginPresented = true
            }) {
                Text("Login")
                
                Text("\(message)")
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
    }
}

//struct LoginPromptView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginPromptView(message: "Login to start creating your recipe book")
//    }
//}
