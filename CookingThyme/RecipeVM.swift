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
    }
    
    init() {
        self.recipe = Recipe()
    }
    
    // MARK: - Model Access
    
    var name: String {
        recipe.name
    }
    
    var servings: Int {
        recipe.servings
    }
    
    var ingredients: [Ingredient] {
        recipe.ingredients
    }
    
    var directions: [String] {
        recipe.directions
    }
    
    // MARK: - Intents
    
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
        return Ingredient(name: name, amount: doubleAmount, unit: unit)
    }
}
