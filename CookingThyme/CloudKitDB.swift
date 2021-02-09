////
////  CloudKitDB.swift
////  CookingThyme
////
////  Created by Rebecca Nybo on 2/5/21.
////
//
//
//import Foundation
//
//class CloudKitDB {
//    // MARK: - Constants
//    
//    struct Constant {
//        static let fileName = "recipe"
//        static let fileExtension = "sqlite"
//    }
//    
//    // MARK: - Properties
//    
//    var privateDB: CKDatabase
//
//    // MARK: - Singleton
//    
//    static let shared = CloudKitDB()
//    
//    private init() {
//        // private db
//        let myContainer = CKContainer.default()
//        privateDatabase = myContainer.privateDatabase
//
//        
//        fatalError("Unable to connect to database")
//    }
//    
//    // MARK: - Create
//    
//    func createRecipe(name: String, servings: Int, source: String, recipeCategoryId: Int) -> Recipe? {
//        let recipeRecordID = CKRecordID(recordName: "115???")
//        let recipeRecord = CKRecord(recordType: "Recipe", recordID: recipeRecordID)
//        recipeRecord["name"] = name as NSString
//        recipeRecord["servings"] = servings as NSNumber
//        recipeRecord["source"] = source as NSString
//        recipeRecord["recipeCategoryId"] = recipeCategoryId as NSNumber
//        privateDatabase.save(recipeRecord) {
//            (record, error) in
//            if let error = error {
//                // Insert error handling
//                return
//            }
//            // Insert successfully saved record code
//        }
//
//    }
//    
////    func createDirection(_ direction: Direction, withRecipeId recipeId: Int) throws {
////        try dbQueue.write{ (db: Database) in
////            try db.execute(
////                sql:
////                """
////                INSERT INTO \(Direction.Table.databaseTableName) (\(Direction.Table.step), \(Direction.Table.direction), \(Direction.Table.recipeId)) \
////                VALUES (?, ?, ?)
////                """,
////                arguments: [direction.step, direction.direction, recipeId])
////            return
////        }
////    }
////
////    func createDirections(directions: [Direction], withRecipeId recipeId: Int) {
////        do {
////            for direction in directions {
////                try createDirection(direction, withRecipeId: recipeId)
////            }
////
////            return
////        } catch {
////            print("Error creating directions")
////            return
////        }
////    }
////
////    func createIngredient(_ ingredient: Ingredient, withRecipeId recipeId: Int) throws {
////        try dbQueue.write{ (db: Database) in
////            try db.execute(
////                sql:
////                """
////                INSERT INTO \(Ingredient.Table.databaseTableName) (\(Ingredient.Table.name), \(Ingredient.Table.amount), \(Ingredient.Table.unitName), \(Ingredient.Table.recipeId)) \
////                VALUES (?, ?, ?, ?)
////                """,
////                arguments: [ingredient.name, ingredient.amount, ingredient.unitName.getName(), recipeId])
////            return
////        }
////    }
////
////    func createIngredients(ingredients: [Ingredient], withRecipeId recipeId: Int) {
////        do {
////            for ingredient in ingredients {
////                try createIngredient(ingredient, withRecipeId: recipeId)
////            }
////
////            return
////        } catch {
////            print("Error creating ingredients")
////            return
////        }
////    }
////
////    func createImage(_ image: RecipeImage, withRecipeId recipeId: Int) throws {
////        do {
////            try dbQueue.write{ (db: Database) in
////                try db.execute(
////                    sql:
////                    """
////                    INSERT INTO \(RecipeImage.Table.databaseTableName) \
////                    (\(RecipeImage.Table.type), \(RecipeImage.Table.data), \(RecipeImage.Table.recipeId)) \
////                    VALUES (?, ?, ?)
////                    """,
////                    arguments: [image.type.rawValue, image.data, recipeId])
////            }
////
////            return
////        } catch {
////            print("Error creating image")
////            return
////        }
////    }
////
////    func createImages(images: [RecipeImage], withRecipeId recipeId: Int) {
////        do {
////            for image in images {
////                try createImage(image, withRecipeId: recipeId)
////            }
////            return
////        } catch {
////            print("Error creating images")
////            return
////        }
////    }
////
////    func createImage(_ image: RecipeImage, withCategoryId categoryId: Int) {
////        do {
////            try dbQueue.write{ (db: Database) in
////                try db.execute(
////                    sql:
////                    """
////                    INSERT INTO \(RecipeImage.Table.databaseTableName) \
////                    (\(RecipeImage.Table.type), \(RecipeImage.Table.data), \(RecipeImage.Table.categoryId)) \
////                    VALUES (?, ?, ?)
////                    """,
////                    arguments: [image.type.rawValue, image.data, categoryId])
////            }
////
////            return
////        } catch {
////            print("Error creating image")
////            return
////        }
////    }
////
////    func createCategory(withName name: String, forCollectionId collectionId: Int) {
////        do {
////            try dbQueue.write{ (db: Database) in
////
////                try db.execute(
////                    sql:
////                    """
////                    INSERT INTO \(RecipeCategory.Table.databaseTableName) (\(RecipeCategory.Table.name), \(RecipeCategory.Table.recipeCollectionId)) \
////                    VALUES (?, ?)
////                    """,
////                    arguments: [name, collectionId])
////            }
////        } catch {
////            print("Error creating recipe")
////        }
////    }
////
////    func createCollection(withUsername username: String) -> RecipeCollection? {
////        do {
////            let collection = try dbQueue.write{ (db: Database) -> RecipeCollection in
////
////                try db.execute(
////                    sql:
////                    """
////                    INSERT INTO \(RecipeCollection.Table.databaseTableName) (\(RecipeCollection.Table.name)) \
////                    VALUES (?)
////                    """,
////                    arguments: [username])
////
////                let collectionId = db.lastInsertedRowID
////
////                return RecipeCollection(id: Int(collectionId), name: username)
////            }
////
////            return collection
////        } catch {
////            print("Error creating collection")
////            return nil
////        }
////    }
////
////    func createShoppingItem(_ item: ShoppingItem, withCollectionId collectionId: Int) throws {
////        try dbQueue.write{ (db: Database) in
////            try db.execute(
////                sql:
////                """
////                INSERT INTO \(ShoppingItem.Table.databaseTableName) (\(ShoppingItem.Table.name), \(ShoppingItem.Table.amount), \(ShoppingItem.Table.unitName), \(ShoppingItem.Table.completed), \(ShoppingItem.Table.collectionId)) \
////                VALUES (?, ?, ?, ?, ?)
////                """,
////                arguments: [item.name, item.amount, item.unitName.getName(), item.completed.toInt(), collectionId])
////            return
////        }
////    }
////
////    func createShoppingItems(items: [ShoppingItem], withCollectionId collectionId: Int) {
////        do {
////            for item in items {
////                try createShoppingItem(item, withCollectionId: collectionId)
////            }
////
////            return
////        } catch {
////            print("Error creating shopping items")
////            return
////        }
////    }
////
////    func createUser(username: String, salt: String, hashedPassword: String, email: String) throws -> User? {
////        do {
////            let user = try dbQueue.write{ (db: Database) -> User in
////
////                try db.execute(
////                    sql:
////                    """
////                    INSERT INTO \(User.Table.databaseTableName) (\(User.Table.username), \(User.Table.salt), \(User.Table.hashedPassword), \(User.Table.email)) \
////                    VALUES (?, ?, ?, ?)
////                    """,
////                    arguments: [username, salt, hashedPassword, email])
////
////                let userId = db.lastInsertedRowID
////
////                return User(id: Int(userId), username: username, salt: salt, hashedPassword: hashedPassword, email: email)
////            }
////
////            return user
////        } catch {
////            print("Error creating user")
////            if error.localizedDescription.contains("UNIQUE constraint failed: User.Email") {
////                throw CreateUserError.emailTaken
////            }
////            if error.localizedDescription.contains("UNIQUE constraint failed: User.Username") {
////                throw CreateUserError.usernameTaken
////            }
////            return nil
////        }
////    }
////
////    func createAuth(withUserId userId: Int, authToken: String, timestamp: String) -> Auth? {
////        do {
////            let auth = try dbQueue.write{ (db: Database) -> Auth in
////
////                try db.execute(
////                    sql:
////                    """
////                    INSERT INTO \(Auth.Table.databaseTableName) (\(Auth.Table.userId), \(Auth.Table.authToken), \(Auth.Table.timestamp)) \
////                    VALUES (?, ?, ?)
////                    """,
////                    arguments: [userId, authToken, timestamp])
////
////                let authId = db.lastInsertedRowID
////
////                return Auth(id: Int(authId), userId: userId, authToken: authToken, timestamp: timestamp)
////            }
////
////            return auth
////        } catch {
////            print("Error creating auth")
////            return nil
////        }
////    }
//    
//    //MARK: - Read
//    
//    func getRecipe(byId id: Int) -> Recipe? {
//        
//    }
//    
////    func getIngredients(forRecipe recipe: Recipe, withId recipeId: Int) -> Recipe? {
////        var updatedRecipe = recipe
////        do {
////            let updatedRecipe = try dbQueue.read { db -> Recipe in
////                let rows = try Row.fetchCursor(db,
////                                               sql: """
////                                                    select * from \(Ingredient.Table.databaseTableName) \
////                                                    where \(Ingredient.Table.recipeId) = ?
////                                                    """,
////                                               arguments: [recipeId])
////                while let row = try rows.next() {
////                    updatedRecipe.addIngredient(row: row)
////                }
////                return updatedRecipe
////            }
////            return updatedRecipe
////        } catch {
////            return nil
////        }
////    }
////
////    func getDirections(forRecipe recipe: Recipe, withId recipeId: Int) -> Recipe? {
////        var updatedRecipe = recipe
////        do {
////            let updatedRecipe = try dbQueue.read { db -> Recipe in
////                let rows = try Row.fetchCursor(db,
////                                               sql: """
////                                                    select * from \(Direction.Table.databaseTableName) \
////                                                    where \(Direction.Table.recipeId) = ?
////                                                    """,
////                                               arguments: [recipeId])
////                while let row = try rows.next() {
////                    updatedRecipe.addDirection(row: row)
////                }
////                return updatedRecipe
////            }
////            return updatedRecipe
////        } catch {
////            return nil
////        }
////    }
////
////    func getImages(forRecipe recipe: Recipe, withRecipeId recipeId: Int) -> Recipe? {
////        var updatedRecipe = recipe
////        do {
////            let updatedRecipe = try dbQueue.read { db -> Recipe in
////                let rows = try Row.fetchCursor(db,
////                                               sql: """
////                                                    select * from \(RecipeImage.Table.databaseTableName) \
////                                                    where \(RecipeImage.Table.recipeId) = ?
////                                                    """,
////                                               arguments: [recipeId])
////                while let row = try rows.next() {
////                    updatedRecipe.addImage(row: row)
////                }
////                return updatedRecipe
////            }
////            return updatedRecipe
////        } catch {
////            return nil
////        }
////    }
////
////    func getImage(withCategoryId categoryId: Int) -> RecipeImage? {
////        do {
////            let image = try dbQueue.inDatabase { (db: Database) -> RecipeImage? in
////                let row = try Row.fetchOne(db,
////                                           sql: """
////                                                select * from \(RecipeImage.Table.databaseTableName) \
////                                                where \(RecipeImage.Table.categoryId) = ?
////                                                """,
////                                           arguments: [categoryId])
////                if let returnedRow = row {
////                    return RecipeImage(row: returnedRow)
////                }
////                return nil
////            }
////
////            return image
////
////        } catch {
////            return nil
////        }
////    }
////
////    func getAllRecipes(withCollectionId collectionId: Int) -> [Recipe] {
////        var allRecipes = [Recipe]()
////        do {
////            let allRecipes = try dbQueue.read { db -> [Recipe] in
////                let rows = try Row.fetchCursor(db,
////                                               sql: """
////                                                    SELECT DISTINCT \(Recipe.Table.databaseTableName).\(Recipe.Table.id), \(Recipe.Table.databaseTableName).\(Recipe.Table.name), \(Recipe.Table.databaseTableName).\(Recipe.Table.servings),
////                                                    \(Recipe.Table.databaseTableName).\(Recipe.Table.source), \(Recipe.Table.databaseTableName).\(Recipe.Table.recipeCategoryId) FROM \(Recipe.Table.databaseTableName) \
////                                                    INNER JOIN \(RecipeCategory.Table.databaseTableName) \
////                                                    ON \(RecipeCategory.Table.databaseTableName).\(RecipeCategory.Table.id) = \(Recipe.Table.databaseTableName).\(Recipe.Table.recipeCategoryId)
////                                                    WHERE \(RecipeCategory.Table.databaseTableName).\(RecipeCategory.Table.recipeCollectionId) = ?
////                                                    """,
////                                               arguments: [collectionId])
////                while let row = try rows.next() {
////                    allRecipes.append(Recipe(row: row))
////                }
////                return allRecipes
////            }
////            return allRecipes
////        } catch {
////            return []
////        }
////    }
////
////    func getRecipes(byCategoryId categoryId: Int) -> [Recipe] {
////        var categoryRecipes = [Recipe]()
////        do {
////            let categoryRecipes = try dbQueue.read { db -> [Recipe] in
////                let rows = try Row.fetchCursor(db,
////                                               sql: """
////                                                    SELECT * FROM \(Recipe.Table.databaseTableName) \
////                                                    WHERE \(Recipe.Table.recipeCategoryId) = ?
////                                                    """,
////                                               arguments: [categoryId])
////                while let row = try rows.next() {
////                    categoryRecipes.append(Recipe(row: row))
////                }
////                return categoryRecipes
////            }
////            return categoryRecipes
////        } catch {
////            return []
////        }
////    }
////
////    func getCategory(withId id: Int) -> RecipeCategory? {
////        do {
////            let category = try dbQueue.read { db -> RecipeCategory? in
////                let row = try Row.fetchOne(db,
////                                               sql: """
////                                                    select * from \(RecipeCategory.Table.databaseTableName) \
////                                                    where \(RecipeCategory.Table.id) = ?
////                                                    """,
////                                               arguments: [id])
////                if let returnedRow = row {
////                    return RecipeCategory(row: returnedRow)
////                }
////                return nil
////            }
////            return category
////        } catch {
////            return nil
////        }
////    }
////
////    func getCollection(withUsername username: String) -> RecipeCollection? {
////        do {
////            let collection = try dbQueue.read { db -> RecipeCollection? in
////                let row = try Row.fetchOne(db,
////                                               sql: """
////                                                    select * from \(RecipeCollection.Table.databaseTableName) \
////                                                    where \(RecipeCollection.Table.name) = ?
////                                                    """,
////                                               arguments: [username])
////                if let returnedRow = row {
////                    return RecipeCollection(row: returnedRow)
////                }
////                return nil
////            }
////            return collection
////        } catch {
////            return nil
////        }
////    }
////
////    func getCategories(byCollectionId collectionId: Int) -> [RecipeCategory] {
////        var categories = [RecipeCategory]()
////        do {
////            let categories = try dbQueue.read { db -> [RecipeCategory] in
////                let rows = try Row.fetchCursor(db,
////                                               sql: """
////                                                    select * from \(RecipeCategory.Table.databaseTableName) \
////                                                    where \(RecipeCategory.Table.recipeCollectionId) = ?
////                                                    """,
////                                               arguments: [collectionId])
////                while let row = try rows.next() {
////                    categories.append(RecipeCategory(row: row))
////                }
////                return categories
////            }
////            return categories
////        } catch {
////            return []
////        }
////    }
////
////    func getShoppingItems(byCollectionId collectionId: Int) -> [ShoppingItem] {
////        var items = [ShoppingItem]()
////        do {
////            let items = try dbQueue.read { db -> [ShoppingItem] in
////                let rows = try Row.fetchCursor(db,
////                                               sql: """
////                                                    select * from \(ShoppingItem.Table.databaseTableName) \
////                                                    where \(ShoppingItem.Table.collectionId) = ?
////                                                    """,
////                                               arguments: [collectionId])
////                while let row = try rows.next() {
////                    items.append(ShoppingItem(row: row))
////                }
////                return items
////            }
////            return items
////        } catch {
////            return []
////        }
////    }
////
////    func getUser(withUsername username: String) -> User? {
////        do {
////            let user = try dbQueue.inDatabase { (db: Database) -> User? in
////                let row = try Row.fetchOne(db,
////                                           sql: """
////                                                select * from \(User.Table.databaseTableName) \
////                                                where \(User.Table.username) = ?
////                                                """,
////                                           arguments: [username])
////                if let returnedRow = row {
////                    return User(row: returnedRow)
////                }
////                return nil
////            }
////
////            return user
////
////        } catch {
////            return nil
////        }
////    }
////
////    func getAuth(withUserId userId: Int) -> Auth? {
////        do {
////            let auth = try dbQueue.inDatabase { (db: Database) -> Auth? in
////                let row = try Row.fetchOne(db,
////                                           sql: """
////                                                select * from \(Auth.Table.databaseTableName) \
////                                                where \(Auth.Table.userId) = ?
////                                                """,
////                                           arguments: [userId])
////                if let returnedRow = row {
////                    return Auth(row: returnedRow)
////                }
////                return nil
////            }
////
////            return auth
////
////        } catch {
////            return nil
////        }
////    }
//    
//    // MARK: - Update
//    
//    func updateRecipe(withId id: Int, name: String, servings: Int, source: String, recipeCategoryId: Int) -> Bool {
//        
//    }
//    
////    func updateDirection(_ direction: Direction) throws {
////        try dbQueue.write{ (db: Database) in
////            try db.execute(
////                sql:
////                """
////                UPDATE \(Direction.Table.databaseTableName) \
////                SET \(Direction.Table.step) = ?, \
////                \(Direction.Table.direction) = ?, \
////                \(Direction.Table.recipeId) = ? \
////                WHERE \(Direction.Table.id) = ?
////                """,
////                arguments: [direction.step, direction.direction, direction.recipeId, direction.id])
////            return
////        }
////    }
////
////    func updateDirections(withRecipeId recipeId: Int, directions: [Direction]) -> Bool {
////        do {
////            for direction in directions {
////                try updateDirection(direction)
////            }
////
////            return true
////        } catch {
////            print("Error updating directions")
////            return false
////        }
////    }
////
////    func updateIngredient(_ ingredient: Ingredient, withRecipeId recipeId: Int) throws {
////        try dbQueue.write{ (db: Database) in
////            try db.execute(
////                sql:
////                """
////                UPDATE \(Ingredient.Table.databaseTableName) \
////                SET \(Ingredient.Table.name) = ?, \
////                \(Ingredient.Table.amount) = ?, \
////                \(Ingredient.Table.unitName) = ?, \
////                \(Ingredient.Table.recipeId) = ? \
////                WHERE \(Ingredient.Table.id) = ?
////                """,
////                arguments: [ingredient.name, ingredient.amount, ingredient.unitName.getName(), recipeId, ingredient.id])
////            return
////        }
////    }
////
////    func updateIngredients(withRecipeId recipeId: Int, ingredients: [Ingredient]) -> Bool {
////        do {
////            for ingredient in ingredients {
////                try updateIngredient(ingredient, withRecipeId: recipeId)
////            }
////
////            return true
////        } catch {
////            print("Error updating ingredients")
////            return false
////        }
////    }
////
////    func updateImage(_ image: RecipeImage, withRecipeId recipeId: Int) throws {
////        try dbQueue.write{ (db: Database) in
////            try db.execute(
////                sql:
////                """
////                UPDATE \(RecipeImage.Table.databaseTableName) \
////                SET \(RecipeImage.Table.type) = ?, \
////                \(RecipeImage.Table.data) = ? \
////                WHERE \(RecipeImage.Table.recipeId) = ?
////                """,
////                arguments: [image.type.rawValue, image.data, recipeId])
////            return
////        }
////    }
////
////    func updateImages(withRecipeId recipeId: Int, images: [RecipeImage]) -> Bool {
////        do {
////            for image in images {
////                try updateImage(image, withRecipeId: recipeId)
////            }
////
////            return true
////        } catch {
////            print("Error updating images")
////            return false
////        }
////    }
////
////    func updateCategory(withId id: Int, name: String, recipeCollectionId: Int) {
////        do {
////            try dbQueue.write{ (db: Database) in
////
////                try db.execute(
////                    sql:
////                    """
////                    UPDATE \(RecipeCategory.Table.databaseTableName) \
////                    SET \(RecipeCategory.Table.name) = ?, \
////                    \(RecipeCategory.Table.recipeCollectionId) = ? \
////                    WHERE \(RecipeCategory.Table.id) = ?
////                    """,
////                    arguments: [name, recipeCollectionId, id])
////
////                return
////            }
////
////            return
////        } catch {
////            print("Error updating category")
////            return
////        }
////    }
////
////    func updateCollection(withId id: Int, name: String) {
////        do {
////            try dbQueue.write{ (db: Database) in
////
////                try db.execute(
////                    sql:
////                    """
////                    UPDATE \(RecipeCollection.Table.databaseTableName) \
////                    SET \(RecipeCollection.Table.name) = ? \
////                    WHERE \(RecipeCollection.Table.id) = ?
////                    """,
////                    arguments: [name, id])
////
////                return
////            }
////            return
////        } catch {
////            print("Error updating collection")
////            return
////        }
////    }
////
////    func updateAuth(withId id: Int, userId: Int, authToken: String, timestamp: String) -> Auth? {
////        do {
////            let auth = try dbQueue.write{ (db: Database) -> Auth in
////
////                try db.execute(
////                    sql:
////                    """
////                    UPDATE \(Auth.Table.databaseTableName) \
////                    SET \(Auth.Table.userId) = ?, \
////                    \(Auth.Table.authToken) = ?, \
////                    \(Auth.Table.timestamp) = ? \
////                    WHERE \(Auth.Table.id) = ?
////                    """,
////                    arguments: [userId, authToken, timestamp, id])
////
////                return Auth(id: id, userId: userId, authToken: authToken, timestamp: timestamp)
////            }
////
////            return auth
////        } catch {
////            print("Error updating recipe")
////            return nil
////        }
////    }
////
////    func updateUser(withId id: Int, username: String, salt: String, hashedPassword: String, email: String) -> Bool {
////        do {
////            let success = try dbQueue.write{ (db: Database) -> Bool in
////                try db.execute(
////                    sql:
////                    """
////                    UPDATE \(User.Table.databaseTableName) \
////                    SET \(User.Table.hashedPassword) = ?,
////                    \(User.Table.salt) = ?, \
////                    \(User.Table.email) = ?, \
////                    \(User.Table.username) = ? \
////                    WHERE \(User.Table.id) = ?
////                    """,
////                    arguments: [hashedPassword, salt, email, username, id])
////
////                return true
////            }
////
////            return success
////        } catch {
////            print("Error updating user")
////            return false
////        }
////    }
//    
//    // MARK: - Delete
//    
//    func deleteRecipe(withId id: Int) {
//        
//    }
//    
////    func deleteDirections(withRecipeId recipeId: Int) {
////        do {
////            try dbQueue.write{ (db: Database) in
////
////                try db.execute(
////                    sql:
////                    """
////                    DELETE FROM \(Direction.Table.databaseTableName) \
////                    WHERE \(Direction.Table.recipeId) = ?
////                    """,
////                    arguments: [recipeId])
////
////                return
////            }
////            return
////        } catch {
////            print("Error deleting directions")
////            return
////        }
////    }
////
////    func deleteIngredients(withRecipeId recipeId: Int) {
////        do {
////            try dbQueue.write{ (db: Database) in
////
////                try db.execute(
////                    sql:
////                    """
////                    DELETE FROM \(Ingredient.Table.databaseTableName) \
////                    WHERE \(Ingredient.Table.recipeId) = ?
////                    """,
////                    arguments: [recipeId])
////
////                return
////            }
////            return
////        } catch {
////            print("Error deleting ingredients")
////            return
////        }
////    }
////
////    func deleteImages(withRecipeId recipeId: Int) {
////        do {
////            try dbQueue.write{ (db: Database) in
////
////                try db.execute(
////                    sql:
////                    """
////                    DELETE FROM \(RecipeImage.Table.databaseTableName) \
////                    WHERE \(RecipeImage.Table.recipeId) = ?
////                    """,
////                    arguments: [recipeId])
////
////                return
////            }
////            return
////        } catch {
////            print("Error deleting images")
////            return
////        }
////    }
////
////    func deleteImage(withId id: Int) {
////        do {
////            try dbQueue.write{ (db: Database) in
////
////                try db.execute(
////                    sql:
////                    """
////                    DELETE FROM \(RecipeImage.Table.databaseTableName) \
////                    WHERE \(RecipeImage.Table.id) = ?
////                    """,
////                    arguments: [id])
////
////                return
////            }
////            return
////        } catch {
////            print("Error deleting image")
////            return
////        }
////    }
////
////    func deleteImage(withCategoryId categoryId: Int) {
////        do {
////            try dbQueue.write{ (db: Database) in
////
////                try db.execute(
////                    sql:
////                    """
////                    DELETE FROM \(RecipeImage.Table.databaseTableName) \
////                    WHERE \(RecipeImage.Table.categoryId) = ?
////                    """,
////                    arguments: [categoryId])
////
////                return
////            }
////            return
////        } catch {
////            print("Error deleting image")
////            return
////        }
////    }
////
////    func deleteCategory(withId id: Int) {
////        do {
////            try dbQueue.write{ (db: Database) in
////
////                try db.execute(
////                    sql:
////                    """
////                    DELETE FROM \(RecipeCategory.Table.databaseTableName) \
////                    WHERE \(RecipeCategory.Table.id) = ?
////                    """,
////                    arguments: [id])
////
////                return
////            }
////            return
////        } catch {
////            print("Error deleting category")
////            return
////        }
////    }
////
////    func deleteRecipes(withCategoryId categoryId: Int) {
////        do {
////            try dbQueue.write{ (db: Database) in
////
////                try db.execute(
////                    sql:
////                    """
////                    DELETE FROM \(Recipe.Table.databaseTableName) \
////                    WHERE \(Recipe.Table.recipeCategoryId) = ?
////                    """,
////                    arguments: [categoryId])
////
////                return
////            }
////            return
////        } catch {
////            print("Error deleting recipes in category")
////            return
////        }
////    }
////
////    func deleteShoppingItem(withId id: Int) {
////        do {
////            try dbQueue.write{ (db: Database) in
////
////                try db.execute(
////                    sql:
////                    """
////                    DELETE FROM \(ShoppingItem.Table.databaseTableName) \
////                    WHERE \(ShoppingItem.Table.id) = ?
////                    """,
////                    arguments: [id])
////
////                return
////            }
////            return
////        } catch {
////            print("Error deleting shopping item")
////            return
////        }
////    }
////
////    func deleteShoppingItems(withCollectionId collectionId: Int) {
////        do {
////            try dbQueue.write{ (db: Database) in
////
////                try db.execute(
////                    sql:
////                    """
////                    DELETE FROM \(ShoppingItem.Table.databaseTableName) \
////                    WHERE \(ShoppingItem.Table.collectionId) = ?
////                    """,
////                    arguments: [collectionId])
////
////                return
////            }
////            return
////        } catch {
////            print("Error deleting shopping items in collection")
////            return
////        }
////    }
////
////    func deleteUser(withId id: Int) {
////        do {
////            try dbQueue.write{ (db: Database) in
////
////                try db.execute(
////                    sql:
////                    """
////                    DELETE FROM \(User.Table.databaseTableName) \
////                    WHERE \(User.Table.id) = ?
////                    """,
////                    arguments: [id])
////
////                return
////            }
////            return
////        } catch {
////            print("Error deleting user")
////            return
////        }
////    }
////
////    func deleteAuth(withUserId userId: Int) {
////        do {
////            try dbQueue.write{ (db: Database) in
////
////                try db.execute(
////                    sql:
////                    """
////                    DELETE FROM \(Auth.Table.databaseTableName) \
////                    WHERE \(Auth.Table.userId) = ?
////                    """,
////                    arguments: [userId])
////
////                return
////            }
////            return
////        } catch {
////            print("Error deleting auth")
////            return
////        }
////    }
//}
////
////enum CreateUserError: Error {
////    case usernameTaken
////    case emailTaken
////}