//
//  FirebaseDB.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/5/21.
//

import Foundation
import Firebase

// https://benmcmahen.com/authentication-with-swiftui-and-firebase/

class RecipeDB {
    var db: Firestore

    // MARK: - Singleton

    static let shared = RecipeDB()
//    static let auth = FUIAuth.defaultAuthUI()
    
    private init() {

        FirebaseApp.configure()
        
        db = Firestore.firestore()
        
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
    
    func createRecipe(name: String, servings: Int, source: String, recipeCategoryId: String, onCompletion: @escaping (Recipe?) -> Void) {
        var ref: DocumentReference? = nil
        ref = db.collection(Recipe.Table.databaseTableName).addDocument(data: [
            Recipe.Table.name: name,
            Recipe.Table.servings: servings,
            Recipe.Table.source: source,
            Recipe.Table.recipeCategoryId: recipeCategoryId
        ]) { err in
            if let err = err {
                print("Error adding recipe: \(err)")
            } else {
                print("Recipe added with ID: \(ref!.documentID)")
            }
        }
        if let ref = ref {
            onCompletion(Recipe(id: ref.documentID, name: name, servings: servings, source: source, recipeCategoryId: recipeCategoryId))
        }
        else {
            onCompletion(nil)
        }
    }
    
    func createDirection(_ direction: Direction, withRecipeId recipeId: String) throws {
        var ref: DocumentReference? = nil
        ref = db.collection(Recipe.Table.databaseTableName).addDocument(data: [
            Direction.Table.step: direction.step,
            Direction.Table.direction: direction.direction,
            Direction.Table.recipeId: recipeId
        ]) { err in
            if let err = err {
                print("Error adding direction: \(err)")
            } else {
                print("Direction added with ID: \(ref!.documentID)")
            }
        }
    }
    
    func createDirections(directions: [Direction], withRecipeId recipeId: String) {
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
    
    func createIngredient(_ ingredient: Ingredient, withRecipeId recipeId: String) throws {
        var ref: DocumentReference? = nil
        ref = db.collection(Ingredient.Table.databaseTableName).addDocument(data: [
            Ingredient.Table.name: ingredient.name,
            Ingredient.Table.amount: ingredient.amount,
            Ingredient.Table.unitName: ingredient.unitName.getName(),
            Ingredient.Table.recipeId: recipeId
        ]) { err in
            if let err = err {
                print("Error adding ingredient: \(err)")
            } else {
                print("Ingredient added with ID: \(ref!.documentID)")
            }
        }
    }
    
    func createIngredients(ingredients: [Ingredient], withRecipeId recipeId: String) {
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
    
    func createImage(_ image: RecipeImage, withRecipeId recipeId: String) throws {
        var ref: DocumentReference? = nil
        ref = db.collection(RecipeImage.Table.databaseTableName).addDocument(data: [
            RecipeImage.Table.type: image.type.rawValue,
            RecipeImage.Table.data: image.data,
            RecipeImage.Table.recipeId: recipeId
        ]) { err in
            if let err = err {
                print("Error adding image: \(err)")
            } else {
                print("Image added with ID: \(ref!.documentID)")
            }
        }
    }
    
    func createImages(images: [RecipeImage], withRecipeId recipeId: String) {
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
    
    func createImage(_ image: RecipeImage, withCategoryId categoryId: String) {
        var ref: DocumentReference? = nil
        ref = db.collection(RecipeImage.Table.databaseTableName).addDocument(data: [
            RecipeImage.Table.type: image.type.rawValue,
            RecipeImage.Table.data: image.data,
            RecipeImage.Table.categoryId: categoryId
        ]) { err in
            if let err = err {
                print("Error adding image: \(err)")
            } else {
                print("Image added with ID: \(ref!.documentID)")
            }
        }
    }
    
    func createCategory(withName name: String, forCollectionId collectionId: String) {
        var ref: DocumentReference? = nil
        ref = db.collection(RecipeCategory.Table.databaseTableName).addDocument(data: [
            RecipeCategory.Table.name: name,
            RecipeCategory.Table.recipeCollectionId: collectionId
        ]) { err in
            if let err = err {
                print("Error adding category: \(err)")
            } else {
                print("Category added with ID: \(ref!.documentID)")
            }
        }
    }
    
    func createCollection(withUsername username: String, onCompletion: @escaping (RecipeCollection?) -> Void) {
        var ref: DocumentReference? = nil
        ref = db.collection(RecipeCollection.Table.databaseTableName).addDocument(data: [
            RecipeCollection.Table.name: username
        ]) { err in
            if let err = err {
                print("Error adding collection: \(err)")
            } else {
                print("Collection added with ID: \(ref!.documentID)")
            }
        }
        if let ref = ref {
            onCompletion(RecipeCollection(id: ref.documentID, name: username))
        }
        else {
            onCompletion(nil)
        }
    }
    
    func createShoppingItem(_ item: ShoppingItem, withCollectionId collectionId: String) throws {
        var ref: DocumentReference? = nil
        ref = db.collection(ShoppingItem.Table.databaseTableName).addDocument(data: [
            ShoppingItem.Table.name: item.name,
            ShoppingItem.Table.amount: item.amount,
            ShoppingItem.Table.unitName: item.unitName.getName(),
            ShoppingItem.Table.completed: item.completed.toInt(),
            ShoppingItem.Table.collectionId: collectionId
        ]) { err in
            if let err = err {
                print("Error adding shopping item: \(err)")
            } else {
                print("Shopping item added with ID: \(ref!.documentID)")
            }
        }
    }
    
    func createShoppingItems(items: [ShoppingItem], withCollectionId collectionId: String) {
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
    
    // MARK: - Read
    
    func getRecipe(byId id: String, onRetrieve: @escaping (Recipe?) -> Void) {
        db.collection(Recipe.Table.databaseTableName).whereField(Recipe.Table.id, isEqualTo: id).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting recipe: \(err)")
                onRetrieve(nil)
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    onRetrieve(Recipe(document: document))
                }
            }
        }
    }
    
    func getIngredients(forRecipe recipe: Recipe, withId recipeId: String, onRetrieve: @escaping (Recipe?) -> Void) {
        var updatedRecipe = recipe
        db.collection(Ingredient.Table.databaseTableName).whereField(Ingredient.Table.recipeId, isEqualTo: recipeId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting ingredients: \(err)")
                onRetrieve(nil)
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    updatedRecipe.addIngredient(document: document)
                }
                onRetrieve(updatedRecipe)
            }
        }
    }
    
    func getDirections(forRecipe recipe: Recipe, withId recipeId: String, onRetrieve: @escaping (Recipe?) -> Void) {
        var updatedRecipe = recipe
        db.collection(Direction.Table.databaseTableName).whereField(Direction.Table.recipeId, isEqualTo: recipeId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting directions: \(err)")
                onRetrieve(nil)
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    updatedRecipe.addDirection(document: document)
                }
                onRetrieve(updatedRecipe)
            }
        }
    }
    
    func getImages(forRecipe recipe: Recipe, withRecipeId recipeId: String, onRetrieve: @escaping (Recipe?) -> Void) {
        var updatedRecipe = recipe
        db.collection(RecipeImage.Table.databaseTableName).whereField(RecipeImage.Table.recipeId, isEqualTo: recipeId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting images: \(err)")
                onRetrieve(nil)
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    updatedRecipe.addImage(document: document)
                }
                onRetrieve(updatedRecipe)
            }
        }
    }
    
    func getImage(withCategoryId categoryId: String, onRetrieve: @escaping (RecipeImage?) -> Void) {
        db.collection(RecipeImage.Table.databaseTableName).whereField(RecipeImage.Table.categoryId, isEqualTo: categoryId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting image: \(err)")
                onRetrieve(nil)
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    onRetrieve(RecipeImage(document: document))
                }
            }
        }
    }
    
    // TODO
    func getAllRecipes(withCollectionId collectionId: String, onRetrieve: @escaping ([Recipe]) -> Void) {
        db.collection(RecipeCategory.Table.databaseTableName).whereField(RecipeCategory.Table.recipeCollectionId, isEqualTo: collectionId).getDocuments() { querySnapshot, err in
            if let err = err {
                print("Error getting recipes: \(err)")
            }
            else {
                var recipes = [Recipe]()
                for document in querySnapshot!.documents {
                    let category = document
                    self.db.collection(Recipe.Table.databaseTableName).whereField(Recipe.Table.recipeCategoryId, isEqualTo: document.documentID).getDocuments() { querySnapshot, err in
                        if let err = err {
                            print("Error getting recipes: \(err)")
                        }
                        else {
                            let categoryRecipes = querySnapshot!.documents
//                            recipes.append(contentsOf: categoryRecipes)
                        }
                    }
                }
                onRetrieve(recipes)
            }
        }
    }
    
    func getRecipes(byCategoryId categoryId: String, onRetrieve: @escaping ([Recipe]) -> Void) {
        var recipes = [Recipe]()
        db.collection(Recipe.Table.databaseTableName).whereField(Recipe.Table.recipeCategoryId, isEqualTo: categoryId)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting recipes: \(err)")
                    onRetrieve([])
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        recipes.append(Recipe(document: document))
                    }
                    onRetrieve(recipes)
                }
        }
    }
    
    func getCategory(withId id: String, onRetrieve: @escaping (RecipeCategory?) -> Void) {
        db.collection(RecipeCategory.Table.databaseTableName).whereField(RecipeCategory.Table.id, isEqualTo: id).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting category: \(err)")
                onRetrieve(nil)
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    onRetrieve(RecipeCategory(document: document))
                }
            }
        }
    }
    
    func getCollection(withUsername username: String, onRetrieve: @escaping (RecipeCollection?) -> Void) {
        db.collection(RecipeCollection.Table.databaseTableName).whereField(RecipeCollection.Table.name, isEqualTo: username).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting collection: \(err)")
                onRetrieve(nil)
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    onRetrieve(RecipeCollection(document: document))
                }
            }
        }
    }
    
    func getCategories(byCollectionId collectionId: String, onRetrieve: @escaping ([RecipeCategory]) -> Void) {
        var categories = [RecipeCategory]()
        db.collection(RecipeCategory.Table.databaseTableName).whereField(RecipeCategory.Table.recipeCollectionId, isEqualTo: collectionId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting categories: \(err)")
                onRetrieve([])
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    categories.append(RecipeCategory(document: document))
                }
                onRetrieve(categories)
            }
        }
    }
    
    func getShoppingItems(byCollectionId collectionId: String, onRetrieve: @escaping ([ShoppingItem]) -> Void) {
        var items = [ShoppingItem]()
        db.collection(ShoppingItem.Table.databaseTableName).whereField(ShoppingItem.Table.collectionId, isEqualTo: collectionId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting shopping items: \(err)")
                onRetrieve([])
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    items.append(ShoppingItem(document: document))
                }
                onRetrieve(items)
            }
        }
    }
    
    // MARK: - Update
    
    func updateRecipe(withId id: String, name: String, servings: Int, source: String, recipeCategoryId: String, onCompletion: @escaping (Bool) -> Void) {
        let ref = db.collection(Recipe.Table.databaseTableName).document(id)

        ref.updateData([
            Recipe.Table.name: name,
            Recipe.Table.servings: servings,
            Recipe.Table.source: source,
            Recipe.Table.recipeCategoryId: recipeCategoryId
        ]) { err in
            if let err = err {
                print("Error updating recipe: \(err)")
                onCompletion(false)
            } else {
                print("Recipe successfully updated")
                onCompletion(true)
            }
        }
    }
    
    // changed this to having with recipe id insteaad of getting the recipe id from the direction
    func updateDirection(_ direction: Direction, onCompletion: @escaping (Bool) -> Void) {
        let ref = db.collection(Direction.Table.databaseTableName).document(direction.id)

        ref.updateData([
            Direction.Table.step: direction.step,
            Direction.Table.direction: direction.direction
        ]) { err in
            if let err = err {
                print("Error updating direction: \(err)")
                onCompletion(false)
            } else {
                print("Direction successfully updated")
                onCompletion(true)
            }
        }
    }
    
    func updateDirections(withRecipeId recipeId: String, directions: [Direction], oldRecipe recipe: Recipe, onCompletion: @escaping (Bool) -> Void) {
        do {
            var directionsToDelete = recipe.directions
            for direction in directions {
                if direction.id == Direction.defaultId {
                    try createDirection(direction, withRecipeId: recipeId)
                }
                else {
                    directionsToDelete.remove(element: direction)
                    updateDirection(direction) { success in
                        if !success {
                            onCompletion(false)

                        }
                    }
                }
            }
            // delete direction
            for direction in directionsToDelete {
                deleteDirection(withId: direction.id)
            }
            
            onCompletion(true)
        } catch {
            print("Error updating directions")
            onCompletion(false)
        }
    }
    
    func updateIngredient(_ ingredient: Ingredient, onCompletion: @escaping (Bool) -> Void) {
        let ref = db.collection(Ingredient.Table.databaseTableName).document(ingredient.id)

        ref.updateData([
            Ingredient.Table.name: ingredient.name,
            Ingredient.Table.amount: ingredient.amount,
            Ingredient.Table.unitName: ingredient.unitName.getName()
        ]) { err in
            if let err = err {
                print("Error updating ingredient: \(err)")
                onCompletion(false)
            } else {
                print("Ingredient successfully updated")
                onCompletion(true)
            }
        }
    }
    
    func updateIngredients(withRecipeId recipeId: String, ingredients: [Ingredient], oldRecipe recipe: Recipe, onCompletion: @escaping (Bool) -> Void) {
        do {
            var ingredientsToDelete = recipe.ingredients
            for ingredient in ingredients {
                if ingredient.id == Ingredient.defaultId {
                    try createIngredient(ingredient, withRecipeId: recipeId)
                }
                else {
                    ingredientsToDelete.remove(element: ingredient)
                    updateIngredient(ingredient) { success in
                        if !success {
                            onCompletion(false)
                        }
                    }
                }
            }
            // delete ingredients
            for ingredient in ingredientsToDelete {
                deleteIngredient(withId: ingredient.id)
            }

            onCompletion(true)
        } catch {
            print("Error updating ingredients")
            onCompletion(false)
        }
    }
    
    func updateImage(_ image: RecipeImage, onCompletion: @escaping (Bool) -> Void) {
        let ref = db.collection(RecipeImage.Table.databaseTableName).document(image.id)

        ref.updateData([
            RecipeImage.Table.type: image.type.rawValue,
            RecipeImage.Table.data: image.data
        ]) { err in
            if let err = err {
                print("Error updating image: \(err)")
                onCompletion(false)
            } else {
                print("Image successfully updated")
                onCompletion(true)
            }
        }
    }
    
    func updateImages(withRecipeId recipeId: String, images: [RecipeImage], oldRecipe recipe: Recipe, onCompletion: @escaping (Bool) -> Void) {
        do {
            var imagesToDelete = recipe.images
            for image in images {
                if image.id == RecipeImage.defaultId {
                    try createImage(image, withRecipeId: recipeId)
                }
                else {
                    imagesToDelete.remove(element: image)
                    updateImage(image) { success in
                        if !success {
                            onCompletion(false)
                        }
                    }
                }
            }
            // delete images
            for image in imagesToDelete {
                deleteImage(withId: image.id)
            }

            onCompletion(true)
        } catch {
            print("Error updating images")
            onCompletion(false)
        }
    }
    
    func updateCategory(withId id: String, name: String, recipeCollectionId: String, onCompletion: @escaping (Bool) -> Void) {
        let ref = db.collection(RecipeCategory.Table.databaseTableName).document(id)

        ref.updateData([
            RecipeCategory.Table.name: name,
            RecipeCategory.Table.recipeCollectionId: recipeCollectionId
        ]) { err in
            if let err = err {
                print("Error updating category: \(err)")
                onCompletion(false)
            } else {
                print("Category successfully updated")
                onCompletion(true)
            }
        }
    }
    
    func updateCollection(withId id: String, name: String, onCompletion: @escaping (Bool) -> Void) {
        let ref = db.collection(RecipeCollection.Table.databaseTableName).document(id)

        ref.updateData([
            RecipeCollection.Table.name: name
        ]) { err in
            if let err = err {
                print("Error updating collection: \(err)")
                onCompletion(false)
            } else {
                print("Collection successfully updated")
                onCompletion(true)
            }
        }
    }
    
    // MARK: - Delete
    
    func deleteRecipe(withId id: String) {
        db.collection(Recipe.Table.databaseTableName).document(id).delete() { err in
            if let err = err {
                print("Error removing recipe: \(err)")
            } else {
                print("Recipe successfully removed!")
            }
        }
    }
    
    func deleteDirection(withId id: String) {
        db.collection(Direction.Table.databaseTableName).document(id).delete() { err in
            if let err = err {
                print("Error removing direction: \(err)")
            } else {
                print("Direction successfully removed!")
            }
        }
    }
    
    func deleteDirections(withRecipeId recipeId: String) {
        db.collection(Direction.Table.databaseTableName).whereField(Direction.Table.recipeId, isEqualTo: recipeId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting directions: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    document.reference.delete() { err in
                        if let err = err {
                            print("Error removing direction: \(err)")
                        } else {
                            print("Direction successfully removed!")
                        }
                    }
                }
            }
        }
    }
    
    func deleteIngredient(withId id: String) {
        db.collection(Ingredient.Table.databaseTableName).document(id).delete() { err in
            if let err = err {
                print("Error removing ingredient: \(err)")
            } else {
                print("Ingredient successfully removed!")
            }
        }
    }
    
    func deleteIngredients(withRecipeId recipeId: String) {
        db.collection(Ingredient.Table.databaseTableName).whereField(Ingredient.Table.recipeId, isEqualTo: recipeId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting ingredients: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    document.reference.delete() { err in
                        if let err = err {
                            print("Error removing ingredient: \(err)")
                        } else {
                            print("Ingredient successfully removed!")
                        }
                    }
                }
            }
        }
    }
    
    func deleteImages(withRecipeId recipeId: String) {
        db.collection(RecipeImage.Table.databaseTableName).whereField(RecipeImage.Table.recipeId, isEqualTo: recipeId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting images: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    document.reference.delete() { err in
                        if let err = err {
                            print("Error removing image: \(err)")
                        } else {
                            print("Image successfully removed!")
                        }
                    }
                }
            }
        }
    }
    
    func deleteImage(withId id: String) {
        db.collection(RecipeImage.Table.databaseTableName).document(id).delete() { err in
            if let err = err {
                print("Error removing image: \(err)")
            } else {
                print("Image successfully removed!")
            }
        }
    }
    
    func deleteImage(withCategoryId categoryId: String) {
        db.collection(RecipeImage.Table.databaseTableName).whereField(RecipeImage.Table.categoryId, isEqualTo: categoryId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting image: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    document.reference.delete() { err in
                            if let err = err {
                                print("Error removing image: \(err)")
                            } else {
                                print("Image successfully removed!")
                            }
                    }
                }
            }
        }
    }
    
    func deleteCategory(withId id: String) {
        db.collection(RecipeCategory.Table.databaseTableName).document(id).delete() { err in
            if let err = err {
                print("Error removing category: \(err)")
            } else {
                print("Category successfully removed!")
            }
        }
    }
    
    func deleteCollection(withId id: String) {
        db.collection(RecipeCollection.Table.databaseTableName).document(id).delete() { err in
            if let err = err {
                print("Error removing collection: \(err)")
            } else {
                print("Collection successfully removed!")
            }
        }
    }
    
    func deleteRecipes(withCategoryId categoryId: String) {
        db.collection(Recipe.Table.databaseTableName).whereField(Recipe.Table.recipeCategoryId, isEqualTo: categoryId)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting recipes: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        document.reference.delete() { err in
                            if let err = err {
                                print("Error removing category: \(err)")
                            } else {
                                print("Category successfully removed!")
                            }
                        }
                    }
                }
        }
    }
    
    func deleteShoppingItem(withId id: String) {
        db.collection(ShoppingItem.Table.databaseTableName).document(id).delete() { err in
            if let err = err {
                print("Error removing shopping item: \(err)")
            } else {
                print("Shopping item successfully removed!")
            }
        }
    }
    
    func deleteShoppingItems(withCollectionId collectionId: String) {
        db.collection(ShoppingItem.Table.databaseTableName).whereField(ShoppingItem.Table.collectionId, isEqualTo: collectionId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting shopping items: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    document.reference.delete() { err in
                        if let err = err {
                            print("Error removing shopping item: \(err)")
                        } else {
                            print("Shopping item successfully removed!")
                        }
                    }
                }
            }
        }
    }
}

//enum CreateUserError: Error {
//    case usernameTaken
//    case emailTaken
//}
