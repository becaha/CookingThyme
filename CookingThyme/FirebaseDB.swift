//
//  FirebaseDB.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/5/21.
//

import Foundation
import Firebase

import FirebaseUI

// https://benmcmahen.com/authentication-with-swiftui-and-firebase/

class FirebaseDB {
////    var db: type

    // MARK: - Singleton

    static let shared = FirebaseDB()
    static let auth = FUIAuth.defaultAuthUI()
    
    private init() {

//        FirebaseApp.configure()
//        
//        db = Firestore.firestore()
        
        FirebaseApp.configure()
//        let authUI = FUIAuth.defaultAuthUI()
//        // You need to adopt a FUIAuthDelegate protocol to receive callback
//        authUI.delegate = self
//
//        let providers: [FUIAuthProvider] = [
//          FUIGoogleAuth(),
//          FUIFacebookAuth(),
//          FUITwitterAuth(),
//          FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()),
//        ]
//        self.authUI.providers = providers
//
//        let authViewController = authUI.authViewController()
//
//        func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
//          // handle user and error as necessary
//        }

    }
    
    // MARK: - Create
    
//    func createRecipe(name: String, servings: Int, source: String, recipeCategoryId: Int) -> Recipe? {
//        var ref: DocumentReference? = nil
//        ref = db.collection(Recipe.Table.databaseTableName).addDocument(data: [
//            Recipe.Table.name: name,
//            Recipe.Table.servings: servings,
//            Recipe.Table.source: source,
//            Recipe.Table.recipeCategoryId: recipeCategoryId
//        ]) { err in
//            if let err = err {
//                print("Error adding recipe: \(err)")
//                return nil
//            } else {
//                print("Recipe added with ID: \(ref!.documentID)")
//                return Recipe(id: Int(recipeId), name: name, servings: servings, source: source, recipeCategoryId: recipeCategoryId)
//            }
//        }
//    }
//    
//    func createDirection(_ direction: Direction, withRecipeId recipeId: Int) throws {
//        var ref: DocumentReference? = nil
//        ref = db.collection(Recipe.Table.databaseTableName).addDocument(data: [
//            Direction.Table.step: direction.step,
//            Direction.Table.direction: direction.direction,
//            Direction.Table.recipeId: recipeId
//        ]) { err in
//            if let err = err {
//                print("Error adding direction: \(err)")
//            } else {
//                print("Direction added with ID: \(ref!.documentID)")
//            }
//        }
//    }
//    
//    func createDirections(directions: [Direction], withRecipeId recipeId: Int) {
//        do {
//            for direction in directions {
//                try createDirection(direction, withRecipeId: recipeId)
//            }
//            
//            return
//        } catch {
//            print("Error creating directions")
//            return
//        }
//    }
//    
//    func createIngredient(_ ingredient: Ingredient, withRecipeId recipeId: Int) throws {
//        var ref: DocumentReference? = nil
//        ref = db.collection(Ingredient.Table.databaseTableName).addDocument(data: [
//            Ingredient.Table.name: ingredient.name,
//            Ingredient.Table.amount: ingredient.amount,
//            Ingredient.Table.unitName: ingredient.unitName.getName(),
//            Ingredient.Table.recipeId: recipeId
//        ]) { err in
//            if let err = err {
//                print("Error adding ingredient: \(err)")
//            } else {
//                print("Ingredient added with ID: \(ref!.documentID)")
//            }
//        }
//    }
//    
//    func createIngredients(ingredients: [Ingredient], withRecipeId recipeId: Int) {
//        do {
//            for ingredient in ingredients {
//                try createIngredient(ingredient, withRecipeId: recipeId)
//            }
//
//            return
//        } catch {
//            print("Error creating ingredients")
//            return
//        }
//    }
//    
//    func createImage(_ image: RecipeImage, withRecipeId recipeId: Int) throws {
//        var ref: DocumentReference? = nil
//        ref = db.collection(RecipeImage.Table.databaseTableName).addDocument(data: [
//            RecipeImage.Table.type: image.type.rawValue,
//            RecipeImage.Table.data: image.data,
//            RecipeImage.Table.recipeId: recipeId
//        ]) { err in
//            if let err = err {
//                print("Error adding image: \(err)")
//            } else {
//                print("Image added with ID: \(ref!.documentID)")
//            }
//        }
//    }
//    
//    func createImages(images: [RecipeImage], withRecipeId recipeId: Int) {
//        do {
//            for image in images {
//                try createImage(image, withRecipeId: recipeId)
//            }
//            return
//        } catch {
//            print("Error creating images")
//            return
//        }
//    }
//    
//    func createImage(_ image: RecipeImage, withCategoryId categoryId: Int) {
//        var ref: DocumentReference? = nil
//        ref = db.collection(RecipeImage.Table.databaseTableName).addDocument(data: [
//            RecipeImage.Table.type: image.type.rawValue,
//            RecipeImage.Table.data: image.data,
//            RecipeImage.Table.categoryId: categoryId
//        ]) { err in
//            if let err = err {
//                print("Error adding image: \(err)")
//            } else {
//                print("Image added with ID: \(ref!.documentID)")
//            }
//        }
//    }
//    
//    func createCategory(withName name: String, forCollectionId collectionId: Int) {
//        var ref: DocumentReference? = nil
//        ref = db.collection(RecipeCategory.Table.databaseTableName).addDocument(data: [
//            RecipeCategory.Table.name: name,
//            RecipeCategory.Table.recipeCollectionId: collectionId
//        ]) { err in
//            if let err = err {
//                print("Error adding category: \(err)")
//            } else {
//                print("Category added with ID: \(ref!.documentID)")
//            }
//        }
//    }
//    
//    func createCollection(withUsername username: String) -> RecipeCollection? {
//        var ref: DocumentReference? = nil
//        ref = db.collection(RecipeCollection.Table.databaseTableName).addDocument(data: [
//            RecipeCollection.Table.name: username
//        ]) { err in
//            if let err = err {
//                print("Error adding collection: \(err)")
//            } else {
//                print("Collection added with ID: \(ref!.documentID)")
//            }
//        }
//    }
//    
//    func createShoppingItem(_ item: ShoppingItem, withCollectionId collectionId: Int) throws {
//        var ref: DocumentReference? = nil
//        ref = db.collection(ShoppingItem.Table.databaseTableName).addDocument(data: [
//            ShoppingItem.Table.name: item.name,
//            ShoppingItem.Table.amount: item.amount,
//            ShoppingItem.Table.unitName: item.unitName.getName(),
//            ShoppingItem.Table.completed: item.completed.toInt(),
//            ShoppingItem.Table.collectionId: collectionId
//        ]) { err in
//            if let err = err {
//                print("Error adding shopping item: \(err)")
//            } else {
//                print("Shopping item added with ID: \(ref!.documentID)")
//            }
//        }
//    }
//    
//    func createShoppingItems(items: [ShoppingItem], withCollectionId collectionId: Int) {
//        do {
//            for item in items {
//                try createShoppingItem(item, withCollectionId: collectionId)
//            }
//
//            return
//        } catch {
//            print("Error creating shopping items")
//            return
//        }
//    }
//    
//    func createUser(username: String, salt: String, hashedPassword: String, email: String) throws -> User? {
//        var ref: DocumentReference? = nil
//        ref = db.collection(User.Table.databaseTableName).addDocument(data: [
//            User.Table.username: username,
//            User.Table.salt: salt,
//            User.Table.hashedPassword: hashedPassword,
//            User.Table.email: email
//        ]) { err in
//            if let err = err {
//                print("Error creating user")
//                if error.localizedDescription.contains("UNIQUE constraint failed: User.Email") {
//                    throw CreateUserError.emailTaken
//                }
//                if error.localizedDescription.contains("UNIQUE constraint failed: User.Username") {
//                    throw CreateUserError.usernameTaken
//                }
//                return nil
//            } else {
//                print("User added with ID: \(ref!.documentID)")
//                return User(id: Int(userId), username: username, salt: salt, hashedPassword: hashedPassword, email: email)
//            }
//        }
//    }
//    
//    func createAuth(withUserId userId: Int, authToken: String, timestamp: String) -> Auth? {
//        var ref: DocumentReference? = nil
//        ref = db.collection(Auth.Table.databaseTableName).addDocument(data: [
//            Auth.Table.userId: userId,
//            Auth.Table.authToken: authToken,
//            Auth.Table.timestamp: timestamp
//        ]) { err in
//            if let err = err {
//                print("Error adding auth: \(err)")
//                return nil
//            } else {
//                print("Auth added with ID: \(ref!.documentID)")
////                return Auth(id: Int(authId), userId: userId, authToken: authToken, timestamp: timestamp)
//            }
//        }
//    }
//    
//    // MARK: - Read
//    
//    func getRecipe(byId id: Int) -> Recipe? {
//        db.collection(Recipe.Table.databaseTableName).whereField(Recipe.Table.id, isEqualTo: id).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting recipe: \(err)")
//                return nil
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    return Recipe(document: document)
//                }
//            }
//        }
//    }
//    
//    func getIngredients(forRecipe recipe: Recipe, withId recipeId: Int) -> Recipe? {
//        var updatedRecipe = recipe
//        db.collection(Ingredient.Table.databaseTableName).whereField(Ingredient.Table.recipeId, isEqualTo: recipeId).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting ingredients: \(err)")
//                return nil
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    updatedRecipe.addIngredient(row: row)
//                }
//                return updatedRecipe
//            }
//        }
//    }
//    
//    func getDirections(forRecipe recipe: Recipe, withId recipeId: Int) -> Recipe? {
//        var updatedRecipe = recipe
//        db.collection(Direction.Table.databaseTableName).whereField(Direction.Table.recipeId, isEqualTo: recipeId).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting directions: \(err)")
//                return nil
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    updatedRecipe.addDirection(row: row)
//                }
//                return updatedRecipe
//            }
//        }
//    }
//    
//    func getImages(forRecipe recipe: Recipe, withRecipeId recipeId: Int) -> Recipe? {
//        var updatedRecipe = recipe
//        db.collection(RecipeImage.Table.databaseTableName).whereField(RecipeImage.Table.recipeId, isEqualTo: recipeId).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting images: \(err)")
//                return nil
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    updatedRecipe.addImage(row: row)
//                }
//                return updatedRecipe
//            }
//        }
//    }
//    
//    func getImage(withCategoryId categoryId: Int) -> RecipeImage? {
//        db.collection(RecipeImage.Table.databaseTableName).whereField(RecipeImage.Table.categoryId, isEqualTo: categoryId).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting image: \(err)")
//                return nil
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    return RecipeImage(row: returnedRow)
//                }
//            }
//        }
//    }
//    
//    func getAllRecipes(withCollectionId collectionId: Int) -> [Recipe] {
//        db.collection(RecipeCategory.Table.databaseTableName).whereField(RecipeCategory.Table.recipeCollectionId, isEqualTo: collectionId).getDocuments() { querySnapshot, err in
//            if let err = err {
//                print("Error getting categories: \(err)")
//            }
//            else {
//                var recipes = [Recipe]()
//                for document in querySnapshot!.documents {
//                    let category = document
//                    db.collection(Recipe.Table.databaseTableName).whereField(Recipe.Table.recipeCategoryId, isEqualTo: category.id).getDocuments() { querySnapshot, err in
//                        if let err = err {
//                            print("Error getting recipes: \(err)")
//                        }
//                        else {
//                            let categoryRecipes = querySnapshot!.documents
//                            recipes.append(contentsOf: categoryRecipes)
//                        }
//                    }
//                }
//                return recipes
//            }
//        }
//    }
//    
//    func getRecipes(byCategoryId categoryId: Int) -> [Recipe] {
//        var recipes = [Recipe]()
//        db.collection(Recipe.Table.databaseTableName).whereField(Recipe.Table.recipeCategoryId, isEqualTo: categoryId)
//            .getDocuments() { (querySnapshot, err) in
//                if let err = err {
//                    print("Error getting recipes: \(err)")
//                    return []
//                } else {
//                    for document in querySnapshot!.documents {
//                        print("\(document.documentID) => \(document.data())")
//                        recipes.append(Recipe(row: returnedRow))
//                    }
//                    return recipes
//                }
//        }
//    }
//    
//    func getCategory(withId id: Int) -> RecipeCategory? {
//        db.collection(RecipeCategory.Table.databaseTableName).whereField(RecipeCategory.Table.id, isEqualTo: id).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting category: \(err)")
//                return nil
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    return RecipeCategory(row: returnedRow)
//                }
//            }
//        }
//    }
//    
//    func getCollection(withUsername username: String) -> RecipeCollection? {
//        db.collection(RecipeCollection.Table.databaseTableName).whereField(RecipeCollection.Table.name, isEqualTo: username).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting collection: \(err)")
//                return nil
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    return RecipeCollection(row: returnedRow)
//                }
//            }
//        }
//    }
//    
//    func getCategories(byCollectionId collectionId: Int) -> [RecipeCategory] {
//        var categories = [RecipeCategory]()
//        db.collection(RecipeCategory.Table.databaseTableName).whereField(RecipeCategory.Table.recipeCollectionId, isEqualTo: collectionId).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting categories: \(err)")
//                return []
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    categories.append(RecipeCategory(row: returnedRow))
//                }
//                return categories
//            }
//        }
//    }
//    
//    func getShoppingItems(byCollectionId collectionId: Int) -> [ShoppingItem] {
//        var items = [ShoppingItem]()
//        db.collection(ShoppingItem.Table.databaseTableName).whereField(ShoppingItem.Table.collectionId, isEqualTo: collectionId).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting shopping items: \(err)")
//                return []
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    items.append(ShoppingItem(row: returnedRow))
//                }
//                return items
//            }
//        }
//    }
//    
//    func getUser(withUsername username: String) -> User? {
//        db.collection(User.Table.databaseTableName).whereField(User.Table.username, isEqualTo: username).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting user: \(err)")
//                return nil
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    return User(row: row)
//                }
//            }
//        }
//    }
//    
//    func getAuth(withUserId userId: Int) -> Auth? {
//        db.collection(Auth.Table.databaseTableName).whereField(Auth.Table.userId, isEqualTo: userId).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting auth: \(err)")
//                return nil
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    return Auth(row: row)
//                }
//            }
//        }
//    }
//    
//    // MARK: - Update
//    
//    func updateRecipe(withId id: Int, name: String, servings: Int, source: String, recipeCategoryId: Int) -> Bool {
//        let ref = db.collection(Recipe.Table.databaseTableName).document(id)
//
//        ref.updateData([
//            Recipe.Table.name: name,
//            Recipe.Table.servings: servings,
//            Recipe.Table.source: source,
//            Recipe.Table.recipeCategoryId: recipeCategoryId
//        ]) { err in
//            if let err = err {
//                print("Error updating recipe: \(err)")
//                return false
//            } else {
//                print("Recipe successfully updated")
//                return true
//            }
//        }
//    }
//    
//    // changed this to having with recipe id insteaad of getting the recipe id from the direction
//    func updateDirection(_ direction: Direction, withRecipeId recipeId: Int) throws {
//        let ref = db.collection(Direction.Table.databaseTableName).document(direction.id)
//
//        ref.updateData([
//            Direction.Table.step: direction.step,
//            Direction.Table.direction: direction.direction,
//            Direction.Table.recipeId: recipeId
//        ]) { err in
//            if let err = err {
//                print("Error updating direction: \(err)")
//                return false
//            } else {
//                print("Direction successfully updated")
//                return true
//            }
//        }
//    }
//    
//    func updateDirections(withRecipeId recipeId: Int, directions: [Direction]) -> Bool {
//        do {
//            for direction in directions {
//                try updateDirection(direction, withRecipeId: recipeId)
//            }
//            
//            return true
//        } catch {
//            print("Error updating directions")
//            return false
//        }
//    }
//    
//    func updateIngredient(_ ingredient: Ingredient, withRecipeId recipeId: Int) throws {
//        let ref = db.collection(Ingredient.Table.databaseTableName).document(ingredient.id)
//
//        ref.updateData([
//            Ingredient.Table.name: ingredient.name,
//            Ingredient.Table.amount: ingredient.amount,
//            Ingredient.Table.unitName: ingredient.unitName.getName(),
//            Ingredient.Table.recipeId: recipeId
//        ]) { err in
//            if let err = err {
//                print("Error updating ingredient: \(err)")
//                return false
//            } else {
//                print("Ingredient successfully updated")
//                return true
//            }
//        }
//    }
//    
//    func updateIngredients(withRecipeId recipeId: Int, ingredients: [Ingredient]) -> Bool {
//        do {
//            for ingredient in ingredients {
//                try updateIngredient(ingredient, withRecipeId: recipeId)
//            }
//
//            return true
//        } catch {
//            print("Error updating ingredients")
//            return false
//        }
//    }
//    
//    func updateImage(_ image: RecipeImage, withRecipeId recipeId: Int) throws {
//        let ref = db.collection(RecipeImage.Table.databaseTableName).document(image.id)
//
//        ref.updateData([
//            RecipeImage.Table.type: image.type.rawValue,
//            RecipeImage.Table.data: image.data,
//            RecipeImage.Table.recipeId: recipeId
//        ]) { err in
//            if let err = err {
//                print("Error updating image: \(err)")
//                return false
//            } else {
//                print("Image successfully updated")
//                return true
//            }
//        }
//    }
//    
//    func updateImages(withRecipeId recipeId: Int, images: [RecipeImage]) -> Bool {
//        do {
//            for image in images {
//                try updateImage(image, withRecipeId: recipeId)
//            }
//
//            return true
//        } catch {
//            print("Error updating images")
//            return false
//        }
//    }
//    
//    func updateCategory(withId id: Int, name: String, recipeCollectionId: Int) -> Bool {
//        let ref = db.collection(RecipeCategory.Table.databaseTableName).document(id)
//
//        ref.updateData([
//            RecipeCategory.Table.name: name,
//            RecipeCategory.Table.recipeCollectionId: recipeCollectionId
//        ]) { err in
//            if let err = err {
//                print("Error updating category: \(err)")
//                return false
//            } else {
//                print("Category successfully updated")
//                return true
//            }
//        }
//    }
//    
//    func updateCollection(withId id: Int, name: String) {
//        let ref = db.collection(RecipeCollection.Table.databaseTableName).document(id)
//
//        ref.updateData([
//            RecipeCollection.Table.name: name
//        ]) { err in
//            if let err = err {
//                print("Error updating collection: \(err)")
//                return false
//            } else {
//                print("Collection successfully updated")
//                return true
//            }
//        }
//    }
//    
//    // return bool?
//    func updateAuth(withId id: Int, userId: Int, authToken: String, timestamp: String) -> Auth? {
//        let ref = db.collection(Auth.Table.databaseTableName).document(id)
//
//        ref.updateData([
//            Auth.Table.userId: userId,
//            Auth.Table.authToken: authToken,
//            Auth.Table.timestamp: timestamp
//        ]) { err in
//            if let err = err {
//                print("Error updating auth: \(err)")
//                return false
//            } else {
//                print("Auth successfully updated")
//                return true
//            }
//        }
//    }
//    
//    func updateUser(withId id: Int, username: String, salt: String, hashedPassword: String, email: String) -> Bool {
//        let ref = db.collection(User.Table.databaseTableName).document(id)
//
//        ref.updateData([
//            User.Table.hashedPassword: hashedPassword,
//            User.Table.salt: salt,
//            User.Table.email: email,
//            User.Table.username: username
//        ]) { err in
//            if let err = err {
//                print("Error updating user: \(err)")
//                return false
//            } else {
//                print("User successfully updated")
//                return true
//            }
//        }
//    }
//    
//    // MARK: - Delete
//    
//    func deleteRecipe(withId id: Int) {
//        db.collection(Recipe.Table.databaseTableName).document(id).delete() { err in
//            if let err = err {
//                print("Error removing recipe: \(err)")
//            } else {
//                print("Recipe successfully removed!")
//            }
//        }
//    }
//    
//    func deleteDirections(withRecipeId recipeId: Int) {
//        db.collection(Direction.Table.databaseTableName).whereField(Direction.Table.recipeId, isEqualTo: recipeId).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting directions: \(err)")
//                return nil
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    document.delete() { err in
//                        if let err = err {
//                            print("Error removing direction: \(err)")
//                        } else {
//                            print("Direction successfully removed!")
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    func deleteIngredients(withRecipeId recipeId: Int) {
//        db.collection(Ingredient.Table.databaseTableName).whereField(Ingredient.Table.recipeId, isEqualTo: recipeId).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting ingredients: \(err)")
//                return nil
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    document.delete() { err in
//                        if let err = err {
//                            print("Error removing ingredient: \(err)")
//                        } else {
//                            print("Ingredient successfully removed!")
//                        }
//                    }
//                }
//                return updatedRecipe
//            }
//        }
//    }
//    
//    func deleteImages(withRecipeId recipeId: Int) {
//        db.collection(RecipeImage.Table.databaseTableName).whereField(RecipeImage.Table.recipeId, isEqualTo: recipeId).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting images: \(err)")
//                return nil
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    document.delete() { err in
//                        if let err = err {
//                            print("Error removing image: \(err)")
//                        } else {
//                            print("Image successfully removed!")
//                        }
//                    }
//                }
//                return updatedRecipe
//            }
//        }
//    }
//    
//    func deleteImage(withId id: Int) {
//        db.collection(RecipeImage.Table.databaseTableName).document(id).delete() { err in
//            if let err = err {
//                print("Error removing image: \(err)")
//            } else {
//                print("Image successfully removed!")
//            }
//        }
//    }
//    
//    func deleteImage(withCategoryId categoryId: Int) {
//        db.collection(RecipeImage.Table.databaseTableName).whereField(RecipeImage.Table.categoryId, isEqualTo: categoryId).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting image: \(err)")
//                return nil
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    document.delete() { err in
//                            if let err = err {
//                                print("Error removing image: \(err)")
//                            } else {
//                                print("Image successfully removed!")
//                            }
//                    }
//                }
//            }
//        }
//    }
//    
//    func deleteCategory(withId id: Int) {
//        db.collection(RecipeCategory.Table.databaseTableName).document(id).delete() { err in
//            if let err = err {
//                print("Error removing category: \(err)")
//            } else {
//                print("Category successfully removed!")
//            }
//        }
//    }
//    
//    func deleteRecipes(withCategoryId categoryId: Int) {
//        db.collection(Recipe.Table.databaseTableName).whereField(Recipe.Table.recipeCategoryId, isEqualTo: categoryId)
//            .getDocuments() { (querySnapshot, err) in
//                if let err = err {
//                    print("Error getting recipes: \(err)")
//                } else {
//                    for document in querySnapshot!.documents {
//                        print("\(document.documentID) => \(document.data())")
//                        document.delete() { err in
//                            if let err = err {
//                                print("Error removing category: \(err)")
//                            } else {
//                                print("Category successfully removed!")
//                            }
//                        }
//                    }
//                }
//        }
//    }
//    
//    func deleteShoppingItem(withId id: Int) {
//        db.collection(ShoppingItem.Table.databaseTableName).document(id).delete() { err in
//            if let err = err {
//                print("Error removing shopping item: \(err)")
//            } else {
//                print("Shopping item successfully removed!")
//            }
//        }
//    }
//    
//    func deleteShoppingItems(withCollectionId collectionId: Int) {
//        db.collection(ShoppingItem.Table.databaseTableName).whereField(ShoppingItem.Table.collectionId, isEqualTo: collectionId).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting shopping items: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    document.delete() { err in
//                        if let err = err {
//                            print("Error removing shopping item: \(err)")
//                        } else {
//                            print("Shopping item successfully removed!")
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    func deleteUser(withId id: Int) {
//        db.collection(User.Table.databaseTableName).document(id).delete() { err in
//            if let err = err {
//                print("Error removing user: \(err)")
//            } else {
//                print("User successfully removed!")
//            }
//        }
//    }
//    
//    func deleteAuth(withUserId userId: Int) {
//        db.collection(Auth.Table.databaseTableName).whereField(Auth.Table.userId, isEqualTo: userId).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting auth: \(err)")
//                return nil
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    document.delete() { err in
//                        if let err = err {
//                            print("Error removing auth: \(err)")
//                        } else {
//                            print("Auth successfully removed!")
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//}
//
//enum CreateUserError: Error {
//    case usernameTaken
//    case emailTaken
}
