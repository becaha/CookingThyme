//
//  HomeNavigationBar.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/4/21.
//

import SwiftUI

struct HomeNavigationBar: ViewModifier {
    var settingsAction: () -> Void
    
    func body(content: Content) -> some View {
        NavigationView {
            content
            .customFont(style: .headline)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: settingsAction) {
                    Image(systemName: "gear")
                        .imageScale(.large)
                        .frame(width: 44, height: 44, alignment: .trailing)
                        .foregroundColor(.black)
//                        .padding(.leading)
                }
            )
                .navigationBarColor(mainUIColor(), text: "Cooking Thyme", style: nil, textColor: UIColor(Color.black))
        }
        // make sure all navigation is shown in stacks (one at a time, no sidebar)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

extension View {
    func homeNavigationBar(settingsAction: @escaping () -> Void) -> some View {
        modifier(HomeNavigationBar(settingsAction: settingsAction))
    }
}
