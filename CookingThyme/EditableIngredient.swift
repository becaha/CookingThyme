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
    var autocapitalization: UITextAutocapitalizationType

    @State private var dummyBinding: String = ""
    
    init(index: Int) {
        self.index = index
        self.autocapitalization = .none
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Text(getIngredient())
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.all, 8)
            }
            
            TextEditor(text: getIngredientBinding())
                .autocapitalization(autocapitalization)
        }
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

