//
//  CreateRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/10/21.
//

import SwiftUI

struct CreateRecipeView: View {
    @EnvironmentObject var collection: RecipeCollectionVM
    @ObservedObject var category: RecipeCategoryVM
    @State var recipe: RecipeVM?

    var body: some View {
        Group {
            if recipe != nil {
                RecipeView(recipe: recipe!.recipe, isEditingRecipe: true)
            }
        }
        .environmentObject(category)
        // on appear so not called when parent and child force reinitialization
        .onAppear {
            recipe = RecipeVM(category: category, collection: collection)
        }
    }
}

