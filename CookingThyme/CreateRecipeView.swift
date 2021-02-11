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
    @ObservedObject var recipe: RecipeVM
    
    init(category: RecipeCategoryVM) {
        self.category = category
        // dummy initialize
        recipe = RecipeVM(recipe: Recipe())
        // real initialize with category
        recipe = RecipeVM(category: category)
    }
    
    var body: some View {
        RecipeView(recipe: recipe, isEditingRecipe: true)
            .environmentObject(category)
    }
}

