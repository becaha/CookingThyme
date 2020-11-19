//
//  RecipeTable.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/19/20.
//

import Foundation
import GRDB

struct RecipeTable {
    // MARK: - Constants
    
    struct Table {
        static let databaseTableName = "Recipe"
        
        static let id = "Id"
        static let name = "Name"
        static let servings = "Servings"
    }
    
    // MARK: - DB Properties

    var id: Int
    var name: String
    var servings: Int
    
    init(id: Int, name: String, servings: Int) {
        self.id = id
        self.name = name
        self.servings = servings
    }
    
    init(row: Row) {
        id = row[Table.id]
        name = row[Table.name]
        servings = row[Table.servings]
    }
    
}
