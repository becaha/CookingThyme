//
//  EditableDirection.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/1/20.
//

import SwiftUI

struct EditableDirection: View {
    @EnvironmentObject var recipe: RecipeVM
    var index: Int
    @Binding var editingIndex: Int?

    var autocapitalization: UITextAutocapitalizationType = .sentences
    @State private var dummyBinding: String = ""
    
    var body: some View {
        ZStack {
            SpaceKeeper(text: " ")
            
            SpaceKeeper(text: getDirectionString())

            if editingIndex == index {
                VStack {
                    Spacer()
                    
                    EditableTextView(textBinding: getDirectionBinding(), isFirstResponder: true)
                        .customFont(style: .subheadline)
                        .onChange(of: getDirectionString()) { value in
                            if value.hasSuffix("\n") {
                                commitDirection()
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
    
    func commitDirection() {
        if index < recipe.tempRecipe.directions.count {
            recipe.tempRecipe.directions[index].direction.removeLast(1)
//            recipe.tempRecipe.ingredients[index].setIngredientParts()
        }
    }
    
    
    func getDirectionBinding() -> Binding<String> {
        if index < recipe.tempRecipe.directions.count {
            return $recipe.tempRecipe.directions[index].direction
        }
        return $dummyBinding
    }
    
    func getDirectionString() -> String {
        if index < recipe.tempRecipe.directions.count {
            return recipe.tempRecipe.directions[index].direction
        }
        return ""
    }
    
    @ViewBuilder
    func SpaceKeeper(text: String) -> some View {
        HStack {
            // keep this as read ingredient text
            RecipeControls.ReadIngredientText(text)
                .padding()

            Spacer()
        }
        .opacity(editingIndex != index ? 1 : 0)
    }
}

