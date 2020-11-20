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
        static let fileExtension = "sqlite"
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
    
    // MARK: - Create
    
    func createRecipe(name: String, servings: Int) -> RecipeTable? {
        do {
            let writeResult = try dbQueue.write{ (db: Database) -> RecipeTable in
                let sql =
                    """
                    INSERT INTO \(RecipeTable.Table.databaseTableName) (\(RecipeTable.Table.name), \(RecipeTable.Table.servings)) \
                    VALUES (?, ?)
                    """
                let executeResult = try db.execute(
                    sql:
                    """
                    INSERT INTO \(RecipeTable.Table.databaseTableName) (\(RecipeTable.Table.name), \(RecipeTable.Table.servings)) \
                    VALUES (?, ?)
                    """,
                    arguments: [name, servings])
                
                let recipeId = db.lastInsertedRowID
                
                return RecipeTable(id: Int(recipeId), name: name, servings: servings)
            }
            
            return RecipeTable(id: Int(writeResult.id), name: name, servings: servings)
        } catch {
            print("Error creating recipe")
            return nil
        }
    }
    
    //MARK: - Read
    
    func getRecipe(byId id: Int) -> RecipeTable? {
        do {
            let recipe = try dbQueue.inDatabase { (db: Database) -> RecipeTable? in
                let row = try Row.fetchOne(db,
                                           sql: """
                                                select * from \(RecipeTable.Table.databaseTableName) \
                                                where \(RecipeTable.Table.id) = ?
                                                """,
                                           arguments: [id])
                if let returnedRow = row {
                    return RecipeTable(row: returnedRow)
                }
                return nil
            }
            
            return recipe
            
        } catch {
            return nil
        }
    }
    
//    func getRecipes(byCategory category: String, withCollectionId collectionId: Int) -> [RecipeTable] {
//        do {
//            let recipes = try dbQueue.inDatabase { (db: Database) -> [RecipeTable] in
//                let row = try Row.fetchAAll(db,
//                                           sql: """
//                                                select * from \(RecipeTable.Table.databaseTableName) \
//                                                where \(RecipeTable.Table.id) = ?
//                                                """,
//                                           arguments: [id])
//                if let returnedRow = row {
//                    return RecipeTable(row: returnedRow)
//                }
//                return []
//            }
//
//            return recipes
//
//        } catch {
//            return []
//        }
//    }
    
//    func getIngredients(forRecipeId id: Int) -> RecipeTable? {
//        do {
//            let recipe = try dbQueue.inDatabase { (db: Database) -> RecipeTable? in
//                let row = try Row.fetchOne(db,
//                                           sql: """
//                                                select * from \(RecipeTable.Table.databaseTableName) \
//                                                where \(RecipeTable.Table.id) = ?
//                                                """,
//                                           arguments: [id])
//                if let returnedRow = row {
//                    return RecipeTable(row: returnedRow)
//                }
//                return nil
//            }
//            
//            return recipe
//            
//        } catch {
//            return nil
//        }
//    }
}
