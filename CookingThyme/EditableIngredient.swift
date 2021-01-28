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
        HStack {
//            ZStack {
//                TextEditor(text: getIngredientBinding())
//                    .autocapitalization(autocapitalization)
//                    .overlay(
//                        Text(getIngredient())
//                            .background(Color.blue)
//                            .multilineTextAlignment(.leading)
//                    )
                
                Text(getIngredient())
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.all, 8)

                    
            
            Spacer()
                
//                VStack {
//                    HStack {
//                        Text(getIngredient())
//                            .background(Color.blue)
//                            .multilineTextAlignment(.leading)
//                        //                    .opacity(0)
//
//                        Spacer()
//                    }
//                }
//            }
            
//            TextField(getAmount(), text: getAmountBinding())
//                .keyboardType(.numbersAndPunctuation)
//                .autocapitalization(autocapitalization)
//                .fixedSize()
//            
//            TextField(getUnit(), text: getUnitBinding())
//                .autocapitalization(autocapitalization)
//                .fixedSize()
//            
//            TextField(getName(), text: getNameBinding())
//                .autocapitalization(autocapitalization)
//                .fixedSize()
        }
        .overlay(
            TextEditor(text: getIngredientBinding())
                .autocapitalization(autocapitalization)
        )
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
    
    func getAmount() -> String {
        if index < recipe.tempIngredients.count {
            return recipe.tempIngredients[index].amount
        }
        return ""
    }
    
    func getAmountBinding() -> Binding<String> {
        if index < recipe.tempIngredients.count {
            return $recipe.tempIngredients[index].amount
        }
        return $dummyBinding
    }
    
    func getUnit() -> String {
        if index < recipe.tempIngredients.count {
            return recipe.tempIngredients[index].unitName
        }
        return ""
    }

    func getUnitBinding() -> Binding<String> {
        if index < recipe.tempIngredients.count {
            return $recipe.tempIngredients[index].unitName
        }
        return $dummyBinding
    }

    func getName() -> String {
        if index < recipe.tempIngredients.count {
            return recipe.tempIngredients[index].name
        }
        return ""
    }

    func getNameBinding() -> Binding<String> {
        if index < recipe.tempIngredients.count {
            return $recipe.tempIngredients[index].name
        }
        return $dummyBinding
    }
}

