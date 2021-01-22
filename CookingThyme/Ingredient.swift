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
    
    init(name: String, amount: Double, unitName: UnitOfMeasurement) {
        self.name = name
        self.amount = amount
        self.unitName = unitName
        // is temporary, will be replaced
        let id = Double(name.hashValue) + Double(unitName.getName().count)
        if let uuid = Int(UUID().uuidString) {
            self.id = uuid
        }
        else {
            self.id = Int(id)
        }
        // is temporary, will be replaced
        self.recipeId = 0
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
    
    // gets the string value of the ingredient amount
    func getAmountString() -> String {
        if amount == 0 {
            return ""
        }
        return Fraction.toString(fromDouble: amount)
    }
    
    // makes enum UnitOfMeasurement from unit String
    static func makeUnit(fromUnit unitString: String) -> UnitOfMeasurement {
        return UnitOfMeasurement.fromString(unitString: unitString)
    }
    
    // takes temporary ingredients (made in edit recipe) and turns into ingredients ready to be put in db
    static func toIngredients(_ temps: [TempIngredient]) -> [Ingredient] {
        var ingredients = [Ingredient]()
        for temp in temps {
            let ingredient = Ingredient(name: temp.name, amount: Fraction.toDouble(fromString: temp.amount), unitName: makeUnit(fromUnit: temp.unitName))
            ingredients.append(ingredient)
        }
        return ingredients
    }
    
    // takes ingredients and turns into temp ingredients for use in edit recipe
    static func toTempIngredients(_ ingredients: [Ingredient]) -> [TempIngredient] {
        var temps = [TempIngredient]()
        for ingredient in ingredients {
            temps.append(TempIngredient(name: ingredient.name, amount: ingredient.getAmountString(), unitName: ingredient.unitName.getName(), recipeId: ingredient.recipeId, id: ingredient.id))
        }
        return temps
    }
    
    // TODO:
    // 1 1/2 cup flour
    static func toIngredients(fromStrings ingredientStrings: [String]) -> [Ingredient] {
        var ingredients = [Ingredient]()
        for ingredientString in ingredientStrings {
            var amount = ""
            var unit: UnitOfMeasurement?
            var name = ""
            let words = ingredientString.components(separatedBy: " ")
            for word in words {
                if Int(word) != nil || (word.count == 1 && Character(word).isNumber) {
                    if amount != "" {
                        amount += " "
                    }
                    amount += word
                    continue
                }
                else if unit == nil {
                    if UnitOfMeasurement.isUnknown(unitString: word) {
                        unit = UnitOfMeasurement.none
                    }
                    else {
                        unit = Ingredient.makeUnit(fromUnit: word)
                        continue
                    }
                }
                if name != "" {
                    name += " "
                }
                name += word
            }
            let doubleAmount = Fraction.toDouble(fromString: amount)
            if let unit = unit {
                ingredients.append(Ingredient(name: name, amount: doubleAmount, unitName: unit))
            }
        }
        return ingredients
    }
    
    // creates ingredient from given name, amount, unit in strings
    static func makeIngredient(name: String, amount: String, unit: String) -> Ingredient {
        let doubleAmount = Fraction.toDouble(fromString: amount)
        let unit = Ingredient.makeUnit(fromUnit: unit)
        return Ingredient(name: name, amount: doubleAmount, unitName: unit)
    }
    
    // turns ingredient into a one line string (1 cup apple juice)
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

// used as a temporary ingredient while editing recipe (amount and unit name are string for easy editing)
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

