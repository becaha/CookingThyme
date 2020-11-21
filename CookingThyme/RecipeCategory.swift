//
//  RecipeCategory.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/20/20.
//

import Foundation
import GRDB

struct RecipeCategory {
    struct Table {
        static let databaseTableName = "RecipeCategory"
        
        static let id = "Id"
        static let name = "Name"
        static let recipeCollectionId = "RecipeCollectionId"
        static let recipeId = "RecipeId"
    }
    
    var id: Int
    var name: String
    var recipeCollectionId: Int
    var recipeId: Int
    
    init(row: Row) {
        id = row[Table.id]
        name = row[Table.name]
        recipeCollectionId = row[Table.recipeCollectionId]
        recipeId = row[Table.recipeId]
    }
}
