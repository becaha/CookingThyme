//
//  Ingredient.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation
import GRDB

struct Ingredient: Identifiable, Equatable {
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.id == rhs.id
    }
    
    struct Table {
        static let databaseTableName = "Ingredient"
        
        static let id = "Id"
        static let name = "Name"
        static let amount = "Amount"
        static let unitName = "UnitName"
        static let recipeId = "RecipeId"
    }
    
    var name: String
    var amount: Double
    var unitName: UnitOfMeasurement
    var id: Int
    var recipeId: Int
    var temp = false
    
    // TODO get rid of
    init(name: String, amount: Double, unitName: UnitOfMeasurement) {
        self.name = name
        self.amount = amount
        self.unitName = unitName
        let id = Double(name.hashValue) + Double(unitName.getName().count)
        if let uuid = Int(UUID().uuidString) {
            self.id = uuid
        }
        else {
            self.id = Int(id)
        }
        self.recipeId = 0 // BAD
        self.temp = true
    }
    
    init(row: Row) {
        id = row[Table.id]
        name = row[Table.name]
        amount = row[Table.amount]
        recipeId = row[Table.recipeId]
        
        let unitString: String = row[Table.unitName]
        unitName = UnitOfMeasurement.fromString(unitString: unitString)
    }
    
    func getAmountString() -> String {
        if amount == 0 {
            return ""
        }
        return Fraction.toString(fromDouble: amount)
    }
    
    static func makeUnit(fromUnit unitString: String) -> UnitOfMeasurement {
        return UnitOfMeasurement.fromString(unitString: unitString)
    }
    
    static func toIngredients(_ temps: [TempIngredient]) -> [Ingredient] {
        var ingredients = [Ingredient]()
        for temp in temps {
            let ingredient = Ingredient(name: temp.name, amount: Fraction.toDouble(fromString: temp.amount), unitName: makeUnit(fromUnit: temp.unitName))
            ingredients.append(ingredient)
        }
        return ingredients
    }
    
    static func toTempIngredients(_ ingredients: [Ingredient]) -> [TempIngredient] {
        var temps = [TempIngredient]()
        for ingredient in ingredients {
            temps.append(TempIngredient(name: ingredient.name, amount: ingredient.getAmountString(), unitName: ingredient.unitName.getName(), recipeId: ingredient.recipeId, id: ingredient.id))
        }
        return temps
    }
    
    func toString() -> String {
        var string = ""
        let amountString = getAmountString()
        if amountString != "" {
            string += amountString + " "
        }
        if self.unitName.getName() != "" {
            string += self.unitName.getName() + " "
        }
        string += self.name
        return string
    }
}

struct TempIngredient {
    
    var name: String
    var amount: String
    var unitName: String
    var recipeId: Int
    var id: Int?
    
    init(name: String, amount: String, unitName: String, recipeId: Int, id: Int?) {
        self.name = name
        self.amount = amount
        self.unitName = unitName
        self.recipeId = recipeId
        self.id = id
    }
}

