//
//  SigninPromptView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import SwiftUI

struct SigninPromptView: View {
    @EnvironmentObject var user: UserVM
    
    var message: String
    
    var body: some View {
        VStack {
            Spacer()
            
            Button(action: {
                user.signinPresented = true
            }) {
                Text("Sign In")
                
                Text("\(message)")
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
    }
}

//struct SigninPromptView_Previews: PreviewProvider {
//    static var previews: some View {
//        SigninPromptView(message: "Signin to start creating your recipe book")
//    }
//}
