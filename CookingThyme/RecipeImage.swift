//
//  RecipeImage.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/4/20.
//

import Foundation
import GRDB
import Firebase


struct RecipeImage: Identifiable {
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
    
    init(type: ImageType, data: String, categoryId: String) {
        self.type = type
        self.data = data
        self.categoryId = categoryId
        self.id = RecipeImage.defaultId
    }
    
    init(row: Row) {
        id = row[Table.id]
        if let type = ImageType.init(rawValue: row[Table.type]) {
            self.type = type
        }
        else {
            print("error getting image type")
            self.type = ImageType.error
        }
        data = row[Table.data]
        recipeId = row[Table.recipeId]
        categoryId = row[Table.categoryId]
    }
    
    init(document: DocumentSnapshot, withData data: Data?) {
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
        else if self.type == ImageType.uiImage {
            if let data = data {
                if let dataString = ImageHandler.encodeImageFromData(data) {
                    self.data = dataString
                }
            }
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
