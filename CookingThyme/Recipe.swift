//
//  Recipe.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation
import Firebase


struct Recipe: Identifiable, Hashable {
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
    
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

    var servings: Int
    var ingredients: [Ingredient] = []
    var directions: [Direction] = []
    var images: [RecipeImage] = []
    var source: String = ""
    var recipeCategoryId: String
    
    // for search recipes
    var detailId: Int?
    
    // for servings ratio
    // when servings change, change the amounts of all ingredients to reflect it
    var ratioServings: Int = 0 {
        willSet {
            if newValue != 0 {
                changeIngredientAmounts(withRatio: Double(newValue) / Double(self.servings))
            }
        }
    }
    var ratioIngredients: [Ingredient] = []
    
    // recipe from api will have a detail id and name
    init(detailId: Int, name: String) {
        self.id = detailId.toString()
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
    
    // used to create temp recipe from recipe
    init(id: String, name: String, ingredients: [Ingredient], directions: [Direction], images: [RecipeImage], servings: Int, source: String, recipeCategoryId: String) {
        self.id = id
        self.name = name.lowercased().capitalized
        self.ingredients = ingredients
        self.directions = directions
        self.images = images
        self.servings = servings
        self.source = source
        self.recipeCategoryId = recipeCategoryId
    }
    
    // DAN's recipe init, images [], servings 0, source: ""
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
    
    mutating func addImage(_ image: RecipeImage) {
        images.append(image)
    }
    
    // change ratio ingredient amounts according to the serving size change
    mutating func changeIngredientAmounts(withRatio ratio: Double) {
        var newIngredients = [Ingredient]()
        for ingredient in ingredients {
            newIngredients.append(Ingredient(name: ingredient.name, amount: ingredient.amount * ratio, unitName: ingredient.unitName))
        }
        ratioIngredients = newIngredients
    }
}
