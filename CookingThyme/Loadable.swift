//
//  Loadable.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/16/21.
//

import SwiftUI

struct Loadable: ViewModifier {
    @Binding var isLoading: Bool?
    
    func body(content: Content) -> some View {
        ZStack {
            if isLoading != nil, isLoading! {
                UIControls.Loading()
            }
            
            content
                .opacity(isLoading != nil && isLoading! ? 0.5 : 1)
                .disabled(isLoading != nil && isLoading!)
        }
    }
}

extension View {
    func loadable(isLoading: Binding<Bool?>) -> some View {
        modifier(Loadable(isLoading: isLoading))
    }
}

