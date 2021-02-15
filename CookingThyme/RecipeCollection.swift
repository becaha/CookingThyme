//
//  RecipeCollection.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/20/20.
//

import Foundation
import GRDB
import Firebase

struct RecipeCollection {
    struct Table {
        static let databaseTableName = "RecipeCollection"
        
        static let id = "Id"
        static let name = "Name"
    }
    
    static let defaultId = ""
    
    var id: String
    var name: String
    
    init(row: Row) {
        id = row[Table.id]
        name = row[Table.name]
    }
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    init(document: DocumentSnapshot) {
        self.name = ""
        self.id = RecipeCollection.defaultId
    }
}
