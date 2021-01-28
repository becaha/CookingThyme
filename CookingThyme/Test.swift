//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct Test: View {
    
    @State var email: String = ""
    @State var username: String = """
                                    turn off the heat and add cooked chicken and stir until well mixed. you have have to add some more corn starch to get the suace to thicken up a bit.
                                    """
    @State var password: String = ""
    @State var isSigningIn: Bool = false
    
    @State var signinErrorMessage = ""
    @State var signupErrorMessage = ""
    
    var body: some View {
        VStack {
//            ZStack {
            HStack(spacing: 0) {
                    Text(username)
                        .font(.body)
                        .opacity(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.all, 8)

//                    Spacer()
                }
//            .overlay(Rectangle().stroke())
    //            .fixedSize(horizontal: false, vertical: true)
    //            .padding(.all, 8)
                
                
                TextEditor(text: $username)
//                    .overlay(Rectangle().stroke())

//            }
        }.padding()
    }
        
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
