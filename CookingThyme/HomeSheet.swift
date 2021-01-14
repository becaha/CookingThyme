//
//  HomeSheet.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/13/21.
//

import SwiftUI

struct HomeSheet: View {
    @EnvironmentObject var user: UserVM
    
    @Binding var isPresented: Bool
    
    var body: some View {
        Group {
            if user.signinPresented {
                SigninView(isPresented: $isPresented)
            }
            else {
                Settings(isPresented: $isPresented)
            }
        }
        .environmentObject(user)
    }
}

//struct HomeSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeSheet()
//    }
//}
