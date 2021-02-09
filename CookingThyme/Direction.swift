//
//  Direction.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/20/20.
//

import Foundation
import GRDB

struct Direction: Identifiable {
    struct Table {
        static let databaseTableName = "Direction"
        
        static let id = "Id"
        static let step = "Step"
        static let recipeId = "RecipeId"
        static let direction = "Direction"
    }
    
    var id: Int
    var step: Int
    var recipeId: Int
    var direction: String
    
    init(step: Int, recipeId: Int, direction: String) {
        self.step = step
        self.recipeId = recipeId
        self.direction = direction
        // temporary until id is created in db
        self.id = 0
    }
    
    init(row: Row) {
        id = row[Table.id]
        step = row[Table.step]
        recipeId = row[Table.recipeId]
        direction = row[Table.direction]
    }
    
    // takes directions strings from edit recipe and changs them to directions with the actual recipe id for db
    static func toDirections(directionStrings: [String], withRecipeId recipeId: Int) -> [Direction] {
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
