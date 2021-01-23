//
//  RecipeTitleBorder.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct RecipeTitleBorder: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
        }
        .padding()
    }
}

struct RecipeTitleBorder_Previews: PreviewProvider {
    static var previews: some View {
        Text("hi").recipeTitleBorder()
    }
}

extension View {
    func recipeTitleBorder() -> some View {
        modifier(RecipeTitleBorder())
    }
}
