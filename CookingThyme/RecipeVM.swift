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
    @Published var tempDirections: [Direction]
    @Published var tempIngredients: [TempIngredient]
    
    // MARK: - Init
    
    init(recipe: Recipe, category: RecipeCategoryVM) {
        self.recipe = recipe
        self.category = category
        self.tempDirections = []
        self.tempIngredients = []
        popullateRecipe()
    }
    
    func popullateRecipe() {
        if let recipeWithDirections = RecipeDB.shared.getDirections(forRecipe: recipe, withId: recipe.id) {
            if let fullRecipe = RecipeDB.shared.getIngredients(forRecipe: recipeWithDirections, withId: recipe.id) {
                recipe = fullRecipe
                self.tempDirections = recipe.directions
                self.tempIngredients = Ingredient.toTempIngredients(recipe.ingredients)
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
        self.tempDirections = []
        self.tempIngredients = []
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
    
    // temporary
    
    func removeTempDirection(at index: Int) {
        tempDirections.remove(at: index)
    }
    
    func addTempDirection(_ direction: String) {
        tempDirections.append(Direction(step: tempDirections.count, recipeId: recipe.id, direction: direction))
    }
    
    func removeTempIngredient(at index: Int) {
        tempIngredients.remove(at: index)
    }
    
    func addTempIngredient(name: String, amount: String, unit: String) {
        tempIngredients.append(TempIngredient(name: name, amount: amount, unitName: unit, recipeId: recipe.id, id: nil))
    }

    
    // TODO make more robust, servings is initialized to 0 but cannot be zero once created
    func isCreatingRecipe() -> Bool {
        return recipe.servings == 0
    }
    
    func setServingSize(_ size: Int) {
        recipe.servings = size
    }
    
    // TODO
    func makeIngredient(name: String, amount: String, unit: String) -> Ingredient {
        // check if amount is written as double or as fraction, have an ingredient that keeps amount as fraction
        // (given as fraction, stay as fraction, given as decimal, change to fraction)
        // should we force them to give as fraction, give them fractions in keyboard?
        let doubleAmount = Fraction.toDouble(fromString: amount)
        // check if is correct unit of measure, (if not, should we add it? should we give them only a set of units to pick from?
        let unit = Ingredient.makeUnit(fromUnit: unit)
        return Ingredient(name: name, amount: doubleAmount, unitName: unit)
    }
    
    func updateRecipe(withId id: Int, name: String, tempIngredients: [TempIngredient], directions: [Direction], servings: String) {
        category.deleteRecipe(withId: id)
        if let recipe = category.createRecipe(name: name, tempIngredients: tempIngredients, directions: directions, servings: servings) {
            self.recipe = recipe
            refreshRecipe()
        }
        category.popullateRecipes()
    }
    
    func copyRecipe(toCategoryId categoryId: Int) {
        if let category = RecipeDB.shared.getCategory(withId: categoryId) {
            RecipeCategoryVM.createRecipe(forCategoryId: category.id, name: recipe.name, ingredients: recipe.ingredients, directions: recipe.directions, servings: recipe.servings.toString())
        }
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
