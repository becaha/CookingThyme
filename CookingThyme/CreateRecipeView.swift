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
    @State var isImportingRecipe: Bool = false
    
    var body: some View {
        NavigationView {
            if recipe.recipeText == nil {
                VStack {
                    EditRecipeView(isEditingRecipe: $isCreatingRecipe, isCreatingRecipe: true)
                }
                .navigationBarTitle("", displayMode: .inline)
            }
            else {
                ImportedRecipe(isCreatingRecipe: $isCreatingRecipe, recipeText: recipe.recipeText!)
            }
        }
        .foregroundColor(mainColor())
    }
}
