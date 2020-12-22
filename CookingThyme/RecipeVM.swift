//
//  RecipeVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import Foundation
import Combine
import SwiftUI

class RecipeVM: ObservableObject {
    var category: RecipeCategoryVM
    @Published var recipe: Recipe
    @Published var tempDirections: [Direction] = []
    @Published var tempIngredients: [TempIngredient] = []
    @Published var tempImages: [RecipeImage] = []
    @Published var recipeText: String?
    
    @Published var imageHandler = ImageHandler()
    private var imageHandlerCancellable: AnyCancellable?
    
    @Published var transcriber = RecipeTranscriber()
    private var recipeTranscriberCancellable: AnyCancellable?
    
    // MARK: - Init
    
    init(recipe: Recipe, category: RecipeCategoryVM) {
        self.recipe = recipe
        self.category = category
        self.imageHandlerCancellable = self.imageHandler.objectWillChange
            .sink { _ in
                self.objectWillChange.send()
            }
        
        self.recipeTranscriberCancellable = self.transcriber.$recipeText
            .sink { (recipeText) in
                self.recipeText = recipeText
            }
        
        popullateRecipe()
    }
    
    init(category: RecipeCategoryVM) {
        self.recipe = Recipe()
        self.category = category
        
        self.imageHandlerCancellable = self.imageHandler.objectWillChange
            .sink { _ in
                self.objectWillChange.send()
            }
        
        self.recipeTranscriberCancellable = self.transcriber.$recipeText
            .sink { (recipeText) in
                self.recipeText = recipeText
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
    
    // MARK: - Intents
    
    // gets recipe, directions, ingredients, and images from db
    func popullateRecipe() {
        if let recipeWithDirections = RecipeDB.shared.getDirections(forRecipe: recipe, withId: recipe.id) {
            if let recipeWithIngredients = RecipeDB.shared.getIngredients(forRecipe: recipeWithDirections, withId: recipe.id) {
                if let recipeWithImages = RecipeDB.shared.getImages(forRecipe: recipeWithIngredients, withRecipeId: recipe.id) {
                    recipe = recipeWithImages
                    self.tempDirections = recipe.directions
                    self.tempIngredients = Ingredient.toTempIngredients(recipe.ingredients)
                    self.tempImages = recipe.images
                    popullateImages()
                }
            }
        }
    }
    
    // sends images to image handler to prep for ui
    func popullateImages() {
        imageHandler.setImages(tempImages)
    }
    
    // gets recipe from db
    func refreshRecipe() {
        if let recipe = RecipeDB.shared.getRecipe(byId: recipe.id) {
            self.recipe = recipe
            popullateRecipe()
        }
    }
    
    // update recipe to given recipe parts
    func updateRecipe(withId id: Int, name: String, tempIngredients: [TempIngredient], directions: [Direction], images: [RecipeImage], servings: String) {
        category.deleteRecipe(withId: id)
        if let recipe = category.createRecipe(name: name, tempIngredients: tempIngredients, directions: directions, images: images, servings: servings) {
            self.recipe = recipe
            refreshRecipe()
        }
    }
    
    // TODO: no duplicate recipes, just move
    func copyRecipe(toCategoryId categoryId: Int) {
        RecipeVM.copy(recipe: self.recipe, toCategoryId: categoryId)
    }
    
    static func copy(recipe: Recipe, toCategoryId categoryId: Int) {
        if let category = RecipeDB.shared.getCategory(withId: categoryId) {
            let recipe = RecipeCategoryVM.createRecipe(forCategoryId: category.id, name: recipe.name, ingredients: recipe.ingredients, directions: recipe.directions, images: recipe.images, servings: recipe.servings.toString())
            if recipe == nil {
                print("error copying recipe")
            }
        }
    }
    
    // - Temporary for Editing
    
    func addTempDirection(_ direction: String) {
        tempDirections.append(Direction(step: tempDirections.count, recipeId: recipe.id, direction: direction))
    }
    
    func removeTempDirection(at index: Int) {
        tempDirections.remove(at: index)
    }
    
    func addTempIngredient(name: String, amount: String, unit: String) {
        tempIngredients.append(TempIngredient(name: name, amount: amount, unitName: unit, recipeId: recipe.id, id: nil))
    }
    
    func removeTempIngredient(at index: Int) {
        tempIngredients.remove(at: index)
    }
    
    func addTempImage(url: URL?) {
        if let url = url {
            tempImages.append(RecipeImage(type: ImageType.url, data: url.absoluteString, recipeId: recipe.id))
            imageHandler.addImage(url: url)
        }
    }
    
    func addTempImage(uiImage: UIImage) {
        if let imageData = imageHandler.encodeImage(uiImage) {
            tempImages.append(RecipeImage(type: ImageType.uiImage, data: imageData, recipeId: recipe.id))
            imageHandler.addImage(uiImage: uiImage)
        }
    }
    
    func removeTempImage(at index: Int) {
        tempImages.remove(at: index)
        imageHandler.removeImage(at: index)
    }

    
    // TODO make more robust, servings is initialized to 0 but cannot be zero once created
    func isCreatingRecipe() -> Bool {
        return recipe.servings == 0
    }
    
    // creates ingredient from given name, amount, unit in strings
    func makeIngredient(name: String, amount: String, unit: String) -> Ingredient {
        let doubleAmount = Fraction.toDouble(fromString: amount)
        let unit = Ingredient.makeUnit(fromUnit: unit)
        return Ingredient(name: name, amount: doubleAmount, unitName: unit)
    }
    
    // transcribe images to recipes
    
    func transcribeRecipe(fromImage image: UIImage) {
        transcriber.transcribe(uiImage: image)
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
