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
    @State var recipeVM: RecipeVM?
    
    var recipe: Recipe
    @State var isEditingRecipe: Bool
    
//    init(recipe: Recipe, isEditingRecipe: Bool) {
//        self.recipe = recipe
//        self.isEditingRecipe = isEditingRecipe
//    }
    
    var body: some View {
        VStack {
            if recipeVM != nil {
                Group {
                    if !isEditingRecipe {
                        ReadRecipeView(isEditingRecipe: self.$isEditingRecipe)
                    }
                    else {
                        EditRecipeView(isEditingRecipe: self.$isEditingRecipe)
                    }
                }
                .environmentObject(recipeVM!)
            }
        }
        .onAppear {
            recipeVM = RecipeVM(recipe: recipe, category: category)
        }
        .navigationBarColor(offWhiteUIColor())
    }
}
