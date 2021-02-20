//
//  RecipeVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation
import Combine
import SwiftUI

// TODO: when update, must return id
// TODO: everything on background threed
class RecipeVM: ObservableObject, Identifiable {
    var collection: RecipeCollectionVM?
    var category: RecipeCategoryVM?
    @Published var recipe: Recipe
    @Published var tempDirections: [Direction] = []
    @Published var tempIngredients: [TempIngredient] = []
    @Published var tempImages: [RecipeImage] = []
    @Published var recipeText: String?
        
    @Published var imageHandler = ImageHandler()
    private var imageHandlerCancellable: AnyCancellable?
    
    @Published var transcriber = RecipeTranscriber()
    @Published var importFromURL = false
    @Published var isImportingFromURL = false
    @Published var invalidURL = false
    
    @Published var recipesWebHandler = RecipeSearchHandler()
    @Published var isPopullating = true
    @Published var recipeNotFound = false
    
    @Published var tempRecipe: Recipe
    
    @Published var isLoading: Bool?
    
    private var webHandlerCancellable: AnyCancellable?
    private var recipeDetailCancellable: AnyCancellable?
    private var recipeDetailErrorCancellable: AnyCancellable?
    
    var originalServings: Int = 0
    var tempRecipeOriginalServings: Int = 0

    private var recipeTranscriberCancellable: AnyCancellable?
    private var recipeTextTranscriberCancellable: AnyCancellable?
    
    var imagesChanged = false

    // MARK: - Init
    
    // inits recipe in a category
    init(recipe: Recipe, category: RecipeCategoryVM, collection: RecipeCollectionVM) {
        self.isLoading = true
        self.collection = collection
        self.category = category

        self.recipe = recipe
        self.tempRecipe = recipe
        
        setCancellables()
        
        // checks if recipe is in recipe store
        if let foundRecipeVM = self.collection?.recipesStore[recipe.id] {
            self.recipe = foundRecipeVM.tempRecipe
            
            self.popullateRecipeTemps()
            self.imageHandler = foundRecipeVM.imageHandler

            self.isLoading = false
            return
        }
        
        popullateRecipe() { success in
            if success {
                self.popullateLocalRecipe() { success in
                    self.isLoading = false
                    // sets initialized recipe to the recipe store, if not on create new recipe
                    if recipe.id != Recipe.defaultId {
                        self.collection?.recipesStore[recipe.id] = self
                    }
                }
            }
            else {
                print("error popullating initialized recipe")
            }
        }
    }
    
    // inits a create new recipe in a category
    init(category: RecipeCategoryVM, collection: RecipeCollectionVM) {
        self.isLoading = true
        self.recipe = Recipe()
        self.tempRecipe = Recipe()

        self.category = category
        
        setCancellables()
        self.isLoading = false
    }
    
    // inits a public recipe from search
    init(recipe: Recipe) {
        self.isLoading = true
        self.recipe = recipe
        self.tempRecipe = recipe
        
        setCancellables()
        self.popullateLocalRecipe() { success in
            self.isLoading = false
        }
    }
    
    func setCancellables() {
        self.imageHandlerCancellable = self.imageHandler.objectWillChange
            .sink { _ in
                self.objectWillChange.send()
            }
        
        self.recipeTranscriberCancellable = self.transcriber.$recipe
            .sink { (recipe) in
                if let recipe = recipe {
                    self.importFromURL = false
                    self.invalidURL = false
                    self.recipe = recipe
                    self.popullateLocalRecipe() { success in
                        self.isImportingFromURL = false
                    }
                }
                else if self.isImportingFromURL {
                    self.invalidURL = true
                }
            }
        
        self.recipeTextTranscriberCancellable = self.transcriber.$recipeText
            .sink { (recipeText) in
                self.recipeText = recipeText
            }
        
        self.webHandlerCancellable = self.recipesWebHandler.objectWillChange
            .sink { _ in
                self.objectWillChange.send()
            }
        
        self.recipeDetailCancellable = self.recipesWebHandler.$recipeDetail.sink { (recipe) in
            if let recipe = recipe {
                self.recipe = recipe
                self.tempRecipe = recipe
                self.popullateLocalRecipe() { success in
                    if !success {
                        print("error popullating images")
                    }
                    self.isPopullating = false
                }
            }
        }
        
        self.recipeDetailErrorCancellable = self.recipesWebHandler.$recipeDetailError.sink { (isError) in
            self.recipeNotFound = isError
        }
    }
    
    // MARK: - Model Access
    
    var id: String {
        recipe.id
    }
    
    var name: String {
        recipe.name.lowercased().capitalized
    }
    
    var servings: Int {
        get { recipe.servings }
        set { recipe.servings = newValue }
    }
    
    var ingredients: [Ingredient] {
        recipe.ingredients
    }
    
    var directions: [Direction] {
        recipe.directions
    }
    
    var images: [RecipeImage] {
        recipe.images
    }
    
    var source: String {
        recipe.source
    }
    
    var categoryId: String {
        recipe.recipeCategoryId
    }
    
    func isCreatingRecipe() -> Bool {
        return recipe.id == Recipe.defaultId
    }
    
    // MARK: - Intents
    
    // MARK: - Public Recipe
    
    // calls api to get detail of a recipe (its parts)
    func popullateDetail() {
        recipesWebHandler.listRecipeDetail(recipe)
    }
    
    // copies public recipe to category of user's collection, makes recipe permanent
    func copyRecipe(toCategoryId categoryId: String, inCollection collection: RecipeCollectionVM) {
        if let category = collection.getCategory(withId: categoryId) {
            RecipeCategoryVM.createRecipe(forCategoryId: category.id, name: recipe.name, ingredients: recipe.ingredients, directions: recipe.directions, images: recipe.images, servings: recipe.servings.toString(), source: recipe.source) { createdRecipe in
                if let createdRecipe = createdRecipe {
                    // todo store
                    let updatedRecipeVM = self
                    updatedRecipeVM.recipe = createdRecipe
                    // updates recipe store
                    collection.recipesStore[createdRecipe.id] = updatedRecipeVM
                    // updates category store
                    collection.addRecipeToStore(createdRecipe, toCategoryId: categoryId)
                    
                    collection.refreshCurrentCategory()
                }
                else {
                    print("error copying recipe")
                }
            }
        }
    }
    
    // MARK: - Recipe
    
    // MARK: - DB Loaders
    
    // gets recipe from db
    func refreshRecipe(onCompletion: @escaping (Bool) -> Void) {
        RecipeDB.shared.getRecipe(byId: recipe.id) { recipe in
            if let recipe = recipe {
                self.recipe = recipe
                self.popullateRecipe(onCompletion: onCompletion)
            }
            else {
                onCompletion(false)
            }
        }
    }
    
    // gets recipe, directions, ingredients, and images from db
    func popullateRecipe(onCompletion: @escaping (Bool) -> Void) {
        RecipeDB.shared.getDirections(forRecipe: self.recipe, withId: self.recipe.id) { recipeWithDirections in
            if let recipeWithDirections = recipeWithDirections {
                RecipeDB.shared.getIngredients(forRecipe: recipeWithDirections, withId: self.recipe.id) { recipeWithIngredients in
                    if let recipeWithIngredients = recipeWithIngredients {
                        RecipeDB.shared.getImages(forRecipe: recipeWithIngredients, withRecipeId: self.recipe.id) { recipeWithImages in
                            if let recipeWithImages = recipeWithImages {
                                self.recipe = recipeWithImages
//                                self.popullateRecipeTemps()
                                onCompletion(true)
                                return
                            }
                        }
                    }
                }
            }
        }
        onCompletion(false)
    }
    
    // MARK: - Setters/Popullaters
    
    func popullateRecipeTemps() {
        self.originalServings = recipe.servings
        self.tempDirections = recipe.directions
        self.tempIngredients = Ingredient.toTempIngredients(recipe.ingredients)
        self.tempImages = recipe.images
        
        self.tempRecipeOriginalServings = recipe.servings
        self.tempRecipe.directions = recipe.directions
        self.tempRecipe.ingredients = recipe.ingredients
        self.tempRecipe.images = recipe.images
        
    }
    
    // changed so doesn't wait for pictures
    func popullateLocalRecipe(onCompletion: @escaping (Bool) -> Void) {
        self.popullateRecipeTemps()
        onCompletion(true)
        
        popullateImages() { success in
            if !success {
                print("error popullating images")
            }
//            onCompletion(success)
        }
    }
    
    // sends images to image handler to prep for ui
    func popullateImages(onCompletion: @escaping (Bool) -> Void) {
        // only update images if they have been (added to/deleted from) or image handler count is wrong
        if imagesChanged || imageHandler.images.count != tempImages.count {
            imageHandler.setImages(tempImages) { success in
                onCompletion(success)
            }
            imagesChanged = false
        }
        else {
            onCompletion(true)
        }
    }
    
    func setRecipe(_ recipe: Recipe) {
        self.recipe = recipe
        popullateRecipe() { success in
            if !success {
                print("error setting recipe")
            }
        }
    }
    
    // called on saving edit recipe to set saved temps
    func setTempRecipe(_ recipe: Recipe) {
        tempRecipe = recipe
        tempRecipeOriginalServings = recipe.servings
    }
    
    // called on saving edit recipe to set saved temps
    func setTempRecipe(name: String, tempIngredients: [TempIngredient], directions: [Direction], images: [RecipeImage], servings: String, source: String) {
        let ingredients = Ingredient.toIngredients(tempIngredients)
        tempRecipe = Recipe(id: recipe.id, name: name, ingredients: ingredients, directions: directions, images: images, servings: servings.toInt(), source: source, recipeCategoryId: recipe.recipeCategoryId)
        tempRecipeOriginalServings = servings.toInt()
    }
    
    // MARK: - Recipe Modifiers
        
    // called by saving an edit recipe, updates recipe in db and in local store
    func updateRecipe(withId id: String, name: String, ingredients: [Ingredient], directions: [Direction], images: [RecipeImage], servings: String, source: String, categoryId: String, onCompletion: @escaping (Bool) -> Void) {
        updateRecipeMiddle(forCategoryId: categoryId, id: id, name: name, ingredients: ingredients, directions: directions, images: images, servings: servings, source: source, oldRecipe: self.recipe, onCompletion: onCompletion)
    }
    
    // called by updateRecipe above
    // updates recipe given temp ingredients
    func updateRecipeMiddle(forCategoryId categoryId: String, id: String, name: String, ingredients: [Ingredient], directions: [Direction], images: [RecipeImage], servings: String, source: String, oldRecipe recipe: Recipe, onCompletion: @escaping (Bool) -> Void) {
        let ingredients = Ingredient.toIngredients(ingredients)
        
        updateRecipe(forCategoryId: categoryId, id: id, name: name, ingredients: ingredients, directions: directions, images: images, servings: servings, source: source, oldRecipe: recipe) { updatedRecipe in
            if let updatedRecipe = updatedRecipe {
                self.setTempRecipe(updatedRecipe)
                
                let updatedRecipeVM = self
                updatedRecipeVM.recipe = updatedRecipe
                // updates recipe store
                self.collection?.recipesStore[id] = updatedRecipeVM
                // updates category store
                self.collection?.removeRecipeFromStoreCategory(updatedRecipe)
                self.collection?.addRecipeToStore(updatedRecipe, toCategoryId: categoryId)
                onCompletion(true)
            }
            else {
                onCompletion(false)
            }
        }
    }
    
    // called by updateRecipe above, updates recipe given ingredients
    func updateRecipe(forCategoryId categoryId: String, id: String, name: String, ingredients: [Ingredient], directions: [Direction], images: [RecipeImage], servings: String, source: String, oldRecipe recipe: Recipe, onCompletion: @escaping (Recipe?) -> Void) {
        var updateSuccess = true
        var updatedRecipe = recipe
        // is this group ok? enter and leave, hits each once?
        let recipeGroup = DispatchGroup()
        
        recipeGroup.enter()
        RecipeDB.shared.updateRecipe(withId: id, name: name, servings: servings.toInt(), source: source, recipeCategoryId: categoryId) { success in
            recipeGroup.leave()
        }
        
        recipeGroup.enter()
        RecipeDB.shared.updateDirections(withRecipeId: id, directions: directions, oldRecipe: recipe) { success in
            if !success {
                updateSuccess = false
            }
            recipeGroup.leave()
        }
        
        recipeGroup.enter()
        RecipeDB.shared.updateIngredients(withRecipeId: id, ingredients: ingredients, oldRecipe: recipe) { updatedIngredients in
            if updatedIngredients.count == 0 {
                updateSuccess = false
            }
            else {
                updatedRecipe.ingredients = updatedIngredients
            }
            recipeGroup.leave()
        }
        
        recipeGroup.enter()
        RecipeDB.shared.updateImages(withRecipeId: id, images: images, oldRecipe: recipe) { success in
            if !success {
                updateSuccess = false
            }
            recipeGroup.leave()
        }
        
        recipeGroup.notify(queue: .main) {
            if updateSuccess {
                onCompletion(updatedRecipe)
            }
            else {
                onCompletion(nil)
            }
        }
    }
    
    // called by drag and drop recipe to different category and
    // moving recipe to different category in recipe view
    // updates recipe categoryId in db and in local store
    func moveRecipe(toCategoryId categoryId: String) {
        RecipeVM.moveRecipe(self.recipe, toCategoryId: categoryId)
        category?.popullateRecipes() { success in
            if !success {
                print("error popullating recipes")
            }

            // update categories and recipes store, moves recipe to new category
            self.collection?.moveRecipeInStore(self.recipe, toCategoryId: categoryId)
        }
        // TODO remove
//        if let category = category?.collection.getCategory(withId: categoryId) {
//            category.popullateRecipes() { success in
//                if !success {
//                    print("error popullating recipes")
//                }
//            }
//        }
    }
    
    // called by member moveRecipe and moving recipe from public recipe view to permanent recipes
    // don't need to update local store because the recipe will be put in local store on init in recipe book
    static func moveRecipe(_ recipe: Recipe, toCategoryId categoryId: String) {
        RecipeDB.shared.updateRecipe(withId: recipe.id, name: recipe.name, servings: recipe.servings, source: recipe.source, recipeCategoryId: categoryId) { success in
            if !success {
                print("error moving recipe")
            }
        }
    }
    
    // MARK: - Temporary for Editing
    
    func addTempDirection(_ direction: String) {
        tempDirections.append(Direction(step: tempDirections.count, recipeId: recipe.id, direction: direction))
        tempRecipe.directions.append(Direction(step: tempDirections.count, recipeId: recipe.id, direction: direction))
    }
    
    func removeTempDirection(at index: Int) {
        tempDirections.remove(at: index)
        tempRecipe.directions.remove(at: index)
    }
    
    func addTempIngredient(_ ingredientString: String) {
        tempIngredients.append(TempIngredient(ingredientString: ingredientString, recipeId: recipe.id, id: nil))
        tempRecipe.ingredients.append(Ingredient(ingredientString: ingredientString, recipeId: recipe.id))
    }
    
    func addTempIngredient(name: String, amount: String, unit: String) {
        tempIngredients.append(TempIngredient(name: name, amount: amount, unitName: unit, recipeId: recipe.id, id: nil))
        let ing = Ingredient(name: name, amount: amount, unitName: unit, recipeId: recipe.id)
        tempRecipe.ingredients.append(ing)
    }
    
    func removeTempIngredient(at index: Int) {
        tempIngredients.remove(at: index)
        tempRecipe.ingredients.remove(at: index)
    }
    
    static func toRecipeImage(fromURL url: URL, withRecipeId recipeId: String) -> RecipeImage {
        return RecipeImage(type: ImageType.url, data: url.absoluteString, recipeId: recipeId)
    }
    
    func addTempImage(url: URL?) {
        if let url = url {
            let image = RecipeVM.toRecipeImage(fromURL: url, withRecipeId: recipe.id)
            tempImages.append(image)
            tempRecipe.images.append(image)
            imageHandler.addImage(url: url)
        }
    }
    
    static func toRecipeImage(fromUIImage uiImage: UIImage, withRecipeId recipeId: String) -> RecipeImage? {
        if let imageData = ImageHandler.encodeImage(uiImage) {
            return RecipeImage(type: ImageType.uiImage, data: imageData, recipeId: recipeId)
        }
        return nil
    }
    
    func addTempImage(uiImage: UIImage) {
        // resize image
        if let resizedImage = uiImage.resized(toWidth: ImageHandler.pictureWidth, toHeight: ImageHandler.pictureHeight) {
            if let image = RecipeVM.toRecipeImage(fromUIImage: resizedImage, withRecipeId: recipe.id) {
                tempImages.append(image)
                tempRecipe.images.append(image)
                imageHandler.addImage(uiImage: uiImage)
                imagesChanged = true
            }
        }
    }
    
    func removeTempImage(at index: Int) {
        tempImages.remove(at: index)
        tempRecipe.images.remove(at: index)
        imageHandler.removeImage(at: index)
        imagesChanged = true
    }
    
    // creates ingredient from given name, amount, unit in strings
    func makeIngredient(name: String, amount: String, unit: String) -> Ingredient {
        return Ingredient.makeIngredient(name: name, amount: amount, unit: unit)
    }
    
    // MARK: - Transcribe images to recipes
    
    func transcribeRecipe(fromImage image: UIImage) {
        transcriber.createTranscription(fromImage: image)
    }
    
    func transcribeRecipe(fromUrlString urlString: String) {
        self.isImportingFromURL = true
        transcriber.createTranscription(fromUrlString: urlString)
    }
}

extension String {
    func toInt() -> Int {
        let formatter = NumberFormatter()
        return formatter.number(from: self)!.intValue
    }
}

extension Int {
    func toString() -> String {
        let formatter = NumberFormatter()
        return formatter.string(from: self as NSNumber)!
    }
}
