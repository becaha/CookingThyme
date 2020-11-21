//
//  Ingredient.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation
import GRDB

struct Ingredient: Identifiable {
    
    struct Table {
        static let databaseTableName = "Ingredient"
        
        static let id = "Id"
        static let name = "Name"
        static let amount = "Amount"
        static let unit = "UnitName"
        static let recipeId = "RecipeId"
    }
    
    var name: String
    var amount: Double
    var unit: UnitOfMeasurement
    var id: Int
    var recipeId: Int
    
    // TODO get rid of
    init(name: String, amount: Double, unit: UnitOfMeasurement) {
        self.name = name
        self.amount = amount
        self.unit = unit
        self.id = Int(Double(name.hashValue) * amount)
        self.recipeId = 0 // BAD
    }
    
    init(row: Row) {
        id = row[Table.id]
        name = row[Table.name]
        amount = row[Table.amount]
        recipeId = row[Table.recipeId]
        
        let unitString: String = row[Table.unit]
        unit = UnitOfMeasurement.fromString(unitString: unitString)
    }
    
    func getFractionAmount() -> String {
        let decimalPart = amount.truncatingRemainder(dividingBy: 1)
        let wholePart = Int(amount - decimalPart)
        if decimalPart == 0 {
            return "\(wholePart)"
        }
        let rational = Rational.init(decimal: decimalPart)
        
        return "\(wholePart) \(rational.numerator)/\(rational.denominator)"
    }
}
