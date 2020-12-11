//
//  RecipeControls.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/10/20.
//

import Foundation
import SwiftUI

struct RecipeControls {
    @ViewBuilder
    static func ReadDirection(withIndex index: Int, recipe: Recipe) -> some View {
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
                            .frame(width: 20, height: 20, alignment: .center)

                        Text("\(recipe.directions[index].direction)")
                    }
                    .padding(.vertical)
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
    
    @ViewBuilder
    static func AddIngredientsButton(collection: RecipeCollectionVM, recipe: Recipe, action: @escaping () -> Void) -> some View {
        VStack(alignment: .center) {
            Button(action: {
                withAnimation {
                    collection.addToShoppingList(fromRecipe: recipe)
                    action()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(UIColor.tertiarySystemFill))
                    
                    HStack {
                        Image(systemName: "cart.fill")
                        
                        Text("Add All to Shopping List")
                            .padding(.vertical)
                    }
                }
            }
        }
    }
}
