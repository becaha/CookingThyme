//
//  Direction.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/20/20.
//

import Foundation
import Firebase


struct Direction: Identifiable {
    struct Table {
        static let databaseTableName = "Direction"
        
        static let id = "Id"
        static let step = "Step"
        static let recipeId = "RecipeId"
        static let direction = "Direction"
    }
    
    static let defaultId = ""
    
    var id: String
    var step: Int
    var recipeId: String
    var direction: String
    
    init(step: Int, recipeId: String, direction: String) {
        self.step = step
        self.recipeId = recipeId
        self.direction = direction
        // temporary until id is created in db
        self.id = Direction.defaultId
    }
    
    init(document: DocumentSnapshot) {
        self.step = document.get(Table.step) as? Int ?? 0
        self.direction = document.get(Table.direction) as? String ?? ""
        self.id = document.documentID
        self.recipeId = document.get(Table.recipeId) as? String ?? Recipe.defaultId
    }
    
    // takes directions strings from edit recipe and changs them to directions with the actual recipe id for db
    static func toDirections(directionStrings: [String], withRecipeId recipeId: String) -> [Direction] {
        var directions = [Direction]()
        for index in 0..<directionStrings.count {
            directions.append(Direction(step: index + 1, recipeId: recipeId, direction: directionStrings[index]))
        }
        return directions
    }
    
    // takes directions from db and changes them to strings to be used in edit recipe
    static func toStrings(directions: [Direction]) -> [String] {
        var directionStrings = [String]()
        for direction in directions {
            directionStrings.append(direction.direction)
        }
        return directionStrings
    }
}
