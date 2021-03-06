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
    @EnvironmentObject var recipeSearchHandler: RecipeSearchHandler
    @State var recipeVM: RecipeVM?
    
    var recipe: Recipe
    @State var isEditingRecipe: Bool
    
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
            recipeVM = RecipeVM(recipe: recipe, category: category, collection: collection, recipeSearchHandler: recipeSearchHandler)
        }
        .navigationBarColor(UIColor(navBarColor()), text: "", style: .headline, textColor: UIColor(formItemFont()))
    }
}
