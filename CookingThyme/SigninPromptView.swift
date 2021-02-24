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
            
            HStack {
                Spacer()
                
                Button(action: {
                    sheetNavigator.showSheet = true
                    sheetNavigator.sheetDestination = .signin
                }) {
                    Text("Sign in")
                        .bold()
                        .font(.subheadline)
                    
                    Text("\(message)")
                        .font(.subheadline)
                        .foregroundColor(formItemFont())
                }
                
                Spacer()
            }
            
            Spacer()
        }
        .background(formBackgroundColor())
        .foregroundColor(mainColor())
    }
}

//struct SigninPromptView_Previews: PreviewProvider {
//    static var previews: some View {
//        SigninPromptView(message: "Signin to start creating your recipe book")
//    }
//}
