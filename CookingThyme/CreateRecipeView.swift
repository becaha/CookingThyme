//
//  CreateRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/10/21.
//

import SwiftUI

struct CreateRecipeView: View {
    @EnvironmentObject var collection: RecipeCollectionVM
    @EnvironmentObject var category: RecipeCategoryVM
    
    var body: some View {
        RecipeView(recipe: RecipeVM(category: category), isEditingRecipe: true)
    }
}

struct CreateRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRecipeView()
    }
}
