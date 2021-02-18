//
//  EditableDirection.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/1/20.
//

import SwiftUI
import GRDB

// TODO change to recipe.tempRecipe.directions
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
        if index < recipe.tempDirections.count {
            recipe.tempDirections[index].direction.removeLast(1)
        }
    }
    
    
    func getDirectionBinding() -> Binding<String> {
        if index < recipe.tempDirections.count {
            return $recipe.tempDirections[index].direction
        }
        return $dummyBinding
    }
    
    func getDirectionString() -> String {
        if index < recipe.tempDirections.count {
            return recipe.tempDirections[index].direction
        }
        return ""
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

