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
            if let error = err as NSError? {
                self.handleError(error)
                print("Error adding recipe: \(error)")
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
            if let error = err as NSError? {
                self.handleError(error)
                print("Error adding direction: \(error)")
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
    
    func createIngredient(_ ingredient: Ingredient, order: Int, withRecipeId recipeId: String, onCompletion: @escaping (Ingredient?) -> Void) {
        var ref: DocumentReference? = nil
        ref = db.collection(Ingredient.Table.databaseTableName).addDocument(data: [
            Ingredient.Table.name: ingredient.name,
            Ingredient.Table.amount: ingredient.amount,
            Ingredient.Table.unitName: ingredient.unitName.getName(),
            Ingredient.Table.order: order,
            Ingredient.Table.recipeId: recipeId
        ]) { err in
            if let error = err as NSError? {
                self.handleError(error)
                print("Error adding ingredient: \(error)")
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
        var count = -1

        for ingredient in ingredients {
            ingredientGroup.enter()
            count += 1
            createIngredient(ingredient, order: count, withRecipeId: recipeId) { createdIngredient in
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
    
    func createStorageImage(_ image: RecipeImage, withId id: String, onCompletion: @escaping (Bool) -> Void) {
        let ref = getStorageImageRef(withId: id)

        if image.type == ImageType.url {
            onCompletion(true)
            return
        }
        if let imageData = ImageHandler.decodeImageToData(image.data) {
            // Upload the file to the path
            _ = ref.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error as NSError? {
                  self.handleStorageError(error)
                  let message = error.localizedDescription
                  print("error: \(message)")
                  onCompletion(false)
                }
                else {
                    onCompletion(true)
                }
            }
        }
        else {
            onCompletion(false)
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
            if let error = err as NSError? {
                self.handleError(error)
                let message = error.localizedDescription
                print("Error adding image: \(message)")
            } else {
                print("Image added with ID: \(ref!.documentID)")
                self.createStorageImage(image, withId: ref!.documentID) { success in
                    if !success {
                        // if image was not stored, delete reference to image
                        self.deleteImage(withId: ref!.documentID) { success in
                            if !success {
                                print("error")
                            }
                        }
                    }
                }
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
            if let error = err as NSError? {
                self.handleError(error)
                print("Error adding image: \(error)")
                onCompletion(nil)
            } else {
                print("Image added with ID: \(ref!.documentID)")
                if image.type == ImageType.uiImage {
                    self.createStorageImage(image, withId: ref!.documentID) { success in
                        if !success {
                            self.deleteImage(withId: ref!.documentID) { success in
                                if !success {
                                    print("error")
                                }
                                onCompletion(nil)
                            }
                        }
                        else {
                            self.getStorageImageURL(withName: ref!.documentID) { url in
                                if let url = url {
                                    onCompletion(RecipeImage(id: ref!.documentID, type: image.type, data: url.absoluteString, recipeId: recipeId))
                                }
                                else {
                                    onCompletion(nil)
                                }
                            }
                        }
                    }
                }
                // url
                else {
                    onCompletion(RecipeImage(id: ref!.documentID, type: image.type, data: imageData, recipeId: recipeId))
                }
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
            if let error = err as NSError? {
                self.handleError(error)
                print("Error adding category: \(error)")
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
            if let error = err as NSError? {
                self.handleError(error)
                print("Error adding collection: \(error)")
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
            if let error = err as NSError? {
                self.handleError(error)
                print("Error adding shopping item: \(error)")
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
            if let error = err as NSError? {
                self.handleError(error)
                print("Error getting recipe: \(error)")
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
            if let error = err as NSError? {
                self.handleError(error)
                print("Error getting recipes: \(error)")
            }
            else {
                var recipes = [Recipe]()
                let recipesGroup = DispatchGroup()
                // only uses dispatch dispatchGroup if get all recipes is called, not the add snapshot listener
                var inRecipesGroup = true
                
                for document in querySnapshot!.documents {
                    recipesGroup.enter()
                    let category = document
                    self.db.collection(Recipe.Table.databaseTableName).whereField(Recipe.Table.recipeCategoryId, isEqualTo: category.documentID).getDocuments() { querySnapshot, err in
                        if let error = err as NSError? {
                            self.handleError(error)
                            print("Error getting recipes: \(error)")
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
        db.collection(Ingredient.Table.databaseTableName).whereField(Ingredient.Table.recipeId, isEqualTo: recipeId).order(by: Ingredient.Table.order).getDocuments() { (querySnapshot, err) in
            if let error = err as NSError? {
                self.handleError(error)
                print("Error getting ingredients: \(error)")
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
            if let error = err as NSError? {
                self.handleError(error)
                print("Error getting directions: \(error)")
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
            if let error = err as NSError? {
                self.handleError(error)
                print("Error getting images: \(error)")
                onRetrieve(nil)
            } else {
                let imageGroup = DispatchGroup()

                for document in querySnapshot!.documents {
                    imageGroup.enter()
                    print("image retrieved id: \(document.documentID)")
                    var recipeImage = RecipeImage(document: document)
                    if recipeImage.type == .uiImage {
                        self.getStorageImageURL(withName: document.documentID) { url in
                            if let url = url {
                                recipeImage.data = url.absoluteString
                                updatedRecipe.addImage(recipeImage)
                            }
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
            ref.write(toFile: localURL) { url, err in
                if let error = err as NSError? {
                    self.handleStorageError(error)
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
            if let error = err as NSError? {
                self.handleError(error)
                print("Error getting image: \(error)")
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
                            if let url = url {
                                recipeImage.data = url.absoluteString
                                onRetrieve(recipeImage)
                            }
                            else {
                                onRetrieve(nil)
                            }
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
                if let error = err as NSError? {
                    self.handleError(error)
                    print("Error getting recipes: \(error)")
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
            if let error = err as NSError? {
                self.handleError(error)
                print("Error getting category: \(error)")
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
    
    func getCollection(withUsername username: String, onRetrieve: @escaping (RecipeCollection?, Bool) -> Void) {
        db.collection(RecipeCollection.Table.databaseTableName).whereField(RecipeCollection.Table.name, isEqualTo: username).getDocuments() { (querySnapshot, err) in
            if let error = err as NSError? {
                self.handleError(error)
                print("Error getting collection: \(error)")
                if self.isUnauthorized(error) {
                    onRetrieve(nil, true)
                }
                else {
                    onRetrieve(nil, false)
                }
            } else {
                if querySnapshot!.documents.count == 0 {
                    onRetrieve(nil, false)
                    return
                }
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    onRetrieve(RecipeCollection(document: document), false)
                }
            }
        }
    }
    
    func getCategories(byCollectionId collectionId: String, onRetrieve: @escaping (Bool, [RecipeCategory]) -> Void) {
        db.collection(RecipeCategory.Table.databaseTableName).whereField(RecipeCategory.Table.recipeCollectionId, isEqualTo: collectionId).order(by: RecipeCategory.Table.name).getDocuments() { (querySnapshot, err) in
            var categories = [RecipeCategory]()
            if let error = err as NSError? {
                self.handleError(error)
                print("Error getting categories: \(error)")
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
            if let error = err as NSError? {
                self.handleError(error)
                print("Error getting shopping items: \(error)")
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
            if let error = err as NSError? {
                self.handleError(error)
                print("Error updating recipe: \(error)")
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
            if let error = err as NSError? {
                self.handleError(error)
                print("Error updating direction: \(error)")
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
            deleteDirection(withId: direction.id) { success in

            }
        }
        
        directionGroup.notify(queue: .main) {
            onCompletion(updatedDirections)
        }
    }
    
    func updateIngredient(_ ingredient: Ingredient, order: Int, onCompletion: @escaping (Bool) -> Void) {
        let ref = db.collection(Ingredient.Table.databaseTableName).document(ingredient.id)

        ref.updateData([
            Ingredient.Table.name: ingredient.name,
            Ingredient.Table.amount: ingredient.amount,
            Ingredient.Table.unitName: ingredient.unitName.getName(),
            Ingredient.Table.order: order
        ]) { err in
            if let error = err as NSError? {
                self.handleError(error)
                print("Error updating ingredient: \(error)")
                onCompletion(false)
            } else {
                print("Ingredient successfully updated")
                onCompletion(true)
            }
        }
    }
    
    func updateIngredients(withRecipeId recipeId: String, ingredients: [Ingredient], oldRecipe recipe: Recipe, onCompletion: @escaping ([Ingredient]) -> Void) {
        var updatedIngredients = [Ingredient]()
        let ingredientGroup = DispatchGroup()
        var count = -1
        
        var ingredientsToDelete = recipe.ingredients
        for ingredient in ingredients {
            ingredientGroup.enter()
            count += 1
            if ingredient.id == Ingredient.defaultId {
                createIngredient(ingredient, order: count, withRecipeId: recipeId) { createdIngredient in
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
                updateIngredient(ingredient, order: count) { success in
                    updatedIngredients.append(ingredient)
                    ingredientGroup.leave()
                }
            }
        }
        // delete ingredients
        for ingredient in ingredientsToDelete {
            deleteIngredient(withId: ingredient.id) { success in
                if !success {
                    print("error")
                }
            }
        }
        
        ingredientGroup.notify(queue: .main) {
            onCompletion(updatedIngredients)
        }
    }
    
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
            deleteImage(withId: image.id) { success in
                if !success {
                    print("error")
                }
            }
        }
        
        imageGroup.notify(queue: .main) {
            onCompletion(updatedImages)
        }
    }
    
    func updateShoppingItem(_ item: ShoppingItem) {
        let ref = db.collection(ShoppingItem.Table.databaseTableName).document(item.id)

        ref.updateData([
            // currently completed is only piece editable
            ShoppingItem.Table.completed: item.completed.toInt()
        ]) { err in
            if let error = err as NSError? {
                self.handleError(error)
                print("Error updating shopping item: \(error)")
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
            if let error = err as NSError? {
                self.handleError(error)
                print("Error updating category: \(error)")
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
            if let error = err as NSError? {
                self.handleError(error)
                print("Error updating collection: \(error)")
                onCompletion(false)
            } else {
                print("Collection successfully updated")
                onCompletion(true)
            }
        }
    }
    
    // MARK: - Delete
    
    func deleteRecipe(withId id: String, onCompletion: @escaping (Bool) -> Void) {
        db.collection(Recipe.Table.databaseTableName).document(id).delete() { err in
            if let error = err as NSError? {
                self.handleError(error)
                print("Error removing recipe: \(error)")
                onCompletion(false)
            } else {
                print("Recipe successfully removed!")
                onCompletion(true)
            }
        }
    }
    
    func deleteDirection(withId id: String, onCompletion: @escaping (Bool) -> Void) {
        db.collection(Direction.Table.databaseTableName).document(id).delete() { err in
            if let error = err as NSError? {
                self.handleError(error)
                print("Error removing direction: \(error)")
                onCompletion(false)
            } else {
                print("Direction successfully removed!")
                onCompletion(true)
            }
        }
    }
    
    func deleteDirections(withRecipeId recipeId: String, onCompletion: @escaping (Bool) -> Void) {
        db.collection(Direction.Table.databaseTableName).whereField(Direction.Table.recipeId, isEqualTo: recipeId).getDocuments() { (querySnapshot, err) in
            if let error = err as NSError? {
                self.handleError(error)
                print("Error getting directions: \(error)")
                onCompletion(false)
            } else {
                let dispatchGroup = DispatchGroup()
                
                for document in querySnapshot!.documents {
                    dispatchGroup.enter()
                    print("\(document.documentID) => \(document.data())")
                    document.reference.delete() { err in
                        if let error = err as NSError? {
                            self.handleError(error)
                            print("Error removing direction: \(error)")
                            dispatchGroup.leave()
                        } else {
                            print("Direction successfully removed!")
                            dispatchGroup.leave()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    onCompletion(true)
                }
            }
        }
    }
    
    func deleteIngredient(withId id: String, onCompletion: @escaping (Bool) -> Void) {
        db.collection(Ingredient.Table.databaseTableName).document(id).delete() { err in
            if let error = err as NSError? {
                self.handleError(error)
                print("Error removing ingredient: \(error)")
                onCompletion(false)
            } else {
                print("Ingredient successfully removed!")
                onCompletion(true)
            }
        }
    }
    
    func deleteIngredients(withRecipeId recipeId: String, onCompletion: @escaping (Bool) -> Void) {
        db.collection(Ingredient.Table.databaseTableName).whereField(Ingredient.Table.recipeId, isEqualTo: recipeId).getDocuments() { (querySnapshot, err) in
            if let error = err as NSError? {
                self.handleError(error)
                print("Error getting ingredients: \(error)")
                onCompletion(false)
            } else {
                let dispatchGroup = DispatchGroup()
                
                for document in querySnapshot!.documents {
                    dispatchGroup.enter()
                    print("\(document.documentID) => \(document.data())")
                    document.reference.delete() { err in
                        if let error = err as NSError? {
                            self.handleError(error)
                            print("Error removing ingredient: \(error)")
                            dispatchGroup.leave()
                        } else {
                            print("Ingredient successfully removed!")
                            dispatchGroup.leave()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    onCompletion(true)
                }
            }
        }
    }
    
    func deleteImages(withRecipeId recipeId: String, onCompletion: @escaping (Bool) -> Void) {
        db.collection(RecipeImage.Table.databaseTableName).whereField(RecipeImage.Table.recipeId, isEqualTo: recipeId).getDocuments() { (querySnapshot, err) in
            if let error = err as NSError? {
                self.handleError(error)
                print("Error getting images: \(error)")
                onCompletion(false)
            } else {
                let dispatchGroup = DispatchGroup()
                
                for document in querySnapshot!.documents {
                    dispatchGroup.enter()
                    print("\(document.documentID) => \(document.data())")
                    document.reference.delete() { err in
                        if let error = err as NSError? {
                            self.handleError(error)
                            print("Error removing image: \(error)")
                            dispatchGroup.leave()
                        } else {
                            print("Image successfully removed!")
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.enter()
                    self.deleteStorageImage(withId: document.documentID) { success in
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    onCompletion(true)
                }
            }
        }
    }
    
    func deleteImages(withCategoryId categoryId: String, onCompletion: @escaping (Bool) -> Void) {
        db.collection(RecipeImage.Table.databaseTableName).whereField(RecipeImage.Table.categoryId, isEqualTo: categoryId).getDocuments() { (querySnapshot, err) in
            if let error = err as NSError? {
                self.handleError(error)
                print("Error getting images: \(error)")
                onCompletion(false)
            } else {
                let dispatchGroup = DispatchGroup()
                
                for document in querySnapshot!.documents {
                    dispatchGroup.enter()
                    print("\(document.documentID) => \(document.data())")
                    document.reference.delete() { err in
                        if let error = err as NSError? {
                            self.handleError(error)
                            print("Error removing image: \(error)")
                            dispatchGroup.leave()
                        } else {
                            print("Image successfully removed!")
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.enter()
                    self.deleteStorageImage(withId: document.documentID) { success in
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    onCompletion(true)
                }
            }
        }
    }
    
    
    func getStorageImageRef(withId id: String) -> StorageReference {
        return storage.child("images/\(id).jpg")
    }
    
    func deleteStorageImage(withId id: String, onCompletion: @escaping (Bool) -> Void) {
        let ref = getStorageImageRef(withId: id)

        ref.delete { err in
            if let error = err as NSError? {
                self.handleStorageError(error)
                let message = error.localizedDescription
                print("error: \(message)")
                onCompletion(false)
            }
            else {
                // File deleted successfully
                onCompletion(true)
            }
        }
    }
    
    func deleteImage(withId id: String, onCompletion: @escaping (Bool) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        db.collection(RecipeImage.Table.databaseTableName).document(id).delete() { err in
            if let error = err as NSError? {
                self.handleError(error)
                print("Error removing image: \(error)")
                dispatchGroup.leave()
            } else {
                print("Image successfully removed!")
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        deleteStorageImage(withId: id) { success in
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            onCompletion(true)
        }
    }
    
    func deleteImage(withCategoryId categoryId: String, onCompletion: @escaping (Bool) -> Void) {
        db.collection(RecipeImage.Table.databaseTableName).whereField(RecipeImage.Table.categoryId, isEqualTo: categoryId).getDocuments() { (querySnapshot, err) in
            if let error = err as NSError? {
                self.handleError(error)
                print("Error getting image: \(error)")
                onCompletion(false)
            } else {
                let dispatchGroup = DispatchGroup()
                
                for document in querySnapshot!.documents {
                    dispatchGroup.enter()
                    print("\(document.documentID) => \(document.data())")
                    document.reference.delete() { err in
                        if let error = err as NSError? {
                            self.handleError(error)
                            print("Error removing image: \(error)")
                            dispatchGroup.leave()
                        } else {
                            print("Image successfully removed!")
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.enter()
                    self.deleteStorageImage(withId: document.documentID) { success in
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    onCompletion(true)
                }
            }
        }
    }
    
    func deleteCategory(withId id: String, onCompletion: @escaping (Bool) -> Void) {
        db.collection(RecipeCategory.Table.databaseTableName).document(id).delete() { err in
            if let error = err as NSError? {
                self.handleError(error)
                print("Error removing category: \(error)")
                onCompletion(false)
            } else {
                print("Category successfully removed!")
                onCompletion(true)
            }
        }
    }
    
    func deleteCollection(withId id: String, onCompletion: @escaping (Bool) -> Void) {
        db.collection(RecipeCollection.Table.databaseTableName).document(id).delete() { err in
            if let error = err as NSError? {
                self.handleError(error)
                print("Error removing collection: \(error)")
                onCompletion(false)
            } else {
                print("Collection successfully removed!")
                onCompletion(true)
            }
        }
    }
    
    func deleteRecipes(withCategoryId categoryId: String, onCompletion: @escaping (Bool) -> Void) {
        db.collection(Recipe.Table.databaseTableName).whereField(Recipe.Table.recipeCategoryId, isEqualTo: categoryId)
            .getDocuments() { (querySnapshot, err) in
                if let error = err as NSError? {
                    self.handleError(error)
                    print("Error getting recipes: \(error)")
                    onCompletion(false)
                } else {
                    let dispatchGroup = DispatchGroup()
                    
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        dispatchGroup.enter()
                        document.reference.delete() { err in
                            if let error = err as NSError? {
                                self.handleError(error)
                                print("Error removing category: \(error)")
                                dispatchGroup.leave()
                            } else {
                                print("Category successfully removed!")
                                dispatchGroup.leave()
                            }
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        onCompletion(true)
                    }
                }
        }
    }
    
    func deleteShoppingItem(withId id: String, onCompletion: @escaping (Bool) -> Void) {
        db.collection(ShoppingItem.Table.databaseTableName).document(id).delete() { err in
            if let error = err as NSError? {
                self.handleError(error)
                print("Error removing shopping item: \(error)")
                onCompletion(false)
            } else {
                print("Shopping item successfully removed!")
                onCompletion(true)
            }
        }
    }
    
    func deleteShoppingItems(withCollectionId collectionId: String, onCompletion: @escaping (Bool) -> Void) {
        db.collection(ShoppingItem.Table.databaseTableName).whereField(ShoppingItem.Table.collectionId, isEqualTo: collectionId).getDocuments() { (querySnapshot, err) in
            if let error = err as NSError? {
                self.handleError(error)
                print("Error getting shopping items: \(error)")
                onCompletion(false)
            } else {
                let dispatchGroup = DispatchGroup()
                
                for document in querySnapshot!.documents {
                    dispatchGroup.enter()
                    print("\(document.documentID) => \(document.data())")
                    document.reference.delete() { err in
                        if let error = err as NSError? {
                            self.handleError(error)
                            print("Error removing shopping item: \(error)")
                            dispatchGroup.leave()
                        } else {
                            print("Shopping item successfully removed!")
                            dispatchGroup.leave()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    onCompletion(true)
                }
            }
        }
    }
    
    // MARK: - Handle Errors
    func isUnauthorized(_ error: NSError) -> Bool {
        switch FirestoreErrorCode(rawValue: error.code) {
        case .unauthenticated:
            return true
            
        case .permissionDenied:
            return true
            
        default:
            return false
        }
    }
    
    func handleStorageError(_ error: NSError) {
        switch StorageErrorCode(rawValue: error.code) {
        case .unauthorized:
            // FIRStorageErrorCodeUnauthenticated
            let message = error.localizedDescription
            print("Error: \(message)")

        default:
            let errorType = AuthErrorCode(rawValue: error.code)
            let message = error.localizedDescription
            print("\(String(describing: errorType)): \(message)")
        }
    }
    
    
    func handleError(_ error: NSError) {
        switch FirestoreErrorCode(rawValue: error.code) {
        case .unauthenticated:
            let message = error.localizedDescription
            print("Error: \(message)")
            
        default:
            let errorType = AuthErrorCode(rawValue: error.code)
            let errorMessage = error.localizedDescription
            print("\(String(describing: errorType)): \(errorMessage)")
        }
    }
}

enum RecipeDBError: Error {
    case unauthorized
}
