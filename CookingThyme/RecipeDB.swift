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
    
    func createRecipe(name: String, servings: Int) -> Recipe? {
        do {
            let writeResult = try dbQueue.write{ (db: Database) -> Recipe in
                let executeResult = try db.execute(
                    sql:
                    """
                    INSERT INTO \(Recipe.Table.databaseTableName) (\(Recipe.Table.name), \(Recipe.Table.servings)) \
                    VALUES (?, ?)
                    """,
                    arguments: [name, servings])
                
                let recipeId = db.lastInsertedRowID
                
                return Recipe(id: Int(recipeId), name: name, servings: servings)
            }
            
            return Recipe(id: Int(writeResult.id), name: name, servings: servings)
        } catch {
            print("Error creating recipe")
            return nil
        }
        
        // must also add recipe to recipe collection, recipe category all
    }
    
    //MARK: - Read
    
    func getFullRecipe(byId id: Int) -> Recipe? {
        if let recipe = getRecipe(byId: id) {
            if let recipeWithIngredients = addIngredients(toRecipe: recipe, withId: id) {
                return addDirections(toRecipe: recipeWithIngredients, withId: id)
            }
        }
        return nil
    }
    
    func getRecipe(byId id: Int) -> Recipe? {
        do {
            let recipe = try dbQueue.inDatabase { (db: Database) -> Recipe? in
                let row = try Row.fetchOne(db,
                                           sql: """
                                                select * from \(Recipe.Table.databaseTableName) \
                                                where \(Recipe.Table.id) = ?
                                                """,
                                           arguments: [id])
                if let returnedRow = row {
                    return Recipe(row: returnedRow)
                }
                return nil
            }
            
            return recipe
            
        } catch {
            return nil
        }
    }
    
    func addIngredients(toRecipe recipe: Recipe, withId recipeId: Int) -> Recipe? {
        var updatedRecipe = recipe
        do {
            let updatedRecipe = try dbQueue.read { db -> Recipe in
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
    
    func addDirections(toRecipe recipe: Recipe, withId recipeId: Int) -> Recipe? {
        var updatedRecipe = recipe
        do {
            let updatedRecipe = try dbQueue.read { db -> Recipe in
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
    
    func getRecipes(byCategory category: String, withCollectionId collectionId: Int) -> [Recipe] {
        var categoryRecipes = [Recipe]()
        do {
            let categoryRecipes = try dbQueue.read { db -> [Recipe] in
                let rows = try Row.fetchCursor(db,
                                               sql: """
                                                    SELECT \(Recipe.Table.databaseTableName).\(Recipe.Table.id), \(Recipe.Table.databaseTableName).\(Recipe.Table.name), \(Recipe.Table.databaseTableName).\(Recipe.Table.servings) FROM \(Recipe.Table.databaseTableName) \
                                                    INNER JOIN \(RecipeCategory.Table.databaseTableName) \
                                                    ON \(RecipeCategory.Table.databaseTableName).\(RecipeCategory.Table.recipeId) = \(Recipe.Table.databaseTableName).\(Recipe.Table.id)
                                                    WHERE \(RecipeCategory.Table.databaseTableName).\(RecipeCategory.Table.recipeCollectionId) = ? \
                                                    AND \(RecipeCategory.Table.databaseTableName).\(RecipeCategory.Table.name) = ?
                                                    """,
                                               arguments: [collectionId, category])
                while let row = try rows.next() {
                    categoryRecipes.append(Recipe(row: row))
                }
                return categoryRecipes
            }
            return categoryRecipes
        } catch {
            return []
        }
    }
    
    func getAllRecipes(byCollectionId collectionId: Int) -> [Recipe] {
        var allRecipes = [Recipe]()
        do {
            let allRecipes = try dbQueue.read { db -> [Recipe] in
                let rows = try Row.fetchCursor(db,
                                               sql: """
                                                    SELECT distinct \(Recipe.Table.id), \(Recipe.Table.name), \(Recipe.Table.servings) FROM \(Recipe.Table.databaseTableName) \
                                                    INNER JOIN \(RecipeCategory.Table.databaseTableName) \
                                                    ON \(RecipeCategory.Table.databaseTableName).\(RecipeCategory.Table.recipeId) = \(Recipe.Table.databaseTableName).\(Recipe.Table.id)
                                                    WHERE \(RecipeCategory.Table.databaseTableName).\(RecipeCategory.Table.recipeCollectionId) = ?
                                                    """,
                                               arguments: [collectionId])
                while let row = try rows.next() {
                    allRecipes.append(Recipe(row: row))
                }
                return allRecipes
            }
            return allRecipes
        } catch {
            return []
        }
    }
    
    func getCategories(byCollectionId collectionId: Int) -> [String] {
        var categories = [String]()
        do {
            let categories = try dbQueue.read { db -> [String] in
                let rows = try Row.fetchCursor(db,
                                               sql: """
                                                    select * from (
                                                    select distinct \(RecipeCategory.Table.name) from \(RecipeCategory.Table.databaseTableName) \
                                                    where \(RecipeCategory.Table.recipeCollectionId) = ?)
                                                    """,
                                               arguments: [collectionId])
                while let row = try rows.next() {
                    categories.append(row[RecipeCategory.Table.name])
                }
                return categories
            }
            return categories
        } catch {
            return []
        }
    }
}
