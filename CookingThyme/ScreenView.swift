//
//  ScreenView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import SwiftUI

struct ScreenView: ViewModifier {
    
    func body(content: Content) -> some View {
        NavigationView {
            content
            .navigationBarTitle("Cooking Thyme", displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: {
                    
                }) {
                    Image(systemName: "gear").imageScale(.large)
                        .foregroundColor(.black)
                }
            )
        }
    }
}

struct ScreenView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hi").screenView()
    }
}

extension View {
    func screenView() -> some View {
        modifier(ScreenView())
    }
}
