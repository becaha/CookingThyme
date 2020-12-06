//
//  RecipeImage.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/4/20.
//

import Foundation
import GRDB

struct RecipeImage: RecipeImageProtocol {
    struct Table {
        static let databaseTableName = "RecipeImage"
        
        static let id = "Id"
        static let type = "Type"
        static let data = "Data"
        static let recipeId = "RecipeId"
    }
    
    var id: Int
    var type: ImageType
    var data: String
    var recipeId: Int
    
    init(type: ImageType, data: String, recipeId: Int) {
        self.type = type
        self.data = data
        self.recipeId = recipeId
        self.id = 0
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
    }
}

enum ImageType: String {
    case url = "url"
    case uiImage = "uiImage"
    case error = "error"
}


protocol RecipeImageProtocol {
    var type: ImageType { get set }
    var data: String { get set }
}
