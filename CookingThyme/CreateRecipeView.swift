//
//  CreateRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/24/20.
//

import SwiftUI

struct CreateRecipeView: View {
    @EnvironmentObject var category: RecipeCategoryVM
    @Binding var isCreatingRecipe: Bool
    @EnvironmentObject var recipe: RecipeVM
    
    var body: some View {
        EditRecipeView(isEditingRecipe: $isCreatingRecipe, isCreatingRecipe: true)
    }
}
