//
//  RecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import SwiftUI

struct RecipeView: View {
    @EnvironmentObject var collection: RecipeCollectionVM
    @EnvironmentObject var category: RecipeCategoryVM
    @ObservedObject var recipe: RecipeVM
            
    @State var isEditingRecipe: Bool
    
    var body: some View {
        VStack {
            if !isEditingRecipe {
                ReadRecipeView(isEditingRecipe: self.$isEditingRecipe)
            }
            else {
                EditRecipeView(isEditingRecipe: self.$isEditingRecipe)
            }
        }
        .environmentObject(recipe)
        .navigationBarColor(offWhiteUIColor())
    }
}
