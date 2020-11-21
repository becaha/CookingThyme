//
//  Direction.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/20/20.
//

import Foundation
import GRDB

struct Direction {
    struct Table {
        static let databaseTableName = "Direction"
        
        static let id = "Id"
        static let step = "Step"
        static let recipeId = "RecipeId"
        static let direction = "Direction"
    }
    
    var id: Int
    var step: Int
    var recipeId: Int
    var direction: String
    
    init(row: Row) {
        id = row[Table.id]
        step = row[Table.step]
        recipeId = row[Table.recipeId]
        direction = row[Table.direction]
    }
}
