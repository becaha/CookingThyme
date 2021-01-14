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
    
    @Binding var isSettingsPresented: Bool
    @Binding var isSigninPresented: Bool

    
    var body: some View {
        if isSettingsPresented {
            Settings(isPresented: $isPresented)
        }
        else {
            SigninView(isPresented: $isPresented)
        }
    }
}

//struct HomeSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeSheet()
//    }
//}
