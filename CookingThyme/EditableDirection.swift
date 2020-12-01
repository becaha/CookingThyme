//
//  EditableDirection.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/1/20.
//

import SwiftUI

//TODO: have auto capitalization an option
struct EditableDirection: View {
    @EnvironmentObject var recipeVM: RecipeVM
    var index: Int
    var autocapitalization: UITextAutocapitalizationType

    @State private var dummyBinding: String = ""
    
    init(index: Int) {
        self.index = index
        self.autocapitalization = .sentences
    }
    
    var body: some View {
        TextField(getDirection(), text: getBinding())
            .autocapitalization(autocapitalization)
    }
    
    func getDirection() -> String {
        if index < recipeVM.tempDirections.count {
            return recipeVM.tempDirections[index].direction
        }
        return ""
    }
    
    func getBinding() -> Binding<String> {
        if index < recipeVM.tempDirections.count {
            return $recipeVM.tempDirections[index].direction
        }
        return $dummyBinding
    }
}
