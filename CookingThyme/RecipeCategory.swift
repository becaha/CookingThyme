//
//  RecipeCategory.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/20/20.
//

import Foundation
import Firebase

struct RecipeCategory: Hashable {
    struct Table {
        static let databaseTableName = "RecipeCategory"
        
        static let id = "Id"
        static let name = "Name"
        static let recipeCollectionId = "RecipeCollectionId"
    }
    
    static let defaultId = ""
    
    var id: String
    var name: String
    var recipeCollectionId: String
    
    // called by create category in db
    init(id: String, name: String, recipeCollectionId: String) {
        self.id = id
        self.name = name
        self.recipeCollectionId = recipeCollectionId
    }
    
    init(name: String, recipeCollectionId: String) {
        self.name = name
        self.recipeCollectionId = recipeCollectionId
        self.id = RecipeCategory.defaultId
    }
    
    init(document: DocumentSnapshot) {
        self.id = document.documentID
        self.name = document.get(Table.name) as? String ?? ""
        self.recipeCollectionId = document.get(Table.recipeCollectionId) as? String ?? RecipeCollection.defaultId
    }
}


