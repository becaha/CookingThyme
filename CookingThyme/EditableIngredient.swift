//
//  EditableIngredient.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/1/20.
//

import SwiftUI

struct EditableIngredient: View {
    @EnvironmentObject var recipe: RecipeVM
    var index: Int
    
    var autocapitalization: UITextAutocapitalizationType = .none
    @State private var dummyBinding: String = ""
    
    var body: some View {
        TextField(getIngredient(), text: getIngredientBinding())
            .font(.body)

    }
    
    func getIngredient() -> String {
        if index < recipe.tempIngredients.count {
            return recipe.tempIngredients[index].ingredientString
        }
        return ""
    }
    
    func getIngredientBinding() -> Binding<String> {
        if index < recipe.tempIngredients.count {
            return $recipe.tempIngredients[index].ingredientString
        }
        return $dummyBinding
    }
}

