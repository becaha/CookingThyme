//
//  RecipeCollection.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/20/20.
//

import Foundation
import GRDB

struct RecipeCollection {
    struct Table {
        static let databaseTableName = "RecipeCollection"
        
        static let id = "Id"
        static let name = "Name"
        static let recipeId = "RecipeId"
    }
    
    var id: Int
    var name: String
    var recipeId: Int
    
    init(row: Row) {
        id = row[Table.id]
        name = row[Table.name]
        recipeId = row[Table.recipeId]
    }
}
