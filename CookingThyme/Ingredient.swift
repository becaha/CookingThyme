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
