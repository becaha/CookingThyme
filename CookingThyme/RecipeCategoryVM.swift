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
    
//    init(collection: RecipeCollectionVM) {
//        self.category = RecipeCategory(name: "All", recipeCollectionId: collection.id)
//        self.collection = collection
//        recipes = []
//        popullateRecipes()
//    }
    
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
    
    // MARK: - Intents
    
    // gets recipes of category from db
    func popullateRecipes() {
        if category.name == "All" {
            self.recipes = RecipeDB.shared.getAllRecipes(withCollectionId: collection.id)
        }
        else {
            self.recipes = RecipeDB.shared.getRecipes(byCategoryId: category.id)
        }
    }
    
    // gets category from db
    func refreshCategory() {
        if let category = RecipeDB.shared.getCategory(withId: category.id) {
            self.category = category
            popullateRecipes()
        }
    }
    
    // creates recipe for given category with given parts
    static func createRecipe(forCategoryId categoryId: Int, name: String, ingredients: [Ingredient], directions: [Direction], images: [RecipeImage], servings: String) -> Recipe? {
        var createdRecipe: Recipe?
        if let recipe = RecipeDB.shared.createRecipe(name: name, servings: servings.toInt(), recipeCategoryId: categoryId) {
            createdRecipe = recipe
            RecipeDB.shared.createDirections(directions: directions, withRecipeId: recipe.id)
            RecipeDB.shared.createIngredients(ingredients: ingredients, withRecipeId: recipe.id)
            RecipeDB.shared.createImages(images: images, withRecipeId: recipe.id)
        }
        return createdRecipe
    }
    
    // creates recipe with given partss
    func createRecipe(name: String, tempIngredients: [TempIngredient], directions: [Direction], images: [RecipeImage], servings: String) -> Recipe? {
        var createdRecipe: Recipe?
        let ingredients = Ingredient.toIngredients(tempIngredients)
        if let recipe = RecipeCategoryVM.createRecipe(forCategoryId: category.id, name: name, ingredients: ingredients, directions: directions, images: images, servings: servings) {
            createdRecipe = recipe
            popullateRecipes()
        }
        return createdRecipe
    }
    
    // deletes recipe and associated parts
    func deleteRecipe(withId id: Int) {
        RecipeDB.shared.deleteRecipe(withId: id)
        RecipeDB.shared.deleteDirections(withRecipeId: id)
        RecipeDB.shared.deleteIngredients(withRecipeId: id)
        RecipeDB.shared.deleteImages(withRecipeId: id)
        popullateRecipes()
    }
    
    // updates category name
    func updateCategory(toName name: String) {
        collection.updateCategory(forCategoryId: category.id, toName: name)
        refreshCategory()
    }
}
