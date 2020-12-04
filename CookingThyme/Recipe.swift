//
//  Recipe.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation
import GRDB

struct Recipe: Identifiable {
    // MARK: - Constants
    
    struct Table {
        static let databaseTableName = "Recipe"
        
        static let id = "Id"
        static let name = "Name"
        static let servings = "Servings"
        static let recipeCategoryId = "RecipeCategoryId"
    }
    
    // MARK: - DB Properties

    var id: Int
    // TODO do I want to format this or let them write it in as they want
    var name: String {
        didSet {
            name = name.lowercased().capitalized
        }
    }
    var servings: Int {
        willSet {
            changeIngredientAmounts(withRatio: Double(newValue) / Double(self.servings))
        }
    }
    var ingredients: [Ingredient] = []
    var directions: [Direction] = []
    var images: [RecipeImage] = []
    var recipeCategoryId: Int
    
    init() {
        self.id = 0
        self.name = ""
        self.servings = 0
        self.recipeCategoryId = 0
    }
    
    // TODO remove??
    init(name: String, ingredients: [Ingredient], directions: [Direction], images: [RecipeImage], servings: Int) {
        self.name = name.lowercased().capitalized
        self.ingredients = ingredients
        self.directions = directions
        self.images = images
        self.servings = servings
        self.id = 0
        self.recipeCategoryId = 0
    }
    
    init(id: Int, name: String, servings: Int, recipeCategoryId: Int) {
        self.id = id
        self.name = name.lowercased().capitalized
        self.servings = servings
        self.recipeCategoryId = recipeCategoryId
    }
    
    init(row: Row) {
        id = row[Table.id]
        name = String(row[Table.name]).lowercased().capitalized
        servings = row[Table.servings]
        recipeCategoryId = row[Table.recipeCategoryId]
    }
    
    mutating func addIngredient(row: Row) {
        ingredients.append(Ingredient(row: row))
    }
    
    mutating func addDirection(row: Row) {
        directions.append(Direction(row: row))
    }
    
    mutating func addImage(row: Row) {
        images.append(RecipeImage(row: row))
    }
    
//    var name: String
//    var ingredients: [Ingredient]
//    var directions: [String]
//    var servings: Int {
//        willSet {
//            changeIngredientAmounts(withRatio: Double(newValue) / Double(self.servings))
//        }
//    }
//    var id: UUID
//    
//    init(name: String, ingredients: [Ingredient], directions: [String], servings: Int) {
//        self.name = name
//        self.ingredients = ingredients
//        self.directions = directions
//        self.servings = servings
//        self.id = UUID()
//    }
//    
//    init() {
//        self.name = ""
//        self.ingredients = [Ingredient]()
//        self.directions = [String]()
//        self.servings = 0
//        self.id = UUID()
//    }
    
    mutating func changeIngredientAmounts(withRatio ratio: Double) {
        var newIngredients = [Ingredient]()
        for ingredient in ingredients {
            newIngredients.append(Ingredient(name: ingredient.name, amount: ingredient.amount * ratio, unitName: ingredient.unitName))
        }
        ingredients = newIngredients
    }
}
