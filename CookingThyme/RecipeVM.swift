//
//  RecipeVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation
import Combine
import SwiftUI

// TODO: everything on background threed
class RecipeVM: ObservableObject {
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
    
    private var webHandlerCancellable: AnyCancellable?
    private var recipeDetailCancellable: AnyCancellable?
    private var recipeDetailErrorCancellable: AnyCancellable?
    
    var originalServings: Int = 0

    private var recipeTranscriberCancellable: AnyCancellable?
    private var recipeTextTranscriberCancellable: AnyCancellable?

    // MARK: - Init
    
    // inits recipe in a category
    init(recipe: Recipe, category: RecipeCategoryVM) {
        self.recipe = recipe
        
        self.category = category
        setCancellables()
        
        popullateRecipe()
        popullateImages()
    }
    
    // inits a create new recipe in a category
    init(category: RecipeCategoryVM) {
        self.recipe = Recipe()
        self.category = category
        
        setCancellables()
    }
    
    // inits a public recipe from search
    init(recipe: Recipe) {
        self.recipe = recipe
        
        setCancellables()
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
                    self.popullateRecipeTemps()
                    self.isImportingFromURL = false
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
                self.imageHandler.setImages(self.recipe.images)
                self.isPopullating = false
            }
        }
        
        self.recipeDetailErrorCancellable = self.recipesWebHandler.$recipeDetailError.sink { (isError) in
            self.recipeNotFound = isError
        }
    }
    
    // MARK: - Model Access
    
    var id: Int {
        Int(recipe.id)
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
    
    var categoryId: Int {
        recipe.recipeCategoryId
    }
    
    // MARK: - Intents
    
    // MARK: - Public Recipe
    
    // calls api to get detail of a recipe (its parts)
    func popullateDetail() {
        recipesWebHandler.listRecipeDetail(recipe)
    }
    
    // copies recipe to category of user's collection
    func copyRecipe(toCategoryId categoryId: Int, inCollection collection: RecipeCollectionVM) {
        RecipeVM.copy(recipe: self.recipe, toCategoryId: categoryId, inCollection: collection)
    }
    
    // MARK: - Recipe
    
    // gets recipe, directions, ingredients, and images from db
    func popullateRecipe() {
        if let recipeWithDirections = RecipeDB.shared.getDirections(forRecipe: recipe, withId: recipe.id) {
            if let recipeWithIngredients = RecipeDB.shared.getIngredients(forRecipe: recipeWithDirections, withId: recipe.id) {
                if let recipeWithImages = RecipeDB.shared.getImages(forRecipe: recipeWithIngredients, withRecipeId: recipe.id) {
                    recipe = recipeWithImages
                    popullateRecipeTemps()
                }
            }
        }
    }
    
    func popullateRecipeTemps() {
        self.originalServings = recipe.servings
        self.tempDirections = recipe.directions
        self.tempIngredients = Ingredient.toTempIngredients(recipe.ingredients)
        self.tempImages = recipe.images
    }
    
    // sends images to image handler to prep for ui
    func popullateImages() {
        imageHandler.setImages(tempImages)
    }
    
    func setRecipe(_ recipe: Recipe) {
        self.recipe = recipe
        popullateRecipe()
    }
    
    // gets recipe from db
    func refreshRecipe() {
        if let recipe = RecipeDB.shared.getRecipe(byId: recipe.id) {
            self.recipe = recipe
            popullateRecipe()
        }
    }
    
    
    func updateRecipe(withId id: Int, name: String, tempIngredients: [TempIngredient], directions: [Direction], images: [RecipeImage], servings: String, source: String, categoryId: Int) {
        if RecipeCategoryVM.updateRecipe(forCategoryId: categoryId, id: id, name: name, tempIngredients: tempIngredients, directions: directions, images: images, servings: servings, source: source, oldRecipe: self.recipe) {
            refreshRecipe()
        }
        
        category!.refreshCategory()
    }
    
    func moveRecipe(toCategoryId categoryId: Int) {
        RecipeVM.moveRecipe(self.recipe, toCategoryId: categoryId)
    }
    
    static func moveRecipe(_ recipe: Recipe, toCategoryId categoryId: Int) {
        if !RecipeDB.shared.updateRecipe(withId: recipe.id, name: recipe.name, servings: recipe.servings, source: recipe.source, recipeCategoryId: categoryId) {
            print("error moving recipe")
        }
    }
    
    static func copy(recipe: Recipe, toCategoryId categoryId: Int, inCollection collection: RecipeCollectionVM) {
        if let category = collection.getCategory(withId: categoryId) {
            let recipe = RecipeCategoryVM.createRecipe(forCategoryId: category.id, name: recipe.name, ingredients: recipe.ingredients, directions: recipe.directions, images: recipe.images, servings: recipe.servings.toString(), source: recipe.source)
            if recipe == nil {
                print("error copying recipe")
            }
            collection.refreshCurrrentCategory()
        }
    }
    
    // - Temporary for Editing
    
    func addTempDirection(_ direction: String) {
        tempDirections.append(Direction(step: tempDirections.count, recipeId: recipe.id, direction: direction))
    }
    
    func removeTempDirection(at index: Int) {
        tempDirections.remove(at: index)
    }
    
    func addTempIngredient(_ ingredientString: String) {
        tempIngredients.append(TempIngredient(ingredientString: ingredientString, recipeId: recipe.id, id: nil))
    }
    
    func addTempIngredient(name: String, amount: String, unit: String) {
        tempIngredients.append(TempIngredient(name: name, amount: amount, unitName: unit, recipeId: recipe.id, id: nil))
    }
    
    func removeTempIngredient(at index: Int) {
        tempIngredients.remove(at: index)
    }
    
    static func toRecipeImage(fromURL url: URL, withRecipeId recipeId: Int) -> RecipeImage {
        return RecipeImage(type: ImageType.url, data: url.absoluteString, recipeId: recipeId)
    }
    
    func addTempImage(url: URL?) {
        if let url = url {
            let image = RecipeVM.toRecipeImage(fromURL: url, withRecipeId: recipe.id)
            tempImages.append(image)
            imageHandler.addImage(url: url)
        }
    }
    
    static func toRecipeImage(fromUIImage uiImage: UIImage, withRecipeId recipeId: Int) -> RecipeImage? {
        if let imageData = ImageHandler.encodeImage(uiImage) {
            return RecipeImage(type: ImageType.uiImage, data: imageData, recipeId: recipeId)
        }
        return nil
    }
    
    func addTempImage(uiImage: UIImage) {
        if let image = RecipeVM.toRecipeImage(fromUIImage: uiImage, withRecipeId: recipe.id) {
            tempImages.append(image)
            imageHandler.addImage(uiImage: uiImage)
        }
    }
    
    func removeTempImage(at index: Int) {
        tempImages.remove(at: index)
        imageHandler.removeImage(at: index)
    }

    func isCreatingRecipe() -> Bool {
        return recipe.id == 0
    }
    
    // creates ingredient from given name, amount, unit in strings
    func makeIngredient(name: String, amount: String, unit: String) -> Ingredient {
        return Ingredient.makeIngredient(name: name, amount: amount, unit: unit)
    }
    
    // transcribe images to recipes
    
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
