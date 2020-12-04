//
//  RecipeImage.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/4/20.
//

import Foundation
import GRDB

struct RecipeImage {
    struct Table {
        static let databaseTableName = "RecipeImage"
        
        static let id = "Id"
        static let url = "URL"
        static let recipeId = "RecipeId"
    }
    
    var id: Int
    var url: String
    var recipeId: Int
    
    init(url: String, recipeId: Int) {
        self.url = url
        self.recipeId = recipeId
        self.id = 0
    }
    
    init(row: Row) {
        id = row[Table.id]
        url = row[Table.url]
        recipeId = row[Table.recipeId]
    }
}
