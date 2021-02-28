//
//  Ingredient.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation
import Firebase


struct Ingredient: Identifiable, Equatable, Hashable {
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
        static let order = "Order"
    }
    
    static let defaultId = ""
    
    var name: String
    var amount: Double
    var unitName: UnitOfMeasurement
    var id: String
    var recipeId: String
    
    var order: Int?
    
    // temp strings
    var ingredientString: String
    var ingredientStringMeasurement: String
    
    init(name: String, amount: Double, unitName: UnitOfMeasurement) {
        self.name = name
        self.amount = amount
        self.unitName = unitName
        // temporary until id is created in db
        self.id = Ingredient.defaultId
        // is temporary, will be replaced when saved with recipe
        self.recipeId = Recipe.defaultId
        
        self.ingredientString = ""
        self.ingredientStringMeasurement = ""
        self.setTempStrings()
    }
    
    // called in edit recipe, an ingredient before saved in db
    init(name: String, amount: String, unitName: String, recipeId: String) {
        self.name = name
        self.amount = Fraction.toDouble(fromString: amount)
        self.unitName = Ingredient.makeUnit(fromUnit: unitName)
        // temporary until id is created in db
        self.id = Ingredient.defaultId
        self.recipeId = recipeId
        
        self.ingredientString = ""
        self.ingredientStringMeasurement = ""
        self.setTempStrings()
    }
    
    init(name: String, amount: Double, unitName: UnitOfMeasurement, recipeId: String) {
        self.name = name
        self.amount = amount
        self.unitName = unitName
        // temporary until id is created in db
        self.id = Ingredient.defaultId
        self.recipeId = recipeId
        
        self.ingredientString = ""
        self.ingredientStringMeasurement = ""
        self.setTempStrings()
    }
    
    // called in recipe transcriber
    init(ingredientString: String) {
        // temporary until id is created in db
        self.id = Ingredient.defaultId
        self.recipeId = Recipe.defaultId
        
        self.ingredientString = ingredientString
        self.name = ""
        self.amount = 0
        self.unitName = UnitOfMeasurement.unknown("")
        self.ingredientStringMeasurement = ""
        self.setIngredientParts()
    }
    
    // called in edit recipe, an ingredient before saved in db
    init(ingredientString: String, recipeId: String) {
        self.recipeId = recipeId
        // temporary until id is created in db
        self.id = Ingredient.defaultId
        
        self.ingredientString = ingredientString
        self.name = ""
        self.amount = 0
        self.unitName = UnitOfMeasurement.unknown("")
        self.ingredientStringMeasurement = ""
        self.setIngredientParts()
    }
    
    init(id: String?, name: String, amount: Double, unitName: UnitOfMeasurement) {
        self.name = name
        self.amount = amount
        self.unitName = unitName
        // temporary until id is created in db
        self.id = Ingredient.defaultId
        if let id = id {
            self.id = id
        }
        // is temporary, will be replaced when saved with recipe
        self.recipeId = Recipe.defaultId
        
        self.ingredientString = ""
        self.ingredientStringMeasurement = ""
        self.setTempStrings()
    }
    
    // called from create ingredient to return created
    init(id: String, name: String, amount: Double, unitName: UnitOfMeasurement, recipeId: String) {
        self.name = name
        self.amount = amount
        self.unitName = unitName
        self.id = id
        self.recipeId = recipeId
        
        self.ingredientString = ""
        self.ingredientStringMeasurement = ""
        self.setTempStrings()
    }
    
    init(document: DocumentSnapshot) {
        self.name = document.get(Table.name) as? String ?? ""
        self.amount = document.get(Table.amount) as? Double ?? 0
        let unitName = document.get(Table.unitName) as? String ?? ""
        self.unitName = UnitOfMeasurement.fromString(unitString: unitName)
        self.id = document.documentID
        self.recipeId = document.get(Table.recipeId) as? String ?? Recipe.defaultId
        
        self.ingredientString = ""
        self.ingredientStringMeasurement = ""
        self.setTempStrings()
    }
    
    mutating func setTempStrings() {
        self.ingredientString = self.toString()
        self.ingredientStringMeasurement = self.toStringMeasurement()
    }
    
    // gets the string value of the ingredient amount
    func getAmountString() -> String {
        if amount == 0 || amount == Double.nan {
            return ""
        }
        return Fraction.toString(fromDouble: amount)
    }
    
    func getMeasurementString() -> String {
        if amount == 0 {
            return ""
        }
        if unitName.caseType() == UnitType.volume {
            return getVolumeString()
        }
        else if unitName.caseType() == UnitType.mass {
            return getMassString()
        }
        
        // if unit doesn't break down, get closest fraction
        let fraction = Fraction.toFraction(fromDouble: amount, allDenominators: true)
        if self.unitName.getName(plural: false) != "" {
            return Fraction.toString(fromFraction: fraction) + " " + self.unitName.getName(plural: false)
        }
        else {
            return Fraction.toString(fromFraction: fraction)
        }
    }
    
    func getMassString() -> String {
        var massString = ""
        var index = 0
        var massCases = UnitOfMeasurement.massGramCases
        if let foundIndex = massCases.firstIndex(where: { (massUnit) -> Bool in
            self.unitName.getName() == massUnit.getName()
        }) {
            index = foundIndex
        }
        else {
            massCases = UnitOfMeasurement.massPoundCases
            if let foundIndex = massCases.firstIndex(where: { (massUnit) -> Bool in
                self.unitName.getName() == massUnit.getName()
            }) {
                index = foundIndex
            }
        }
        
        var amountLeft = self.amount
        if let bigUnit = unitName.getUnit() as? UnitMass {
            var biggerMeasurement = Measurement(value: amountLeft, unit: bigUnit)
            // array of volume units from largest to smallest
            for unit in massCases[index...] {
                // gets unit as a measurement (1.2 cups)
                if let smallerUnit = unit.getUnit() as? UnitMass {
                    let conversionMeasurement = biggerMeasurement.converted(to: smallerUnit)
                    
                    // gets closest fraction to take (1.2 cups -> 1 cup)
                    let fraction = Fraction.toFraction(fromDouble: conversionMeasurement.value)
                    // there is a big enough conversion
                    if fraction.whole > 0 || fraction.rational != nil {
                        massString += Fraction.toString(fromFraction: fraction) + " " + unit.getShorthand() + " "
                        
                        // amount left (1.2 - 1 -> .2)
                        amountLeft = conversionMeasurement.value - Fraction.toDouble(fromFraction: fraction)
                        if amountLeft == 0 {
                            massString.removeLast(1)
                            return massString
                        }
                        // sets next biggerMeasurement to current smaller measurement and amount left in it
                        biggerMeasurement = Measurement(value: amountLeft, unit: conversionMeasurement.unit)
                        
                    }
                }
            }
        }
        if massString.count > 0 {
            massString.removeLast(1)
        }
        return massString
    }
    
    func getVolumeString() -> String {
        var volString = ""
        var index = 0
        var volCases = UnitOfMeasurement.volGalCases
        if let foundIndex = volCases.firstIndex(where: { (volUnit) -> Bool in
            self.unitName.getName() == volUnit.getName()
        }) {
            index = foundIndex
        }
        else {
            volCases = UnitOfMeasurement.volLiterCases
            if let foundIndex = volCases.firstIndex(where: { (volUnit) -> Bool in
                self.unitName.getName() == volUnit.getName()
            }) {
                index = foundIndex
            }
        }
        
        var amountLeft = self.amount
        if let bigUnit = unitName.getUnit() as? UnitVolume {
            var biggerMeasurement = Measurement(value: amountLeft, unit: bigUnit)
            // array of volume units from largest to smallest
            for unit in volCases[index...] {
                // gets unit as a measurement (1.2 cups)
                if let smallerUnit = unit.getUnit() as? UnitVolume {
                    let conversionMeasurement = biggerMeasurement.converted(to: smallerUnit)
                    // gets closest fraction to take (1.2 cups -> 1 cup)
                    let fraction = Fraction.toFraction(fromDouble: conversionMeasurement.value)
                    // there is a big enough conversion
                    if fraction.whole > 0 || fraction.rational != nil {
                        volString += Fraction.toString(fromFraction: fraction) + " " + unit.getShorthand() + " "
                        
                        // amount left (1.2 - 1 -> .2)
                        amountLeft = conversionMeasurement.value - Fraction.toDouble(fromFraction: fraction)
                        if amountLeft == 0 {
                            volString.removeLast(1)
                            return volString
                        }
                        // sets next biggerMeasurement to current smaller measurement and amount left in it
                        biggerMeasurement = Measurement(value: amountLeft, unit: conversionMeasurement.unit)
                        
                    }
                }
            }
        }
        if volString.count > 0 {
            volString.removeLast(1)
        }
        return volString
    }
    
    // makes enum UnitOfMeasurement from unit String
    static func makeUnit(fromUnit unitString: String) -> UnitOfMeasurement {
        return UnitOfMeasurement.fromString(unitString: unitString)
    }
    
    // takes temporary ingredients (made in edit recipe) and turns into ingredients ready to be put in db
    static func toIngredients(_ temps: [Ingredient]) -> [Ingredient] {
        var ingredients = [Ingredient]()
        for temp in temps {
            ingredients.append(Ingredient.toIngredient(temp))
        }
        return ingredients
    }
    
    // to ingredient from temp ingredient, keeps id
    static func toIngredient(_ temp: Ingredient) -> Ingredient {
        var setTemp = temp
        setTemp.setIngredientParts()
        return setTemp
    }
    
    // used in parse recipe, temp ingredients, no id
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
    
    // used by parse recipe and temp ingredients to set amount, unit, name, no id
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
                // double
                else if Double(word) != nil && Double(word) != Double.nan && Double(word) != Double.infinity {
                    amount += word
                    continue
                }
                // fraction
                else if Fraction.getFractionPieces(word).count == 2 {
                    let pieces = Fraction.getFractionPieces(word)
                    if amount != "" {
                        amount += " "
                    }
                    if Int(pieces[0]) != nil && Int(pieces[1]) != nil {
                        amount += "\(pieces[0])/\(pieces[1])"
                        continue
                    }
                    else {
                        currentPart = CurrentPart.unit
                    }
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
    
    // turns ingredient into a one line string readable for ui (1 cup apple juice)
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
    
    func toStringMeasurement() -> String {
        var string = ""
        let measurementString = getMeasurementString()
        if measurementString != "" {
            string += measurementString + " "
        }
        string += self.name
        return string
    }
    
    mutating func setIngredientParts() {
        if ingredientString != "" {
            let ingredient = Ingredient.toIngredient(fromString: self.ingredientString)
            self.name = ingredient.name
            self.amount = ingredient.amount
            self.unitName = ingredient.unitName
            self.ingredientStringMeasurement = ingredient.getMeasurementString()
        }
    }
}
