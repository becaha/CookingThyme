//
//  RecipeCategory.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/20/20.
//

import Foundation
import GRDB

struct RecipeCategory: Hashable {
    struct Table {
        static let databaseTableName = "RecipeCategory"
        
        static let id = "Id"
        static let name = "Name"
        static let recipeCollectionId = "RecipeCollectionId"
    }
    
    var id: Int
    var name: String
    var recipeCollectionId: Int
    
    init(name: String, recipeCollectionId: Int) {
        self.name = name
        self.recipeCollectionId = recipeCollectionId
        self.id = 0
    }
    
    init(row: Row) {
        id = row[Table.id]
        name = row[Table.name]
        recipeCollectionId = row[Table.recipeCollectionId]
    }
}
