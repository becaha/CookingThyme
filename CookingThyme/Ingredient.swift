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
        static let unitName = "UnitName"
        static let recipeId = "RecipeId"
    }
    
    var name: String
    var amount: Double
    var unitName: UnitOfMeasurement
    var id: Int
    var recipeId: Int
    
    // TODO get rid of
    init(name: String, amount: Double, unitName: UnitOfMeasurement) {
        self.name = name
        self.amount = amount
        self.unitName = unitName
        self.id = Int(amount)
        self.recipeId = 0 // BAD
    }
    
    init(row: Row) {
        id = row[Table.id]
        name = row[Table.name]
        amount = row[Table.amount]
        recipeId = row[Table.recipeId]
        
        let unitString: String = row[Table.unitName]
        unitName = UnitOfMeasurement.fromString(unitString: unitString)
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
