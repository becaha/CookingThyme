//
//  Direction.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/20/20.
//

import Foundation
import GRDB

struct Direction {
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
        self.id = 0
    }
    
    init(row: Row) {
        id = row[Table.id]
        step = row[Table.step]
        recipeId = row[Table.recipeId]
        direction = row[Table.direction]
    }
    
    static func toDirections(directionStrings: [String], withRecipeId recipeId: Int) -> [Direction] {
        var directions = [Direction]()
        for index in 0..<directionStrings.count {
            directions.append(Direction(step: index + 1, recipeId: recipeId, direction: directionStrings[index]))
        }
        return directions
    }
}
