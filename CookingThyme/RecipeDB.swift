//
//  RecipeDB.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/19/20.
//

import Foundation
import GRDB

class RecipeDB {
    // MARK: - Constants
    
    struct Constant {
        static let fileName = "recipe"
        static let fileExtension = "db"
    }
    
    // MARK: - Properties
    
    var dbQueue: DatabaseQueue
    
    //MARK: - Singleton
    
    static let shared = RecipeDB()
    
    private init() {
        if let path = Bundle.main.path(forResource: Constant.fileName, ofType: Constant.fileExtension) {
            if let queue = try? DatabaseQueue(path: path) {
                dbQueue = queue
                return
            }
        }
        
        fatalError("Unable to connect to database")
    }
    
//    func getRecipe(byId id: Int) -> Recipe? {
//        do {
//            let recipe = try dbQueue.inDatabase { (db: Database) -> Recipe in
//                let row = try Row.fetchOne(db,
//                                           sql: """
//                                                select * from \(Recipe.Table.databaseTableName) \
//                                                where \(Recipe.Table.id) = ?
//                                                """,
//                                           arguments: [id])
//                if let returnedRow = row {
//                    return Recipe(row: returnedRow)
//                }
//            }
//            return nil
//        } catch {
//            return nil
//        }
//    }
    
    func createRecipe(name: String, servings: Int) -> RecipeTable? {
        do {
            try dbQueue.write{ (db: Database) -> RecipeTable in
                try db.execute(
                    sql: """
                    INSERT INTO \(RecipeTable.Table.databaseTableName) (\(RecipeTable.Table.name), \(RecipeTable.Table.servings)) \
                    VALUES (?, ?)
                    """,
                    arguments: [name, servings])
                
                let recipeId = db.lastInsertedRowID
                
                return RecipeTable(id: Int(recipeId), name: name, servings: servings)
            }
            return nil
        } catch {
            print("Error creating recipe")
            return nil
        }
    }
}
