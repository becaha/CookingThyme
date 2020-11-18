//
//  Recipe.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation

struct Recipe: Identifiable {
    var name: String
    var ingredients: [Ingredient]
    var directions: [String]
    var servings: Int {
        willSet {
            changeIngredientAmounts(withRatio: Double(newValue) / Double(self.servings))
        }
    }
    var id: UUID
    
    init(name: String, ingredients: [Ingredient], directions: [String], servings: Int) {
        self.name = name
        self.ingredients = ingredients
        self.directions = directions
        self.servings = servings
        self.id = UUID()
    }
    
    init() {
        self.name = ""
        self.ingredients = [Ingredient]()
        self.directions = [String]()
        self.servings = 0
        self.id = UUID()
    }
    
    mutating func changeIngredientAmounts(withRatio ratio: Double) {
        var newIngredients = [Ingredient]()
        for ingredient in ingredients {
            newIngredients.append(Ingredient(name: ingredient.name, amount: ingredient.amount * ratio, unit: ingredient.unit))
        }
        ingredients = newIngredients
    }
}
