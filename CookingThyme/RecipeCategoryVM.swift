//
//  RecipeCategoryVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/24/20.
//

import Foundation
import Combine
import SwiftUI

class RecipeCategoryVM: ObservableObject, Hashable {
    static func == (lhs: RecipeCategoryVM, rhs: RecipeCategoryVM) -> Bool {
        return lhs.category == rhs.category
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(category.hashValue)
    }
    
    var collection: RecipeCollectionVM
    @Published var category: RecipeCategory
    @Published var recipes: [Recipe]
    
    @Published var imageHandler = ImageHandler()
    private var imageHandlerCancellable: AnyCancellable?

    init(category: RecipeCategory, collection: RecipeCollectionVM) {
        self.category = category
        self.collection = collection
        recipes = []
        
        self.imageHandlerCancellable = self.imageHandler.objectWillChange
            .sink { _ in
                self.objectWillChange.send()
            }
        
        popullateRecipes()
    }
    
    // MARK: - Model Access
    
    var id: Int {
        category.id
    }
    
    var name: String {
        category.name
    }
    
    // MARK: - Intents
    
    // gets recipes of category from db
    func popullateRecipes() {
        if category.name == "All" {
            self.recipes = RecipeDB.shared.getAllRecipes(withCollectionId: collection.id)
        }
        else {
            self.recipes = RecipeDB.shared.getRecipes(byCategoryId: category.id)
        }
        popullateImage()
    }
    
    func popullateImage() {
        if let image = RecipeDB.shared.getImage(withCategoryId: id) {
            imageHandler.setImage(image)
        }
    }
    
    // sets first image found in the recipes of the category as the category image
    func setDefaultImage(_ image: RecipeImage) {
        if imageHandler.image == nil {
            RecipeDB.shared.createImage(image, withCategoryId: id)
            popullateImage()
        }
    }
    
    func addImage(_ image: RecipeImage, withURL url: URL) {
        setDefaultImage(image)
        imageHandler.addImage(url: url)
    }
    
    func addImage(_ image: RecipeImage, withUIImage uiImage: UIImage) {
        setDefaultImage(image)
        imageHandler.addImage(uiImage: uiImage)
    }
    
    // TODO should remove image if it is the category image if was removed from recipe?
    func removeImage(at index: Int) {
//        imageHandler.removeImage(at: index)
    }
    
    // gets category from db
    func refreshCategory() {
        if let category = RecipeDB.shared.getCategory(withId: category.id) {
            self.category = category
            popullateRecipes()
        }
    }
    
    // creates recipe for given category with given parts
    static func createRecipe(forCategoryId categoryId: Int, name: String, ingredients: [Ingredient], directions: [Direction], images: [RecipeImage], servings: String) -> Recipe? {
        var createdRecipe: Recipe?
        if let recipe = RecipeDB.shared.createRecipe(name: name, servings: servings.toInt(), recipeCategoryId: categoryId) {
            createdRecipe = recipe
            RecipeDB.shared.createDirections(directions: directions, withRecipeId: recipe.id)
            RecipeDB.shared.createIngredients(ingredients: ingredients, withRecipeId: recipe.id)
            RecipeDB.shared.createImages(images: images, withRecipeId: recipe.id)
        }
        return createdRecipe
    }
    
    // creates recipe with given partss
    func createRecipe(name: String, tempIngredients: [TempIngredient], directions: [Direction], images: [RecipeImage], servings: String) -> Recipe? {
        var createdRecipe: Recipe?
        let ingredients = Ingredient.toIngredients(tempIngredients)
        if let recipe = RecipeCategoryVM.createRecipe(forCategoryId: category.id, name: name, ingredients: ingredients, directions: directions, images: images, servings: servings) {
            createdRecipe = recipe
            popullateRecipes()
        }
        return createdRecipe
    }
    
    // deletes recipe and associated parts
    func deleteRecipe(withId id: Int) {
        RecipeDB.shared.deleteRecipe(withId: id)
        RecipeDB.shared.deleteDirections(withRecipeId: id)
        RecipeDB.shared.deleteIngredients(withRecipeId: id)
        RecipeDB.shared.deleteImages(withRecipeId: id)
        popullateRecipes()
    }
    
    // updates category name
    func updateCategory(toName name: String) {
        collection.updateCategory(forCategoryId: category.id, toName: name)
        refreshCategory()
    }
}
