//
//  HomeSheet.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/13/21.
//

import SwiftUI

//struct HomeSheet: View {
//    @EnvironmentObject var user: UserVM
//    
//    func sheetView() -> some View {
//        if !user.isSignedIn {
//            return SigninView().eraseToAnyView()
//        }
//        else {
//            return Settings().eraseToAnyView()
//        }
//    }
//    
//    var body: some View {
//        NavigationView {
//            sheetView()
//            .environmentObject(user)
//            .navigationBarTitle("", displayMode: .inline)
//            .navigationBarItems(trailing:
//                Button(action: {
//                    user.sheetPresented = false
//                }) {
//                    Text("Done")
//                })
//        }
//    }
//}

//struct HomeSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeSheet()
//    }
//}

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

