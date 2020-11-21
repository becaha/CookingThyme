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
    
    func getFullRecipe(byId id: Int) -> RecipeTable? {
        do {
            let recipe = try dbQueue.inDatabase { (db: Database) -> RecipeTable? in
                let row = try Row.fetchOne(db,
                                           sql: """
                                                select \(RecipeTable.Table.name), \(RecipeTable.Table.servings), \(Ingredient.Table.name), \(Ingredient.Table.amount), \(Ingredient.Table.unit), \(Direction.Table.step), \(Direction.Table.direction) from \(RecipeTable.Table.databaseTableName) \
                                                inner join \(Ingredient.Table.databaseTableName) on \
                                                \(RecipeTable.Table.id) = \(Ingredient.Table.recipeId) \
                                                inner join \(Direction.Table.databaseTableName) on \
                                                \(RecipeTable.Table.id) = \(Direction.Table.recipeId) \
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
    
    func getIngredients(forRecipe recipe: RecipeTable, withId recipeId: Int) -> RecipeTable? {
        var updatedRecipe = recipe
        do {
            let updatedRecipe = try dbQueue.read { db -> RecipeTable in
                let rows = try Row.fetchCursor(db,
                                               sql: """
                                                    select * from \(Ingredient.Table.databaseTableName) \
                                                    where \(Ingredient.Table.recipeId) = ?
                                                    """,
                                               arguments: [recipeId])
                while let row = try rows.next() {
                    updatedRecipe.addIngredient(row: row)
                }
                return updatedRecipe
            }
            return updatedRecipe
        } catch {
            return nil
        }
    }
    
    func getDirections(forRecipe recipe: RecipeTable, withId recipeId: Int) -> RecipeTable? {
        var updatedRecipe = recipe
        do {
            let updatedRecipe = try dbQueue.read { db -> RecipeTable in
                let rows = try Row.fetchCursor(db,
                                               sql: """
                                                    select * from \(Direction.Table.databaseTableName) \
                                                    where \(Direction.Table.recipeId) = ?
                                                    """,
                                               arguments: [recipeId])
                while let row = try rows.next() {
                    updatedRecipe.addDirection(row: row)
                }
                return updatedRecipe
            }
            return updatedRecipe
        } catch {
            return nil
        }
    }
    
    func getRecipes(byCategory category: String, withCollectionId collectionId: Int) -> [RecipeTable] {
        var categoryRecipes = [RecipeTable]()
        do {
            let categoryRecipes = try dbQueue.read { db -> [RecipeTable] in
                let rows = try Row.fetchCursor(db,
                                               sql: """
                                                    SELECT * FROM \(RecipeTable.Table.databaseTableName) \
                                                    INNER JOIN \(RecipeCategory.Table.databaseTableName) \
                                                    ON \(RecipeCategory.Table.databaseTableName).\(RecipeCategory.Table.recipeId) = \(RecipeTable.Table.databaseTableName).\(RecipeTable.Table.id)
                                                    WHERE \(RecipeCategory.Table.databaseTableName).\(RecipeCategory.Table.recipeCollectionId) = ? \
                                                    AND \(RecipeCategory.Table.databaseTableName).\(RecipeCategory.Table.name) = ?
                                                    """,
                                               arguments: [collectionId, category])
                while let row = try rows.next() {
                    categoryRecipes.append(RecipeTable(row: row))
                }
                return categoryRecipes
            }
            return categoryRecipes
        } catch {
            return categoryRecipes
        }
    }
}
