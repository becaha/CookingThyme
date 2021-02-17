//
//  Recipe.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation
import GRDB
import Firebase


struct Recipe: Identifiable {
    // MARK: - Constants
    
    struct Table {
        static let databaseTableName = "Recipe"
        
        static let id = "Id"
        static let name = "Name"
        static let servings = "Servings"
        static let source = "Source"
        static let recipeCategoryId = "RecipeCategoryId"
    }
    
    static let defaultId = ""
    
    // MARK: - DB Properties

    var id: String
    var name: String {
        didSet {
            name = name.lowercased().capitalized
        }
    }

    // when servings change, change the amounts of all ingredients to reflect it
    var servings: Int {
        willSet {
            changeIngredientAmounts(withRatio: Double(newValue) / Double(self.servings))
        }
    }
    var ingredients: [Ingredient] = []
    var directions: [Direction] = []
    var images: [RecipeImage] = []
    var source: String = ""
    var recipeCategoryId: String
    
    // for search recipes
    var detailId: Int?
    
    // recipe from api will have a detail id and name
    init(detailId: Int, name: String) {
        self.id = Recipe.defaultId
        self.detailId = detailId
        self.name = name
        self.servings = 0
        self.source = ""
        self.recipeCategoryId = RecipeCategory.defaultId
    }
    
    init() {
        self.id = Recipe.defaultId
        self.name = ""
        self.servings = 0
        self.source = ""
        self.recipeCategoryId = RecipeCategory.defaultId
    }
    
    init(name: String, ingredients: [Ingredient], directions: [Direction], images: [RecipeImage], servings: Int, source: String) {
        self.name = name.lowercased().capitalized
        self.ingredients = ingredients
        self.directions = directions
        self.images = images
        self.servings = servings
        self.source = source
        self.id = Recipe.defaultId
        self.recipeCategoryId = RecipeCategory.defaultId
    }
    
    init(id: String, name: String, servings: Int, source: String, recipeCategoryId: String) {
        self.id = id
        self.name = name.lowercased().capitalized
        self.servings = servings
        self.source = source
        self.recipeCategoryId = recipeCategoryId
    }
    
    init(row: Row) {
        id = row[Table.id]
        name = String(row[Table.name]).lowercased().capitalized
        servings = row[Table.servings]
        source = row[Table.source]
        recipeCategoryId = row[Table.recipeCategoryId]
    }
    
    init(document: DocumentSnapshot) {
        self.id = document.documentID
        self.name = document.get(Table.name) as? String ?? ""
        self.servings = document.get(Table.servings) as? Int ?? 0
        self.source = document.get(Table.source) as? String ?? ""
        self.recipeCategoryId = document.get(Table.recipeCategoryId) as? String ?? RecipeCategory.defaultId
    }
    
    mutating func addIngredient(document: DocumentSnapshot) {
        ingredients.append(Ingredient(document: document))
    }
    
    mutating func addDirection(document: DocumentSnapshot) {
        directions.append(Direction(document: document))
    }
    
    mutating func addImage(document: DocumentSnapshot, withData data: Data?) {
        images.append(RecipeImage(document: document, withData: data))
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
    
    // change ingredient amounts according to the serving size change
    mutating func changeIngredientAmounts(withRatio ratio: Double) {
        var newIngredients = [Ingredient]()
        for ingredient in ingredients {
            newIngredients.append(Ingredient(name: ingredient.name, amount: ingredient.amount * ratio, unitName: ingredient.unitName))
        }
        ingredients = newIngredients
    }
}
