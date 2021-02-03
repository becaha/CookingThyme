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
    @Binding var editingIndex: Int?
    
    var autocapitalization: UITextAutocapitalizationType = .none
    @State private var dummyBinding: String = ""
    
    var body: some View {
        ZStack {
            HStack {
                RecipeControls.ReadIngredientText(getIngredient())
                    .padding()

                Spacer()
            }
            .opacity(editingIndex != index ? 1 : 0)

            if editingIndex == index {
                VStack {
                    Spacer()
                    
                    EditableTextView(textBinding: getIngredientBinding(), isFirstResponder: true)
                        .onChange(of: getIngredient()) { value in
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
        .simultaneousGesture(
            TapGesture(count: 1).onEnded { _ in
                unfocusEditable()
                editingIndex = index
            }
        )
    }
    
//    func unfocusEditable() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
//    }
    
    func commitIngredient() {
        if index < recipe.tempIngredients.count {
            recipe.tempIngredients[index].ingredientString.removeLast(1)
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

