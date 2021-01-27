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
//        Button(action: {
//            withAnimation {
//                directionIndicesCompleted.toggleElement(index)
//            }
//        }) {
            HStack(alignment: .top, spacing: 20) {
//                if directionIndicesCompleted.contains(index) {
//                    HStack(alignment: .center) {
//                        Text("\(index + 1)")
//
//                        Spacer()
//
//                        Image(systemName: "plus").imageScale(.medium)
//                    }
//                }
//                else {
                    Group {
                        Text("\(index + 1)")

                        Text("\(direction)")
                    }
//                }
            }
            .foregroundColor(.black)
//        }
    }
    
    // on click to edit an ingredient, this will be added to that ingredient, off click will save that to
    // temporary changed ingredients
    @ViewBuilder
    static func ReadIngredientText(_ ingredient: Ingredient) -> some View {
        Text("\(ingredient.toString())")
    }
}
