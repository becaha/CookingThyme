//
//  RecipeVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation

class RecipeVM: ObservableObject {
    @Published var recipe: Recipe
    
    // MARK: - Init
    
    init(recipe: Recipe) {
        self.recipe = recipe
        popullateRecipe()
    }
    
    func popullateRecipe() {
        if let recipeWithDirections = RecipeDB.shared.getDirections(forRecipe: recipe, withId: recipe.id) {
            if let fullRecipe = RecipeDB.shared.getIngredients(forRecipe: recipeWithDirections, withId: recipe.id) {
                recipe = fullRecipe
            }
        }
    }
    
    init() {
        self.recipe = Recipe()
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
    
    func createRecipe(name: String, ingredients: [Ingredient], directionStrings: [String], servings: String) {
        if let recipe = RecipeDB.shared.createRecipe(name: name, servings: servings.toInt()) {
            let directions = Direction.toDirections(directionStrings: directionStrings, withRecipeId: recipe.id)
            RecipeDB.shared.createDirections(directions: directions)
            RecipeDB.shared.createIngredients(ingredients: ingredients)
            self.recipe = Recipe(name: name, ingredients: ingredients, directions: directions, servings: servings.toInt())
        }
    }
    
    func setServingSize(_ size: Int) {
        recipe.servings = size
    }
    
    // TODO
    func makeIngredient(name: String, amount: String, unit: String) -> Ingredient {
        // check if amount is written as double or as fraction, have an ingredient that keeps amount as fraction
        // (given as fraction, stay as fraction, given as decimal, change to fraction)
        // should we force them to give as fraction, give them fractions in keyboard?
        let doubleAmount = 1.0
        // check if is correct unit of measure, (if not, should we add it? should we give them only a set of units to pick from?
        let unit = UnitOfMeasurement.Cup
        return Ingredient(name: name, amount: doubleAmount, unitName: unit)
    }
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
