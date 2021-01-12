//
//  RecipeDB.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/19/20.
//
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
    
    var documentDirPath: String
    var dbPath: String
    var fileManager: FileManager
    var bundlePath: String
    
    // MARK: - Singleton
    
    static let shared = RecipeDB()
    
    private init() {
        // connect to db
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
                    // RESET DB
//                    try fileManager.removeItem(atPath: dbPath)
//                    try fileManager.copyItem(atPath: path, toPath: dbPath)
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
    
    func createDirection(_ direction: Direction, withRecipeId recipeId: Int) throws {
        try dbQueue.write{ (db: Database) in
            try db.execute(
                sql:
                """
                INSERT INTO \(Direction.Table.databaseTableName) (\(Direction.Table.step), \(Direction.Table.direction), \(Direction.Table.recipeId)) \
                VALUES (?, ?, ?)
                """,
                arguments: [direction.step, direction.direction, recipeId])
            return
        }
    }
    
    func createDirections(directions: [Direction], withRecipeId recipeId: Int) {
        do {
            for direction in directions {
                try createDirection(direction, withRecipeId: recipeId)
            }
            
            return
        } catch {
            print("Error creating directions")
            return
        }
    }
    
    func createIngredient(_ ingredient: Ingredient, withRecipeId recipeId: Int) throws {
        try dbQueue.write{ (db: Database) in
            try db.execute(
                sql:
                """
                INSERT INTO \(Ingredient.Table.databaseTableName) (\(Ingredient.Table.name), \(Ingredient.Table.amount), \(Ingredient.Table.unitName), \(Ingredient.Table.recipeId)) \
                VALUES (?, ?, ?, ?)
                """,
                arguments: [ingredient.name, ingredient.amount, ingredient.unitName.getName(), recipeId])
            return
        }
    }
    
    func createIngredients(ingredients: [Ingredient], withRecipeId recipeId: Int) {
        do {
            for ingredient in ingredients {
                try createIngredient(ingredient, withRecipeId: recipeId)
            }

            return
        } catch {
            print("Error creating ingredients")
            return
        }
    }
    
    func createImage(_ image: RecipeImage, withRecipeId recipeId: Int) throws {
        do {
            try dbQueue.write{ (db: Database) in
                try db.execute(
                    sql:
                    """
                    INSERT INTO \(RecipeImage.Table.databaseTableName) \
                    (\(RecipeImage.Table.type), \(RecipeImage.Table.data), \(RecipeImage.Table.recipeId)) \
                    VALUES (?, ?, ?)
                    """,
                    arguments: [image.type.rawValue, image.data, recipeId])
            }
            
            return
        } catch {
            print("Error creating image")
            return
        }
    }
    
    func createImages(images: [RecipeImage], withRecipeId recipeId: Int) {
        do {
            for image in images {
                try createImage(image, withRecipeId: recipeId)
            }
            return
        } catch {
            print("Error creating images")
            return
        }
    }
    
    func createImage(_ image: RecipeImage, withCategoryId categoryId: Int) {
        do {
            try dbQueue.write{ (db: Database) in
                try db.execute(
                    sql:
                    """
                    INSERT INTO \(RecipeImage.Table.databaseTableName) \
                    (\(RecipeImage.Table.type), \(RecipeImage.Table.data), \(RecipeImage.Table.categoryId)) \
                    VALUES (?, ?, ?)
                    """,
                    arguments: [image.type.rawValue, image.data, categoryId])
            }
            
            return
        } catch {
            print("Error creating image")
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
    
    func createShoppingItem(_ item: ShoppingItem, withCollectionId collectionId: Int) throws {
        try dbQueue.write{ (db: Database) in
            try db.execute(
                sql:
                """
                INSERT INTO \(ShoppingItem.Table.databaseTableName) (\(ShoppingItem.Table.name), \(ShoppingItem.Table.amount), \(ShoppingItem.Table.unitName), \(ShoppingItem.Table.completed), \(ShoppingItem.Table.collectionId)) \
                VALUES (?, ?, ?, ?, ?)
                """,
                arguments: [item.name, item.amount, item.unitName.getName(), item.completed.toInt(), collectionId])
            return
        }
    }
    
    func createShoppingItems(items: [ShoppingItem], withCollectionId collectionId: Int) {
        do {
            for item in items {
                try createShoppingItem(item, withCollectionId: collectionId)
            }

            return
        } catch {
            print("Error creating shopping items")
            return
        }
    }
    
    func createAccount(_ account: User) throws {
        try dbQueue.write{ (db: Database) in
            try db.execute(
                sql:
                """
                INSERT INTO \(User.Table.databaseTableName) (\(User.Table.username), \(User.Table.password), \(User.Table.email)) \
                VALUES (?, ?, ?)
                """,
                arguments: [account.username, account.password, account.email])
            return
        }
    }
    
    func createAccount(username: String, password: String, email: String) -> User? {
        do {
            let account = try dbQueue.write{ (db: Database) -> User in

                try db.execute(
                    sql:
                    """
                    INSERT INTO \(User.Table.databaseTableName) (\(User.Table.username), \(User.Table.password), \(User.Table.email)) \
                    VALUES (?, ?, ?)
                    """,
                    arguments: [username, password, email])

                let accountId = db.lastInsertedRowID

                return User(id: Int(accountId), username: username, password: password, email: email)
            }
            
            return account
        } catch {
            print("Error creating account")
            return nil
        }
    }
    
    func createAuth(withUserId userId: Int, authToken: String, timestamp: String) -> Auth? {
        do {
            let auth = try dbQueue.write{ (db: Database) -> Auth in

                try db.execute(
                    sql:
                    """
                    INSERT INTO \(Auth.Table.databaseTableName) (\(Auth.Table.userId), \(Auth.Table.authToken), \(Auth.Table.timestamp)) \
                    VALUES (?, ?, ?)
                    """,
                    arguments: [userId, authToken, timestamp])

                let authId = db.lastInsertedRowID

                return Auth(id: Int(authId), userId: userId, authToken: authToken, timestamp: timestamp)
            }

            return auth
        } catch {
            print("Error creating auth")
            return nil
        }
    }
    
    //MARK: - Read
    
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
    
    func getImages(forRecipe recipe: Recipe, withRecipeId recipeId: Int) -> Recipe? {
        var updatedRecipe = recipe
        do {
            let updatedRecipe = try dbQueue.read { db -> Recipe in
                let rows = try Row.fetchCursor(db,
                                               sql: """
                                                    select * from \(RecipeImage.Table.databaseTableName) \
                                                    where \(RecipeImage.Table.recipeId) = ?
                                                    """,
                                               arguments: [recipeId])
                while let row = try rows.next() {
                    updatedRecipe.addImage(row: row)
                }
                return updatedRecipe
            }
            return updatedRecipe
        } catch {
            return nil
        }
    }
    
    func getImage(withCategoryId categoryId: Int) -> RecipeImage? {
        do {
            let image = try dbQueue.inDatabase { (db: Database) -> RecipeImage? in
                let row = try Row.fetchOne(db,
                                           sql: """
                                                select * from \(RecipeImage.Table.databaseTableName) \
                                                where \(RecipeImage.Table.categoryId) = ?
                                                """,
                                           arguments: [categoryId])
                if let returnedRow = row {
                    return RecipeImage(row: returnedRow)
                }
                return nil
            }
            
            return image
            
        } catch {
            return nil
        }
    }
    
    func getAllRecipes(withCollectionId collectionId: Int) -> [Recipe] {
        var allRecipes = [Recipe]()
        do {
            let allRecipes = try dbQueue.read { db -> [Recipe] in
                let rows = try Row.fetchCursor(db,
                                               sql: """
                                                    SELECT DISTINCT \(Recipe.Table.databaseTableName).\(Recipe.Table.id), \(Recipe.Table.databaseTableName).\(Recipe.Table.name), \(Recipe.Table.databaseTableName).\(Recipe.Table.servings), \(Recipe.Table.databaseTableName).\(Recipe.Table.recipeCategoryId) FROM \(Recipe.Table.databaseTableName) \
                                                    INNER JOIN \(RecipeCategory.Table.databaseTableName) \
                                                    ON \(RecipeCategory.Table.databaseTableName).\(RecipeCategory.Table.id) = \(Recipe.Table.databaseTableName).\(Recipe.Table.recipeCategoryId)
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
    
    func getCategory(withId id: Int) -> RecipeCategory? {
        do {
            let category = try dbQueue.read { db -> RecipeCategory? in
                let row = try Row.fetchOne(db,
                                               sql: """
                                                    select * from \(RecipeCategory.Table.databaseTableName) \
                                                    where \(RecipeCategory.Table.id) = ?
                                                    """,
                                               arguments: [id])
                if let returnedRow = row {
                    return RecipeCategory(row: returnedRow)
                }
                return nil
            }
            return category
        } catch {
            return nil
        }
    }
    
    func getCollection(withUsername username: String) -> RecipeCollection? {
        do {
            let collection = try dbQueue.read { db -> RecipeCollection? in
                let row = try Row.fetchOne(db,
                                               sql: """
                                                    select * from \(RecipeCollection.Table.databaseTableName) \
                                                    where \(RecipeCollection.Table.name) = ?
                                                    """,
                                               arguments: [username])
                if let returnedRow = row {
                    return RecipeCollection(row: returnedRow)
                }
                return nil
            }
            return collection
        } catch {
            return nil
        }
    }
    
    // TODO: deprecated
    func getCollection(withId id: Int) -> RecipeCollection? {
        do {
            let collection = try dbQueue.read { db -> RecipeCollection? in
                let row = try Row.fetchOne(db,
                                               sql: """
                                                    select * from \(RecipeCollection.Table.databaseTableName) \
                                                    where \(RecipeCollection.Table.id) = ?
                                                    """,
                                               arguments: [id])
                if let returnedRow = row {
                    return RecipeCollection(row: returnedRow)
                }
                return nil
            }
            return collection
        } catch {
            return nil
        }
    }
    
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
    
    func getShoppingItems(byCollectionId collectionId: Int) -> [ShoppingItem] {
        var items = [ShoppingItem]()
        do {
            let items = try dbQueue.read { db -> [ShoppingItem] in
                let rows = try Row.fetchCursor(db,
                                               sql: """
                                                    select * from \(ShoppingItem.Table.databaseTableName) \
                                                    where \(ShoppingItem.Table.collectionId) = ?
                                                    """,
                                               arguments: [collectionId])
                while let row = try rows.next() {
                    items.append(ShoppingItem(row: row))
                }
                return items
            }
            return items
        } catch {
            return []
        }
    }
    
    func getAccount(withUsername username: String) -> User? {
        do {
            let account = try dbQueue.inDatabase { (db: Database) -> User? in
                let row = try Row.fetchOne(db,
                                           sql: """
                                                select * from \(User.Table.databaseTableName) \
                                                where \(User.Table.username) = ?
                                                """,
                                           arguments: [username])
                if let returnedRow = row {
                    return User(row: returnedRow)
                }
                return nil
            }
            
            return account
            
        } catch {
            return nil
        }
    }
    
    func getAuth(withUserId userId: Int) -> Auth? {
        do {
            let auth = try dbQueue.inDatabase { (db: Database) -> Auth? in
                let row = try Row.fetchOne(db,
                                           sql: """
                                                select * from \(Auth.Table.databaseTableName) \
                                                where \(Auth.Table.userId) = ?
                                                """,
                                           arguments: [userId])
                if let returnedRow = row {
                    return Auth(row: returnedRow)
                }
                return nil
            }
            
            return auth
            
        } catch {
            return nil
        }
    }
    
    // MARK: - Update
    
    func updateRecipe(withId id: Int, name: String, servings: Int, recipeCategoryId: Int) -> Recipe? {
        do {
            let recipe = try dbQueue.write{ (db: Database) -> Recipe in

                try db.execute(
                    sql:
                    """
                    UPDATE \(Recipe.Table.databaseTableName) \
                    SET \(Recipe.Table.name) = ?, \
                    \(Recipe.Table.servings) = ?, \
                    \(Recipe.Table.recipeCategoryId) = ? \
                    WHERE \(Recipe.Table.id) = ?
                    """,
                    arguments: [name, servings, recipeCategoryId, id])

                let recipeId = db.lastInsertedRowID
                
                if recipeId != id {
                    print("Error updating recipe")
                }

                return Recipe(id: id, name: name, servings: servings, recipeCategoryId: recipeCategoryId)
            }
            
            return recipe
        } catch {
            print("Error updating recipe")
            return nil
        }
    }
    
    func updateDirection(_ direction: Direction) throws {
        try dbQueue.write{ (db: Database) in
            try db.execute(
                sql:
                """
                UPDATE \(Direction.Table.databaseTableName) \
                SET \(Direction.Table.step) = ?, \
                \(Direction.Table.direction) = ?, \
                \(Direction.Table.recipeId) = ? \
                WHERE \(Direction.Table.id) = ?
                """,
                arguments: [direction.step, direction.direction, direction.recipeId, direction.id])
            return
        }
    }
    
    func updateDirections(withRecipeId recipeId: Int, directions: [Direction]) {
        do {
            for direction in directions {
                if direction.temp {
                    try createDirection(direction, withRecipeId: recipeId)
                }
                else {
                    try updateDirection(direction)
                }
            }
            
            return
        } catch {
            print("Error updating directions")
            return
        }
    }
    
    func updateIngredient(_ ingredient: Ingredient, withRecipeId recipeId: Int) throws {
        try dbQueue.write{ (db: Database) in
            try db.execute(
                sql:
                """
                UPDATE \(Ingredient.Table.databaseTableName) \
                SET \(Ingredient.Table.name) = ?, \
                \(Ingredient.Table.amount) = ?, \
                \(Ingredient.Table.unitName) = ?, \
                \(Ingredient.Table.recipeId) = ? \
                WHERE \(Ingredient.Table.id) = ?
                """,
                arguments: [ingredient.name, ingredient.amount, ingredient.unitName.getName(), recipeId, ingredient.id])
            return
        }
    }
    
    func updateIngredients(forRecipeId recipeId: Int, ingredients: [Ingredient]) {
        do {
            for ingredient in ingredients {
                if ingredient.temp {
                    try createIngredient(ingredient, withRecipeId: recipeId)
                }
                else {
                    try updateIngredient(ingredient, withRecipeId: recipeId)
                }
            }

            return
        } catch {
            print("Error updating ingredients")
            return
        }
    }
    
    func updateCategory(withId id: Int, name: String, recipeCollectionId: Int) {
        do {
            try dbQueue.write{ (db: Database) in

                try db.execute(
                    sql:
                    """
                    UPDATE \(RecipeCategory.Table.databaseTableName) \
                    SET \(RecipeCategory.Table.name) = ?, \
                    \(RecipeCategory.Table.recipeCollectionId) = ? \
                    WHERE \(RecipeCategory.Table.id) = ?
                    """,
                    arguments: [name, recipeCollectionId, id])

                let categoryId = db.lastInsertedRowID
                
                if categoryId != id {
                    print("Error updating category")
                }
                
                return
            }
            
            return
        } catch {
            print("Error updating category")
            return
        }
    }
    
    func updateCollection(withId id: Int, name: String) {
        do {
            try dbQueue.write{ (db: Database) in

                try db.execute(
                    sql:
                    """
                    UPDATE \(RecipeCollection.Table.databaseTableName) \
                    SET \(RecipeCollection.Table.name) = ? \
                    WHERE \(RecipeCollection.Table.id) = ?
                    """,
                    arguments: [name, id])

                let categoryId = db.lastInsertedRowID
                
                if categoryId != id {
                    print("Error updating collection")
                }
                return
            }
            return
        } catch {
            print("Error updating collection")
            return
        }
    }
    
    func updateAuth(withId id: Int, userId: Int, authToken: String, timestamp: String) -> Auth? {
        do {
            let auth = try dbQueue.write{ (db: Database) -> Auth in

                try db.execute(
                    sql:
                    """
                    UPDATE \(Auth.Table.databaseTableName) \
                    SET \(Auth.Table.userId) = ?, \
                    \(Auth.Table.authToken) = ?, \
                    \(Auth.Table.timestamp) = ? \
                    WHERE \(Auth.Table.id) = ?
                    """,
                    arguments: [userId, authToken, timestamp, id])

                let authId = db.lastInsertedRowID
                
                if authId != id {
                    print("Error updating auth")
                }

                return Auth(id: id, userId: userId, authToken: authToken, timestamp: timestamp)
            }
            
            return auth
        } catch {
            print("Error updating recipe")
            return nil
        }
    }
    
    // MARK: - Delete
    
    func deleteRecipe(withId id: Int) {
        do {
            try dbQueue.write{ (db: Database) in

                try db.execute(
                    sql:
                    """
                    DELETE FROM \(Recipe.Table.databaseTableName) \
                    WHERE \(Recipe.Table.id) = ?
                    """,
                    arguments: [id])
                
                return
            }
            return
        } catch {
            print("Error deleting recipe")
            return
        }
    }
    
    func deleteDirections(withRecipeId recipeId: Int) {
        do {
            try dbQueue.write{ (db: Database) in

                try db.execute(
                    sql:
                    """
                    DELETE FROM \(Direction.Table.databaseTableName) \
                    WHERE \(Direction.Table.recipeId) = ?
                    """,
                    arguments: [recipeId])
                
                return
            }
            return
        } catch {
            print("Error deleting directions")
            return
        }
    }
    
    func deleteIngredients(withRecipeId recipeId: Int) {
        do {
            try dbQueue.write{ (db: Database) in

                try db.execute(
                    sql:
                    """
                    DELETE FROM \(Ingredient.Table.databaseTableName) \
                    WHERE \(Ingredient.Table.recipeId) = ?
                    """,
                    arguments: [recipeId])
                
                return
            }
            return
        } catch {
            print("Error deleting ingredients")
            return
        }
    }
    
    func deleteImages(withRecipeId recipeId: Int) {
        do {
            try dbQueue.write{ (db: Database) in

                try db.execute(
                    sql:
                    """
                    DELETE FROM \(RecipeImage.Table.databaseTableName) \
                    WHERE \(RecipeImage.Table.recipeId) = ?
                    """,
                    arguments: [recipeId])
                
                return
            }
            return
        } catch {
            print("Error deleting images")
            return
        }
    }
    
    func deleteImage(withId id: Int) {
        do {
            try dbQueue.write{ (db: Database) in

                try db.execute(
                    sql:
                    """
                    DELETE FROM \(RecipeImage.Table.databaseTableName) \
                    WHERE \(RecipeImage.Table.id) = ?
                    """,
                    arguments: [id])
                
                return
            }
            return
        } catch {
            print("Error deleting image")
            return
        }
    }
    
    func deleteImage(withCategoryId categoryId: Int) {
        do {
            try dbQueue.write{ (db: Database) in

                try db.execute(
                    sql:
                    """
                    DELETE FROM \(RecipeImage.Table.databaseTableName) \
                    WHERE \(RecipeImage.Table.categoryId) = ?
                    """,
                    arguments: [categoryId])
                
                return
            }
            return
        } catch {
            print("Error deleting image")
            return
        }
    }
    
    func deleteCategory(withId id: Int) {
        do {
            try dbQueue.write{ (db: Database) in

                try db.execute(
                    sql:
                    """
                    DELETE FROM \(RecipeCategory.Table.databaseTableName) \
                    WHERE \(RecipeCategory.Table.id) = ?
                    """,
                    arguments: [id])
                
                return
            }
            return
        } catch {
            print("Error deleting category")
            return
        }
    }
    
    func deleteRecipes(withCategoryId categoryId: Int) {
        do {
            try dbQueue.write{ (db: Database) in

                try db.execute(
                    sql:
                    """
                    DELETE FROM \(Recipe.Table.databaseTableName) \
                    WHERE \(Recipe.Table.recipeCategoryId) = ?
                    """,
                    arguments: [categoryId])
                
                return
            }
            return
        } catch {
            print("Error deleting recipes in category")
            return
        }
    }
    
    func deleteShoppingItem(withId id: Int) {
        do {
            try dbQueue.write{ (db: Database) in

                try db.execute(
                    sql:
                    """
                    DELETE FROM \(ShoppingItem.Table.databaseTableName) \
                    WHERE \(ShoppingItem.Table.id) = ?
                    """,
                    arguments: [id])
                
                return
            }
            return
        } catch {
            print("Error deleting shopping item")
            return
        }
    }
    
    func deleteShoppingItems(withCollectionId collectionId: Int) {
        do {
            try dbQueue.write{ (db: Database) in

                try db.execute(
                    sql:
                    """
                    DELETE FROM \(ShoppingItem.Table.databaseTableName) \
                    WHERE \(ShoppingItem.Table.collectionId) = ?
                    """,
                    arguments: [collectionId])
                
                return
            }
            return
        } catch {
            print("Error deleting shopping items in collection")
            return
        }
    }
    
    func deleteAccount(withId id: Int) {
        do {
            try dbQueue.write{ (db: Database) in

                try db.execute(
                    sql:
                    """
                    DELETE FROM \(User.Table.databaseTableName) \
                    WHERE \(User.Table.id) = ?
                    """,
                    arguments: [id])
                
                return
            }
            return
        } catch {
            print("Error deleting account")
            return
        }
    }
    
    func deleteAuth(withUserId userId: Int) {
        do {
            try dbQueue.write{ (db: Database) in

                try db.execute(
                    sql:
                    """
                    DELETE FROM \(Auth.Table.databaseTableName) \
                    WHERE \(Auth.Table.userId) = ?
                    """,
                    arguments: [userId])
                
                return
            }
            return
        } catch {
            print("Error deleting auth")
            return
        }
    }
}
