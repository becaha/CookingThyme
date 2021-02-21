//
//  RecipeDB.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/5/21.
//

import Foundation
import Firebase

class RecipeDB {
    var db: Firestore
    var storage: StorageReference

    // MARK: - Singleton

    static let shared = RecipeDB()
    
    private init() {

        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
                
        db = Firestore.firestore()
        let dataStorage = Storage.storage()
        storage = dataStorage.reference()
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
                onCompletion(nil)
            } else {
                print("Recipe added with ID: \(ref!.documentID)")
                onCompletion(Recipe(id: ref!.documentID, name: name, servings: servings, source: source, recipeCategoryId: recipeCategoryId))
            }
        }
    }
    
    func createDirection(_ direction: Direction, withRecipeId recipeId: String, onCompletion: @escaping (Direction?) -> Void) {
        var ref: DocumentReference? = nil
        ref = db.collection(Direction.Table.databaseTableName).addDocument(data: [
            Direction.Table.step: direction.step,
            Direction.Table.direction: direction.direction,
            Direction.Table.recipeId: recipeId
        ]) { err in
            if let err = err {
                print("Error adding direction: \(err)")
                onCompletion(nil)
            } else {
                print("Direction added with ID: \(ref!.documentID)")
                onCompletion(Direction(id: ref!.documentID, step: direction.step, recipeId: recipeId, direction: direction.direction))
            }
        }
    }
    
    func createDirections(directions: [Direction], withRecipeId recipeId: String, onCompletion: @escaping ([Direction]) -> Void) {
        var createdDirections = [Direction]()
        let directionGroup = DispatchGroup()

        for direction in directions {
            directionGroup.enter()
            createDirection(direction, withRecipeId: recipeId) { createdDirection in
                if let createdDirection = createdDirection {
                    createdDirections.append(createdDirection)
                    directionGroup.leave()
                }
                else {
                    directionGroup.leave()
                }
            }
        }
        
        directionGroup.notify(queue: .main) {
            onCompletion(createdDirections)
        }
    }
    
    func createIngredient(_ ingredient: Ingredient, withRecipeId recipeId: String, onCompletion: @escaping (Ingredient?) -> Void) {
        var ref: DocumentReference? = nil
        ref = db.collection(Ingredient.Table.databaseTableName).addDocument(data: [
            Ingredient.Table.name: ingredient.name,
            Ingredient.Table.amount: ingredient.amount,
            Ingredient.Table.unitName: ingredient.unitName.getName(),
            Ingredient.Table.recipeId: recipeId
        ]) { err in
            if let err = err {
                print("Error adding ingredient: \(err)")
                onCompletion(nil)
            } else {
                print("Ingredient added with ID: \(ref!.documentID)")
                onCompletion(Ingredient(id: ref!.documentID, name: ingredient.name, amount: ingredient.amount, unitName: ingredient.unitName, recipeId: recipeId))
            }
        }
    }
    
    func createIngredients(ingredients: [Ingredient], withRecipeId recipeId: String, onCompletion: @escaping ([Ingredient]) -> Void) {
        var createdIngredients = [Ingredient]()
        let ingredientGroup = DispatchGroup()

        for ingredient in ingredients {
            ingredientGroup.enter()
            createIngredient(ingredient, withRecipeId: recipeId) { createdIngredient in
                if let createdIngredient = createdIngredient {
                    createdIngredients.append(createdIngredient)
                    ingredientGroup.leave()
                }
                else {
                    ingredientGroup.leave()
                }
            }
        }
        
        ingredientGroup.notify(queue: .main) {
            onCompletion(createdIngredients)
        }
    }
    
    func createStorageImage(_ image: RecipeImage, withId id: String) {
        let ref = getStorageImageRef(withId: id)

        if let imageData = ImageHandler.decodeImageToData(image.data) {
            // Upload the file to the path
            let uploadTask = ref.putData(imageData, metadata: nil) { (metadata, error) in
            }
            
            uploadTask.observe(.success) { snapshot in
              // Upload completed successfully
                print("image stored successfully")
            }

            uploadTask.observe(.failure) { snapshot in
              if let error = snapshot.error as NSError? {
                let message = error.localizedDescription
                print("error: \(message)")
              }
            }
        }
    }
    
    func createImage(_ image: RecipeImage, withCategoryId categoryId: String) {
        var ref: DocumentReference? = nil
        var imageData = image.data
        if image.type == .uiImage {
            imageData = ""
        }
        ref = db.collection(RecipeImage.Table.databaseTableName).addDocument(data: [
            RecipeImage.Table.type: image.type.rawValue,
            RecipeImage.Table.data: imageData,
            RecipeImage.Table.categoryId: categoryId
        ]) { err in
            if let err = err {
                let message = err.localizedDescription
                print("Error adding image: \(message)")
            } else {
                print("Image added with ID: \(ref!.documentID)")
                self.createStorageImage(image, withId: ref!.documentID)
            }
        }
    }
    
    func createImage(_ image: RecipeImage, withRecipeId recipeId: String, onCompletion: @escaping (RecipeImage?) -> Void) {
        var ref: DocumentReference? = nil
        var imageData = image.data
        if image.type == .uiImage {
            imageData = ""
        }
        ref = db.collection(RecipeImage.Table.databaseTableName).addDocument(data: [
            RecipeImage.Table.type: image.type.rawValue,
            RecipeImage.Table.data: imageData,
            RecipeImage.Table.recipeId: recipeId
        ]) { err in
            if let err = err {
                print("Error adding image: \(err)")
                onCompletion(nil)
            } else {
                print("Image added with ID: \(ref!.documentID)")
                self.createStorageImage(image, withId: ref!.documentID)
                onCompletion(RecipeImage(id: ref!.documentID, type: image.type, data: imageData, recipeId: recipeId))
            }
        }
    }
    
    func createImages(images: [RecipeImage], withRecipeId recipeId: String, onCompletion: @escaping ([RecipeImage]) -> Void) {
        var createdImages = [RecipeImage]()
        let imageGroup = DispatchGroup()

        for image in images {
            imageGroup.enter()
            createImage(image, withRecipeId: recipeId) { createdImage in
                if let createdImage = createdImage {
                    createdImages.append(createdImage)
                    imageGroup.leave()
                }
                else {
                    imageGroup.leave()
                }
            }
        }
        
        imageGroup.notify(queue: .main) {
            onCompletion(createdImages)
        }
    }
    
    func createCategory(withName name: String, forCollectionId collectionId: String, onCompletion: @escaping (RecipeCategory?) -> Void) {
        var ref: DocumentReference? = nil
        ref = db.collection(RecipeCategory.Table.databaseTableName).addDocument(data: [
            RecipeCategory.Table.name: name,
            RecipeCategory.Table.recipeCollectionId: collectionId
        ]) { err in
            if let err = err {
                print("Error adding category: \(err)")
                onCompletion(nil)
            } else {
                print("Category added with ID: \(ref!.documentID)")
                let category = RecipeCategory(id: ref!.documentID, name: name, recipeCollectionId: collectionId)
                onCompletion(category)
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
                onCompletion(nil)
            } else {
                print("Collection added with ID: \(ref!.documentID)")
                onCompletion(RecipeCollection(id: ref!.documentID, name: username))
            }
        }
    }
    
    func createShoppingItem(_ item: ShoppingItem, withCollectionId collectionId: String, onCompletion: @escaping (ShoppingItem?) -> Void) {
        var ref: DocumentReference? = nil
        ref = db.collection(ShoppingItem.Table.databaseTableName).addDocument(data: [
            ShoppingItem.Table.name: item.name,
            ShoppingItem.Table.amount: item.amount as Any,
            ShoppingItem.Table.unitName: item.unitName.getName(),
            ShoppingItem.Table.completed: item.completed.toInt(),
            ShoppingItem.Table.collectionId: collectionId
        ]) { err in
            if let err = err {
                print("Error adding shopping item: \(err)")
                onCompletion(nil)
            } else {
                print("Shopping item added with ID: \(ref!.documentID)")
                var newItem = item
                newItem.collectionId = collectionId
                newItem.id = ref!.documentID
                onCompletion(newItem)
            }
        }
    }
    
    // MARK: - Read
    
    func getRecipe(byId id: String, onRetrieve: @escaping (Recipe?) -> Void) {
        db.collection(Recipe.Table.databaseTableName).whereField(Recipe.Table.id, isEqualTo: id).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting recipe: \(err)")
                onRetrieve(nil)
            } else {
                if querySnapshot!.documents.count == 0 {
                    onRetrieve(nil)
                    return
                }
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    onRetrieve(Recipe(document: document))
                }
            }
        }
    }
    
    func getAllRecipes(withCollectionId collectionId: String, onRetrieve: @escaping ([Recipe]) -> Void) {
        db.collection(RecipeCategory.Table.databaseTableName).whereField(RecipeCategory.Table.recipeCollectionId, isEqualTo: collectionId).getDocuments() { querySnapshot, err in
            if let err = err {
                print("Error getting recipes: \(err)")
            }
            else {
                var recipes = [Recipe]()
                let recipesGroup = DispatchGroup()
                // only uses dispatch group if get all recipes is called, not the add snapshot listener
                var inRecipesGroup = true
                
                for document in querySnapshot!.documents {
                    recipesGroup.enter()
                    let category = document
                    self.db.collection(Recipe.Table.databaseTableName).whereField(Recipe.Table.recipeCategoryId, isEqualTo: category.documentID).getDocuments() { querySnapshot, err in
                        if let err = err {
                            print("Error getting recipes: \(err)")
                            if inRecipesGroup {
                                recipesGroup.leave()
                            }
                        }
                        else {
                            var categoryRecipes = [Recipe]()
                            let categoryDocs = querySnapshot!.documents
                            for categoryDoc in categoryDocs {
                                categoryRecipes.append(Recipe(document: categoryDoc))
                            }
                            recipes.append(contentsOf: categoryRecipes)
                            if inRecipesGroup {
                                recipesGroup.leave()
                            }
                        }
                    }
                }
                
                recipesGroup.notify(queue: .main) {
                    inRecipesGroup = false
                    recipes.sort { (recipeA, recipeB) -> Bool in
                        recipeA.name < recipeB.name
                    }
                    onRetrieve(recipes)
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
        db.collection(Direction.Table.databaseTableName).whereField(Direction.Table.recipeId, isEqualTo: recipeId).order(by: Direction.Table.step).getDocuments() { (querySnapshot, err) in
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
                let imageGroup = DispatchGroup()

                for document in querySnapshot!.documents {
                    imageGroup.enter()
                    print("image retrieved id: \(document.documentID)")
                    var recipeImage = RecipeImage(document: document)
                    if recipeImage.type == .uiImage {
                        self.getStorageImageURL(withName: document.documentID) { url in
                            recipeImage.data = url?.absoluteString ?? ""
                            updatedRecipe.addImage(recipeImage)
                            imageGroup.leave()
                        }
                    }
                    else {
                        updatedRecipe.addImage(recipeImage)
                        imageGroup.leave()
                    }
                }
                
                imageGroup.notify(queue: .main) {
                    onRetrieve(updatedRecipe)
                }
            }
        }
    }
    
    func getStorageImageURL(withName name: String, onRetrieve: @escaping (URL?) -> Void) {
        let ref = getStorageImageRef(withId: name)

        if let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // creates local filesystem url
            let localURL = documentDir.appendingPathComponent("\(name).jpg")

            // Download to the local filesystem
//            let downloadTask =
            ref.write(toFile: localURL) { url, error in
                if let error = error {
                    let message = error.localizedDescription
                    print("error: \(message)")
                    onRetrieve(nil)
                }
                else {
                    onRetrieve(url)
                }
            }
        }
    }
    
    func getImage(withCategoryId categoryId: String, onRetrieve: @escaping (RecipeImage?) -> Void) {
        db.collection(RecipeImage.Table.databaseTableName).whereField(RecipeImage.Table.categoryId, isEqualTo: categoryId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting image: \(err)")
                onRetrieve(nil)
                return
            } else {
                if querySnapshot!.documents.count == 0 {
                    onRetrieve(nil)
                    return
                }
                for document in querySnapshot!.documents {
                    print("image retrieved id: \(document.documentID)")
                    var recipeImage = RecipeImage(document: document)
                    if recipeImage.type == .uiImage {
                        self.getStorageImageURL(withName: document.documentID) { url in
                            recipeImage.data = url?.absoluteString ?? ""
                            onRetrieve(recipeImage)
                            return
                        }
                    }
                    else {
                        onRetrieve(recipeImage)
                        return
                    }
                }
            }
        }
    }
    
    func getRecipes(byCategoryId categoryId: String, onRetrieve: @escaping ([Recipe]) -> Void) {
        db.collection(Recipe.Table.databaseTableName).whereField(Recipe.Table.recipeCategoryId, isEqualTo: categoryId).order(by: Recipe.Table.name)
            .getDocuments() { (querySnapshot, err) in
                var recipes = [Recipe]()
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
                if querySnapshot!.documents.count == 0 {
                    onRetrieve(nil)
                    return
                }
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
                if querySnapshot!.documents.count == 0 {
                    onRetrieve(nil)
                    return
                }
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    onRetrieve(RecipeCollection(document: document))
                }
            }
        }
    }
    
    func getCategories(byCollectionId collectionId: String, onRetrieve: @escaping (Bool, [RecipeCategory]) -> Void) {
        db.collection(RecipeCategory.Table.databaseTableName).whereField(RecipeCategory.Table.recipeCollectionId, isEqualTo: collectionId).order(by: RecipeCategory.Table.name).getDocuments() { (querySnapshot, err) in
            var categories = [RecipeCategory]()
            if let err = err {
                print("Error getting categories: \(err)")
                onRetrieve(false, [])
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    categories.append(RecipeCategory(document: document))
                }
                onRetrieve(true, categories)
            }
        }
    }
    
    func getShoppingItems(byCollectionId collectionId: String, onRetrieve: @escaping ([ShoppingItem]) -> Void) {
        db.collection(ShoppingItem.Table.databaseTableName).whereField(ShoppingItem.Table.collectionId, isEqualTo: collectionId).order(by: ShoppingItem.Table.name).getDocuments() { (querySnapshot, err) in
            var items = [ShoppingItem]()
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
    
    func updateDirections(withRecipeId recipeId: String, directions: [Direction], oldRecipe recipe: Recipe, onCompletion: @escaping ([Direction]) -> Void) {
        var updatedDirections = [Direction]()
        let directionGroup = DispatchGroup()
        
        var directionsToDelete = recipe.directions
        
        for direction in directions {
            directionGroup.enter()
            if direction.id == Direction.defaultId {
                createDirection(direction, withRecipeId: recipeId) { createdDirection in
                    if let createdDirection = createdDirection {
                        updatedDirections.append(createdDirection)
                        directionGroup.leave()
                    }
                    else {
                        directionGroup.leave()
                    }
                }
            }
            else {
                directionsToDelete.remove(element: direction)
                updateDirection(direction) { success in
                    updatedDirections.append(direction)
                    directionGroup.leave()
                }
            }
        }
        
        // delete directions
        for direction in directionsToDelete {
            deleteDirection(withId: direction.id)
        }
        
        directionGroup.notify(queue: .main) {
            onCompletion(updatedDirections)
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
    
    // TODO need to put id in a newly created item so it can be updated later
    func updateIngredients(withRecipeId recipeId: String, ingredients: [Ingredient], oldRecipe recipe: Recipe, onCompletion: @escaping ([Ingredient]) -> Void) {
        var updatedIngredients = [Ingredient]()
        let ingredientGroup = DispatchGroup()
        
        var ingredientsToDelete = recipe.ingredients
        for ingredient in ingredients {
            ingredientGroup.enter()
            if ingredient.id == Ingredient.defaultId {
                createIngredient(ingredient, withRecipeId: recipeId) { createdIngredient in
                    if let createdIngredient = createdIngredient {
                        updatedIngredients.append(createdIngredient)
                        ingredientGroup.leave()
                    }
                    else {
                        ingredientGroup.leave()
                    }
                }
            }
            else {
                ingredientsToDelete.remove(element: ingredient)
                updateIngredient(ingredient) { success in
                    updatedIngredients.append(ingredient)
                    ingredientGroup.leave()
                }
            }
        }
        // delete ingredients
        for ingredient in ingredientsToDelete {
            deleteIngredient(withId: ingredient.id)
        }
        
        ingredientGroup.notify(queue: .main) {
            onCompletion(updatedIngredients)
        }
    }
    
//    func updateImage(_ image: RecipeImage) {
//        let ref = db.collection(RecipeImage.Table.databaseTableName).document(image.id)
//
//        ref.updateData([
//            RecipeImage.Table.type: image.type.rawValue,
//            RecipeImage.Table.data: image.data
//        ]) { err in
//            if let err = err {
//                print("Error updating image: \(err)")
//            } else {
//                print("Image successfully updated")
//            }
//        }
//    }
    
    func updateImages(withRecipeId recipeId: String, images: [RecipeImage], oldRecipe recipe: Recipe, onCompletion: @escaping ([RecipeImage]) -> Void) {
        var updatedImages = [RecipeImage]()
        let imageGroup = DispatchGroup()
        
        var imagesToDelete = recipe.images
        for image in images {
            imageGroup.enter()
            if image.id == RecipeImage.defaultId {
                createImage(image, withRecipeId: recipeId) { createdImage in
                    if let createdImage = createdImage {
                        updatedImages.append(createdImage)
                        imageGroup.leave()
                    }
                    else {
                        imageGroup.leave()
                    }
                }
            }
            else {
                imagesToDelete.remove(element: image)
                // images are never updated in editing, so neither creating nor deleting, just leave as is
                updatedImages.append(image)
                imageGroup.leave()
            }
        }
        // delete images
        for image in imagesToDelete {
            deleteImage(withId: image.id)
        }
        
        imageGroup.notify(queue: .main) {
            onCompletion(updatedImages)
        }
    }
    
    func updateShoppingItem(_ item: ShoppingItem) {
        let ref = db.collection(ShoppingItem.Table.databaseTableName).document(item.id)

        ref.updateData([
            // currently completed is only piece editable
//            ShoppingItem.Table.name: item.name,
//            ShoppingItem.Table.amount: item.amount,
//            ShoppingItem.Table.unitName: item.unitName.getName(),
            ShoppingItem.Table.completed: item.completed.toInt()
        ]) { err in
            if let err = err {
                print("Error updating shopping item: \(err)")
            } else {
                print("Shopping item successfully updated")
            }
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
                    self.deleteStorageImage(withId: document.documentID)
                }
            }
        }
    }
    
    func getStorageImageRef(withId id: String) -> StorageReference {
        return storage.child("images/\(id).jpg")
    }
    
    func deleteStorageImage(withId id: String) {
        let ref = getStorageImageRef(withId: id)

        ref.delete { error in
            if let error = error {
                let message = error.localizedDescription
                print("error: \(message)")
            }
            else {
                // File deleted successfully
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
        deleteStorageImage(withId: id)
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
                    self.deleteStorageImage(withId: document.documentID)
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
