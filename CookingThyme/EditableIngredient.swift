//
//  EditableIngredient.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/1/20.
//

import SwiftUI

// TODO: get change from read to edit perfect with padding
struct EditableIngredient: View {
    @EnvironmentObject var recipe: RecipeVM
    var index: Int
    @Binding var editingIndex: Int?
    
    var autocapitalization: UITextAutocapitalizationType = .none
    @State private var dummyBinding: String = ""
    
    var body: some View {
        ZStack {
            SpaceKeeper(text: " ")
            
            SpaceKeeper(text: getIngredientString())

            if editingIndex == index {
                VStack {
                    Spacer()
                    
                    EditableTextView(textBinding: getIngredientBinding(), isFirstResponder: true)
                        .customFont(style: .subheadline)
                        .onChange(of: getIngredientString()) { value in
                            if value.hasSuffix("\n") {
                                commitIngredient()
                                withAnimation {
                                    // unfocus
                                    unfocusEditable()
                                    editingIndex = nil
                                }
                            }
                        }
 
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }
    
    func commitIngredient() {
        if index < recipe.tempRecipe.ingredients.count {
            recipe.tempRecipe.ingredients[index].ingredientString.removeLast(1)
//            recipe.tempRecipe.ingredients[index].setIngredientParts()
        }
    }
    
    func getIngredientString() -> String {
        if index < recipe.tempRecipe.ingredients.count {
            return recipe.tempRecipe.ingredients[index].ingredientString
        }
        return ""
    }
    
    func getIngredientBinding() -> Binding<String> {
        if index < recipe.tempRecipe.ingredients.count {
            return $recipe.tempRecipe.ingredients[index].ingredientString
        }
        return $dummyBinding
    }
    
    @ViewBuilder
    func SpaceKeeper(text: String) -> some View {
        HStack {
            RecipeControls.ReadIngredientText(text)
                .padding()

            Spacer()
        }
        .opacity(editingIndex != index ? 1 : 0)
    }
}

