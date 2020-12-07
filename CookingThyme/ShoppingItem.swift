//
//  ShoppingItem.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/7/20.
//

import Foundation
import GRDB

struct ShoppingItem: Identifiable {
    
    struct Table {
        static let databaseTableName = "ShoppingItem"
        
        static let id = "Id"
        static let name = "Name"
        static let amount = "Amount"
        static let unitName = "UnitName"
    }
    
    var name: String
    var amount: Double
    var unitName: UnitOfMeasurement
    var id: Int
    
    init(ingredient: Ingredient) {
        self.name = ingredient.name
        self.amount = ingredient.amount
        self.unitName = ingredient.unitName
        self.id = 0
    }
    
    init(row: Row) {
        self.id = row[Table.id]
        self.name = row[Table.name]
        self.amount = row[Table.amount]
        
        let unitString: String = row[Table.unitName]
        unitName = UnitOfMeasurement.fromString(unitString: unitString)    }
}
