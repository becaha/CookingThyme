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
            ingredients.append(Ingredient.toIngredient(temp))
        }
        return ingredients
    }
    
    static func toIngredient(_ temp: TempIngredient) -> Ingredient {
        var setTemp = temp
        setTemp.setIngredientParts()
        return Ingredient(name: setTemp.name, amount: Fraction.toDouble(fromString: setTemp.amount), unitName: makeUnit(fromUnit: setTemp.unitName))
    }
    
    // takes ingredients and turns into temp ingredients for use in edit recipe
    static func toTempIngredients(_ ingredients: [Ingredient]) -> [TempIngredient] {
        var temps = [TempIngredient]()
        for ingredient in ingredients {
            temps.append(Ingredient.toTempIngredient(ingredient))
        }
        return temps
    }
    
    static func toTempIngredient(_ ingredient: Ingredient) -> TempIngredient {
        TempIngredient(name: ingredient.name, amount: ingredient.getAmountString(), unitName: ingredient.unitName.getName(), recipeId: ingredient.recipeId, id: ingredient.id)
    }
    
    static func toIngredients(fromStrings ingredientStrings: [String]) -> [Ingredient] {
        var ingredients = [Ingredient]()
        for ingredientString in ingredientStrings {
            ingredients.append(Ingredient.toIngredient(fromString: ingredientString))
        }
        return ingredients
    }
    
    enum CurrentPart {
        case amount
        case unit
        case name
    }
    
    static func toIngredient(fromString ingredientString: String) -> Ingredient {
        var amount = ""
        var unitName = ""
        var unit: UnitOfMeasurement?
        var name = ""
        var currentPart = CurrentPart.amount
        let words = ingredientString.components(separatedBy: .whitespaces)
        for word in words {
            if currentPart == CurrentPart.amount {
                // number
                if Int(word) != nil {
                    currentPart = CurrentPart.amount
                    if amount != "" {
                        amount += " "
                    }
                    amount += word
                    continue
                }
                // fraction
                else if Fraction.getFractionPieces(word).count != 0 {
                    let pieces = Fraction.getFractionPieces(word)
                    if amount != "" {
                        amount += " "
                    }
                    amount += "\(pieces[0])/\(pieces[1])"
                    continue
                }
                // 1 and 1/2
                else if word == "and" {
                    amount += " "
                    continue
                }
                // 1½
                else {
                    for char in word {
                        // 1 or ½
                        if char.isNumber {
                            if amount != "" {
                                amount += " "
                            }
                            amount += String(char)
                        }
                        else if Fraction.getFractionPieces(String(char)).count != 0 {
                            let pieces = Fraction.getFractionPieces(String(char))
                            if amount != "" {
                                amount += " "
                            }
                            amount += "\(pieces[0])/\(pieces[1])"
                        }
                        else {
                            currentPart = CurrentPart.unit
                            break
                        }
                    }
                }
            }
            if currentPart == CurrentPart.unit {
                unitName += word.lowercased()
                if UnitOfMeasurement.isUnknown(unitString: unitName) {
                    // units with two words
                    if unitName == "fluid" || unitName == "fl" {
                        continue
                    }
                    else {
                        unit = UnitOfMeasurement.none
                        currentPart = CurrentPart.name
                    }
                }
                else {
                    unit = Ingredient.makeUnit(fromUnit: unitName)
                    currentPart = CurrentPart.name
                    continue
                }
            }
            if currentPart == CurrentPart.name {
                if name != "" {
                    name += " "
                }
                name += word
            }
        }
        if unit == nil {
            unit = UnitOfMeasurement.none
        }
        let doubleAmount = Fraction.toDouble(fromString: amount)
        // unit is always made
        return Ingredient(name: name, amount: doubleAmount, unitName: unit!)
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
            string += self.unitName.getName(plural: self.amount > 1) + " "
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
    
    var ingredientString: String
    
    init(name: String, amount: String, unitName: String, recipeId: Int, id: Int?) {
        self.name = name
        self.amount = amount
        self.unitName = unitName
        self.recipeId = recipeId
        self.id = id
        
        self.ingredientString = ""
        self.ingredientString = self.toString()
    }
    
    init(ingredientString: String, recipeId: Int, id: Int?) {
        self.ingredientString = ingredientString
        self.recipeId = recipeId
        self.id = id
        
        self.name = ""
        self.amount = ""
        self.unitName = ""
        self.setIngredientParts()
    }
    
    func toString() -> String {
        Ingredient.toIngredient(self).toString()
    }
    
    mutating func setIngredientParts() {
        if ingredientString != "" {
            let ingredient = Ingredient.toIngredient(fromString: self.ingredientString)
            self.name = ingredient.name
            self.amount = ingredient.getAmountString()
            self.unitName = ingredient.unitName.getName(plural: ingredient.amount > 1)
        }
    }
}

