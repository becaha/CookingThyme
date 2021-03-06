//
//  RecipeImage.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/4/20.
//

import Foundation
import Firebase


struct RecipeImage: Identifiable, Hashable {
    struct Table {
        static let databaseTableName = "RecipeImage"
        
        static let id = "Id"
        static let type = "Type"
        static let data = "Data"
        static let recipeId = "RecipeId"
        static let categoryId = "CategoryId"
    }
    
    static let defaultId = ""
    
    var id: String
    var type: ImageType
    var data: String
    // has either recipeId or categoryId
    var recipeId: String?
    var categoryId: String?
    
    init(type: ImageType, data: String, recipeId: String) {
        self.type = type
        self.data = data
        self.recipeId = recipeId
        self.id = RecipeImage.defaultId
    }
    
    // called by create image in db
    init(id: String, type: ImageType, data: String, recipeId: String) {
        self.id = id
        self.type = type
        self.data = data
        self.recipeId = recipeId
    }
    
    init(type: ImageType, data: String, categoryId: String) {
        self.type = type
        self.data = data
        self.categoryId = categoryId
        self.id = RecipeImage.defaultId
    }
    
    init(document: DocumentSnapshot) {
        let type = document.get(Table.type) as? String ?? ""
        if let type = ImageType.init(rawValue: type) {
            self.type = type
        }
        else {
            print("error getting image type")
            self.type = ImageType.error
        }
        self.data = ""
        if self.type == ImageType.url {
            self.data = document.get(Table.data) as? String ?? ""
        }
        self.recipeId = document.get(Table.recipeId) as? String ?? Recipe.defaultId
        self.categoryId = document.get(Table.categoryId) as? String ?? RecipeCategory.defaultId
        self.id = document.documentID
    }
}

enum ImageType: String {
    case url = "url"
    case uiImage = "uiImage"
    case error = "error"
}
