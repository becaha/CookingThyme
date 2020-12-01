//
//  RecipeVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation

class RecipeVM: ObservableObject {
    var category: RecipeCategoryVM
    @Published var recipe: Recipe
    
    // MARK: - Init
    
    init(recipe: Recipe, category: RecipeCategoryVM) {
        self.recipe = recipe
        self.category = category
        popullateRecipe()
    }
    
    func popullateRecipe() {
        if let recipeWithDirections = RecipeDB.shared.getDirections(forRecipe: recipe, withId: recipe.id) {
            if let fullRecipe = RecipeDB.shared.getIngredients(forRecipe: recipeWithDirections, withId: recipe.id) {
                recipe = fullRecipe
            }
        }
    }
    
    func refreshRecipe() {
        if let recipe = RecipeDB.shared.getRecipe(byId: recipe.id) {
            self.recipe = recipe
            popullateRecipe()
        }
    }
    
    init(category: RecipeCategoryVM) {
        self.recipe = Recipe()
        self.category = category
    }
    
    // MARK: - Model Access
    
    var id: Int {
        Int(recipe.id)
    }
    
    var name: String {
        recipe.name.lowercased().capitalized
    }
    
    var servings: Int {
        get { recipe.servings }
        set { recipe.servings = newValue }
    }
    
    var ingredients: [Ingredient] {
        recipe.ingredients
    }
    
    var directions: [Direction] {
        recipe.directions
    }
    
    // MARK: - Intents
    
    // TODO make more robust, servings is initialized to 0 but cannot be zero once created
    func isCreatingRecipe() -> Bool {
        return recipe.servings == 0
    }
    
    func setServingSize(_ size: Int) {
        recipe.servings = size
    }
    
    func makeAmount(fromAmount amountString: String) -> Double {
        return 1.0
    }
    
    func makeUnit(fromUnit unitString: String) -> UnitOfMeasurement {
        return UnitOfMeasurement.fromString(unitString: unitString)
    }
    
    // TODO
    func makeIngredient(name: String, amount: String, unit: String) -> Ingredient {
        // check if amount is written as double or as fraction, have an ingredient that keeps amount as fraction
        // (given as fraction, stay as fraction, given as decimal, change to fraction)
        // should we force them to give as fraction, give them fractions in keyboard?
        let doubleAmount = makeAmount(fromAmount: amount)
        // check if is correct unit of measure, (if not, should we add it? should we give them only a set of units to pick from?
        let unit = makeUnit(fromUnit: unit)
        return Ingredient(name: name, amount: doubleAmount, unitName: unit)
    }
    
    func updateRecipe(withId id: Int, name: String, ingredients: [Ingredient], directionStrings: [String], servings: String) {
        category.deleteRecipe(withId: id)
        if let recipe = category.createRecipe(name: name, ingredients: ingredients, directionStrings: directionStrings, servings: servings) {
            self.recipe = recipe
            refreshRecipe()
        }
    }
    
//    func updateRecipe(withRecipeId recipeId: Int, toCategoryId categoryId: Int, name: String, ingredients: [Ingredient], directionStrings: [String], servings: String) {
//        if let recipe = RecipeDB.shared.updateRecipe(withId: recipeId, name: name, servings: servings.toInt(), recipeCategoryId: categoryId) {
//            let directions = Direction.toDirections(directionStrings: directionStrings, withRecipeId: recipe.id)
//            RecipeDB.shared.updateDirections(withRecipeId: recipeId, directions: directions)
//            RecipeDB.shared.updateIngredients(forRecipeId: recipeId, ingredients: ingredients)
//        }
//        refreshRecipe()
//    }
}

extension String {
    func toInt() -> Int {
        let formatter = NumberFormatter()
        return formatter.number(from: self)!.intValue
    }
}

extension Int {
    func toString() -> String {
        let formatter = NumberFormatter()
        return formatter.string(from: self as NSNumber)!
    }
}
