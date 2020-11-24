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
//        static let path = "/Users/rebeccanybo/Documents/recipe.sqlite"
        
    }
    
    // MARK: - Properties
    
    var dbQueue: DatabaseQueue
    
    var documentDirPath: String
    var dbPath: String
    var fileManager: FileManager
    var bundlePath: String
    
    //MARK: - Singleton
    
    static let shared = RecipeDB()
    
    private init() {
        if let path = Bundle.main.path(forResource: Constant.fileName, ofType: Constant.fileExtension) {
            bundlePath = path
            
            if let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                documentDirPath = documentDir
                // TODO path modifying
                dbPath = documentDir + "/" + Constant.fileName + "." + Constant.fileExtension
                print(dbPath)
                
                fileManager = FileManager()
                
                do {
                    if !fileManager.fileExists(atPath: dbPath) {
                        try fileManager.copyItem(atPath: path, toPath: dbPath)
                    }
                } catch {
                    print("Error copying database")
                }
                
                if let queue = try? DatabaseQueue(path: dbPath) {
                    dbQueue = queue
                    return
                }
            }
        }
        
        fatalError("Unable to connect to database")
    }
    
    // MARK: - Create
    
    // must also add recipe to recipe collection, recipe category all
//    func createRecipe(name: String, servings: Int) -> Recipe? {
//        do {
//            let writeResult = try dbQueue.write{ (db: Database) -> Recipe in
//
//                try db.execute(
//                    sql:
//                    """
//                    INSERT INTO \(Recipe.Table.databaseTableName) (\(Recipe.Table.name), \(Recipe.Table.servings)) \
//                    VALUES (?, ?)
//                    """,
//                    arguments: [name, servings])
//
//                let recipeId = db.lastInsertedRowID
//
//                return Recipe(id: Int(recipeId), name: name, servings: servings)
//            }
//            
//            return Recipe(id: writeResult.id, name: name, servings: servings)
//        } catch {
//            print("Error creating recipe")
//            return nil
//        }
//    }
    
    func createRecipe(name: String, servings: Int, recipeCategoryId: Int) -> Recipe? {
        do {
            let recipe = try dbQueue.write{ (db: Database) -> Recipe in

                try db.execute(
                    sql:
                    """
                    INSERT INTO \(Recipe.Table.databaseTableName) (\(Recipe.Table.name), \(Recipe.Table.servings), \(Recipe.Table.recipeCategoryId)) \
                    VALUES (?, ?, ?)
                    """,
                    arguments: [name, servings, recipeCategoryId])

                let recipeId = db.lastInsertedRowID

                return Recipe(id: Int(recipeId), name: name, servings: servings, recipeCategoryId: recipeCategoryId)
            }
            
            return recipe
        } catch {
            print("Error creating recipe")
            return nil
        }
    }
    
    func createDirections(directions: [Direction]) {
        do {
            for direction in directions {
                try dbQueue.write{ (db: Database) in
                    try db.execute(
                        sql:
                        """
                        INSERT INTO \(Direction.Table.databaseTableName) (\(Direction.Table.step), \(Direction.Table.direction), \(Direction.Table.recipeId)) \
                        VALUES (?, ?, ?)
                        """,
                        arguments: [direction.step, direction.direction, direction.recipeId])
                    return
                }
            }
            
            return
        } catch {
            print("Error creating directions")
            return
        }
    }
    
    func createIngredients(ingredients: [Ingredient], withRecipeId recipeId: Int) {
        do {
            for ingredient in ingredients {
                try dbQueue.write{ (db: Database) in
                    try db.execute(
                        sql:
                        """
                        INSERT INTO \(Ingredient.Table.databaseTableName) (\(Ingredient.Table.name), \(Ingredient.Table.amount), \(Ingredient.Table.unitName), \(Ingredient.Table.recipeId)) \
                        VALUES (?, ?, ?, ?)
                        """,
                        arguments: [ingredient.name, ingredient.amount, ingredient.unitName.rawValue, recipeId])
                    return
                }
            }

            return
        } catch {
            print("Error creating ingredients")
            return
        }
    }
    
    func createCategory(withName name: String, forCollectionId collectionId: Int) {
        do {
            try dbQueue.write{ (db: Database) in

                try db.execute(
                    sql:
                    """
                    INSERT INTO \(RecipeCategory.Table.databaseTableName) (\(RecipeCategory.Table.name), \(RecipeCategory.Table.recipeCollectionId)) \
                    VALUES (?, ?)
                    """,
                    arguments: [name, collectionId])
            }
        } catch {
            print("Error creating recipe")
        }
    }
    
    //MARK: - Read
    
    func getFullRecipe(byId id: Int) -> Recipe? {
        if let recipe = getRecipe(byId: id) {
            if let recipeWithIngredients = getIngredients(forRecipe: recipe, withId: id) {
                return getDirections(forRecipe: recipeWithIngredients, withId: id)
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
    
    func getIngredients(forRecipe recipe: Recipe, withId recipeId: Int) -> Recipe? {
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
    
    func getDirections(forRecipe recipe: Recipe, withId recipeId: Int) -> Recipe? {
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
    
    func getRecipes(byCategoryId categoryId: Int) -> [Recipe] {
        var categoryRecipes = [Recipe]()
        do {
            let categoryRecipes = try dbQueue.read { db -> [Recipe] in
                let rows = try Row.fetchCursor(db,
                                               sql: """
                                                    SELECT * FROM \(Recipe.Table.databaseTableName) \
                                                    WHERE \(Recipe.Table.recipeCategoryId) = ?
                                                    """,
                                               arguments: [categoryId])
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
    
//    func getAllRecipes(byCollectionId collectionId: Int) -> [Recipe] {
//        var allRecipes = [Recipe]()
//        do {
//            let allRecipes = try dbQueue.read { db -> [Recipe] in
//                let rows = try Row.fetchCursor(db,
//                                               sql: """
//                                                    SELECT \(Recipe.Table.id), \(Recipe.Table.name), \(Recipe.Table.servings) FROM \(Recipe.Table.databaseTableName) \
//                                                    INNER JOIN \(RecipeCategory.Table.databaseTableName) \
//                                                    ON \(RecipeCategory.Table.databaseTableName).\(RecipeCategory.Table.id) = \(Recipe.Table.databaseTableName).\(Recipe.Table.recipeCategoryId)
//                                                    WHERE \(RecipeCategory.Table.databaseTableName).\(RecipeCategory.Table.recipeCollectionId) = ?
//                                                    """,
//                                               arguments: [collectionId])
//                while let row = try rows.next() {
//                    allRecipes.append(Recipe(row: row))
//                }
//                return allRecipes
//            }
//            return allRecipes
//        } catch {
//            return []
//        }
//    }
    
    func getCategories(byCollectionId collectionId: Int) -> [RecipeCategory] {
        var categories = [RecipeCategory]()
        do {
            let categories = try dbQueue.read { db -> [RecipeCategory] in
                let rows = try Row.fetchCursor(db,
                                               sql: """
                                                    select * from \(RecipeCategory.Table.databaseTableName) \
                                                    where \(RecipeCategory.Table.recipeCollectionId) = ?
                                                    """,
                                               arguments: [collectionId])
                while let row = try rows.next() {
                    categories.append(RecipeCategory(row: row))
                }
                return categories
            }
            return categories
        } catch {
            return []
        }
    }
}
