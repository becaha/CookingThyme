//
//  RecipeTitle.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct RecipeTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
        .multilineTextAlignment(.center)
        .customFont(style: .largeTitle)
    }
}

struct RecipeTitle_Previews: PreviewProvider {
    static var previews: some View {
        Text("Recipe Title")
            .recipeTitle()
    }
}

extension View {
    func recipeTitle() -> some View {
        modifier(RecipeTitle())
    }
}
