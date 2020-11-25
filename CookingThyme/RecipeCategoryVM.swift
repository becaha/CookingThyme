//
//  RecipeCategoryVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/24/20.
//

import Foundation

class RecipeCategoryVM: ObservableObject {
    @Published var category: RecipeCategory
    @Published var recipes: [Recipe]
    
    init(category: RecipeCategory) {
        self.category = category
        recipes = []
        popullateRecipes()
    }
    
    // MARK: - Model Access
    
    var id: Int {
        category.id
    }
    
    var name: String {
        category.name
    }

//    var collectionId: Int {
//        category.recipeCollectionId
//    }
    
    // MARK: - Intents
    
    func popullateRecipes() {
        self.recipes = RecipeDB.shared.getRecipes(byCategoryId: category.id)
    }
    
    func createRecipe(name: String, ingredients: [Ingredient], directionStrings: [String], servings: String) {
        if let recipe = RecipeDB.shared.createRecipe(name: name, servings: servings.toInt(), recipeCategoryId: category.id) {
            let directions = Direction.toDirections(directionStrings: directionStrings, withRecipeId: recipe.id)
            RecipeDB.shared.createDirections(directions: directions)
            RecipeDB.shared.createIngredients(ingredients: ingredients, withRecipeId: recipe.id)
        }
        popullateRecipes()
    }
    
    func deleteRecipe(withId id: Int) {
        RecipeDB.shared.deleteRecipe(withId: id)
        RecipeDB.shared.deleteDirections(withRecipeId: id)
        RecipeDB.shared.deleteIngredients(withRecipeId: id)
        popullateRecipes()
    }
}
