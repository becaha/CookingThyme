//
//  HomeNavigationBar.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/4/21.
//

import SwiftUI

// TODO: the nav bar to be green
struct HomeNavigationBar: ViewModifier {
    var settingsAction: () -> Void
    
    func body(content: Content) -> some View {
        NavigationView {
            content
            .background(NavigationBarConfigurator { nc in
                nc.navigationBar.barTintColor = mainUIColor()
                nc.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.black]
            })
            .font(.headline)
            .navigationBarTitle("Cooking Thyme", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: settingsAction) {
                    Image(systemName: "gear")
                        .foregroundColor(.black)
                }
            )
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
