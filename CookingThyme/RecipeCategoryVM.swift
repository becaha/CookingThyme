//
//  RecipeCategoryVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/24/20.
//

import Foundation

class RecipeCategoryVM: ObservableObject {
    var collection: RecipeCollectionVM
    @Published var category: RecipeCategory
    @Published var recipes: [Recipe]
    
    init(category: RecipeCategory, collection: RecipeCollectionVM) {
        self.category = category
        self.collection = collection
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
    
    func refreshCategory() {
        if let category = RecipeDB.shared.getCategory(withId: category.id) {
            self.category = category
            popullateRecipes()
        }
    }
    
    static func createRecipe(forCategoryId categoryId: Int, name: String, ingredients: [Ingredient], directions: [Direction], images: [RecipeImageProtocol], servings: String) -> Recipe? {
        var createdRecipe: Recipe?
        if let recipe = RecipeDB.shared.createRecipe(name: name, servings: servings.toInt(), recipeCategoryId: categoryId) {
            createdRecipe = recipe
            RecipeDB.shared.createDirections(directions: directions, withRecipeId: recipe.id)
            RecipeDB.shared.createIngredients(ingredients: ingredients, withRecipeId: recipe.id)
            RecipeDB.shared.createImages(images: images, withRecipeId: recipe.id)
        }
        return createdRecipe
    }
    
    func createRecipe(name: String, tempIngredients: [TempIngredient], directions: [Direction], images: [RecipeImageProtocol], servings: String) -> Recipe? {
        var createdRecipe: Recipe?
        let ingredients = Ingredient.toIngredients(tempIngredients)
        if let recipe = RecipeCategoryVM.createRecipe(forCategoryId: category.id, name: name, ingredients: ingredients, directions: directions, images: images, servings: servings) {
            createdRecipe = recipe
            popullateRecipes()
        }
        return createdRecipe
    }
    
    func deleteRecipe(withId id: Int) {
        RecipeDB.shared.deleteRecipe(withId: id)
        RecipeDB.shared.deleteDirections(withRecipeId: id)
        RecipeDB.shared.deleteIngredients(withRecipeId: id)
        RecipeDB.shared.deleteImages(withRecipeId: id)
        popullateRecipes()
    }
    
    func updateCategory(toName name: String) {
        collection.updateCategory(forCategoryId: category.id, toName: name)
        refreshCategory()
    }
}
