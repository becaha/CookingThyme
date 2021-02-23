//
//  RecipeControls.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/10/20.
//

import Foundation
import SwiftUI

// controls for recipes
struct RecipeControls {
    
    @ViewBuilder
    static func ReadDirection(withIndex index: Int, direction: String) -> some View {
        HStack(alignment: .top, spacing: 20) {
            Group {
                Text("\(index + 1)")
                    .customFont(style: .subheadline)

                Text("\(direction)")
                    .customFont(style: .body)
            }
        }
        .foregroundColor(formItemFont())
    }
    
    @ViewBuilder
    static func ReadDirection(direction: String) -> some View {
        Text("\(direction)")
            .customFont(style: .body)
    }
    
    // on click to edit an ingredient, this will be added to that ingredient, off click will save that to
    // temporary changed ingredients
    @ViewBuilder
    static func ReadIngredientText(_ ingredient: Ingredient) -> some View {
        ReadIngredientText(ingredient.toStringMeasurement())
    }
    
    @ViewBuilder
    static func ReadIngredientText(_ ingredientString: String) -> some View {
        Text("\(ingredientString)")
            .customFont(style: .body)
            .fixedSize(horizontal: false, vertical: true)
    }
}
