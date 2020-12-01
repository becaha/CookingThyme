//
//  EditableIngredient.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/1/20.
//

import SwiftUI

//TODO: have auto capitalization an option
struct EditableIngredient: View {
    @EnvironmentObject var recipeVM: RecipeVM
    var index: Int
    var autocapitalization: UITextAutocapitalizationType

    @State private var dummyBinding: String = ""
    
    init(index: Int) {
        self.index = index
        self.autocapitalization = .none
    }
    
    var body: some View {
        HStack {
            TextField(getAmount(), text: getAmountBinding())
                .autocapitalization(autocapitalization)
            
            TextField(getUnit(), text: getUnitBinding())
                .autocapitalization(autocapitalization)
            
            TextField(getName(), text: getNameBinding())
                .autocapitalization(autocapitalization)
        }
    }
    
    func getAmount() -> String {
        if index < recipeVM.tempIngredients.count {
            return recipeVM.tempIngredients[index].amount
        }
        return ""
    }
    
    func getAmountBinding() -> Binding<String> {
        if index < recipeVM.tempIngredients.count {
            return $recipeVM.tempIngredients[index].amount
        }
        return $dummyBinding
    }
    
    func getUnit() -> String {
        if index < recipeVM.tempIngredients.count {
            return recipeVM.tempIngredients[index].unitName
        }
        return ""
    }

    func getUnitBinding() -> Binding<String> {
        if index < recipeVM.tempIngredients.count {
            return $recipeVM.tempIngredients[index].unitName
        }
        return $dummyBinding
    }

    func getName() -> String {
        if index < recipeVM.tempIngredients.count {
            return recipeVM.tempIngredients[index].name
        }
        return ""
    }

    func getNameBinding() -> Binding<String> {
        if index < recipeVM.tempIngredients.count {
            return $recipeVM.tempIngredients[index].name
        }
        return $dummyBinding
    }
}

