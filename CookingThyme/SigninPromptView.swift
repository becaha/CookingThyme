//
//  SigninPromptView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import SwiftUI

struct SigninPromptView: View {
    @EnvironmentObject var sheetNavigator: SheetNavigator
    @EnvironmentObject var user: UserVM
    
    var message: String
    
    var body: some View {
        VStack {
            Spacer()
            
            Button(action: {
                sheetNavigator.showSheet = true
                sheetNavigator.sheetDestination = .signin
            }) {
                Text("Sign in")
                    .customFont(style: .subheadline)
                
                Text("\(message)")
                    .customFont(style: .subheadline)
//                    .foregroundColor(.black)
            }
            
            Spacer()
        }
        .foregroundColor(mainColor())
    }
}

//struct SigninPromptView_Previews: PreviewProvider {
//    static var previews: some View {
//        SigninPromptView(message: "Signin to start creating your recipe book")
//    }
//}
