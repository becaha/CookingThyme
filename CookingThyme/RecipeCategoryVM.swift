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
    @Published var recipes: [Recipe] {
        didSet {
            filteredRecipes = recipes
        }
    }
    @Published var filteredRecipes: [Recipe] = []
    
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
        
        popullateCategory()
    }
    
    // MARK: - Model Access
    
    var id: Int {
        category.id
    }
    
    var name: String {
        category.name
    }
    
    // MARK: - Intents
    
    func filterRecipes(withSearch search: String) {
        if search == "" {
            self.filteredRecipes = self.recipes
        }
        else {
            self.filteredRecipes = self.recipes.filter({ (recipe) -> Bool in
                recipe.name.localizedCaseInsensitiveContains(search)
            })
        }
    }
    
    // gets recipes of category from db
    func popullateRecipes() {
        if category.name == "All" {
            self.recipes = RecipeDB.shared.getAllRecipes(withCollectionId: collection.id)
        }
        else {
            self.recipes = RecipeDB.shared.getRecipes(byCategoryId: category.id)
        }
        self.recipes.sort { (recipeA, recipeB) -> Bool in
            return recipeA.name < recipeB.name
        }
    }
    
    func popullateImage() {
        if let image = RecipeDB.shared.getImage(withCategoryId: id) {
            imageHandler.setImages([image])
        }
    }
    
    // sets first image found in the recipes of the category as the category image
    func setImage(_ image: RecipeImage, replace: Bool) {
        if imageHandler.image == nil {
            createImage(image)
        }
        else if replace == true {
            RecipeDB.shared.deleteImage(withCategoryId: id)
            createImage(image)
        }
    }
    
    func createImage(_ image: RecipeImage) {
        RecipeDB.shared.createImage(image, withCategoryId: id)
        popullateImage()
    }
    
    func setImage(url: URL?) {
        if let url = url {
            var image = RecipeVM.toRecipeImage(fromURL: url, withRecipeId: 0)
            image.recipeId = nil
            image.categoryId = id
            setImage(image, replace: true)
        }
    }
    
    func setImage(uiImage: UIImage) {
        if let image = RecipeVM.toRecipeImage(fromUIImage: uiImage, withRecipeId: 0) {
            var recipeImage = image
            recipeImage.recipeId = nil
            recipeImage.categoryId = id
            setImage(recipeImage, replace: true)
        }
    }
    
    func addImage(_ image: RecipeImage, withURL url: URL) {
        setImage(image, replace: false)
        imageHandler.addImage(url: url)
    }
    
    func addImage(_ image: RecipeImage, withUIImage uiImage: UIImage) {
        setImage(image, replace: false)
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
            popullateCategory()
        }
    }
    
    func popullateCategory() {
        popullateRecipes()
        popullateImage()
    }
    
    // creates recipe given temp ingredients
    static func createRecipe(forCategoryId categoryId: Int, name: String, tempIngredients: [TempIngredient], directions: [Direction], images: [RecipeImage], servings: String) -> Recipe? {
        let ingredients = Ingredient.toIngredients(tempIngredients)
        return createRecipe(forCategoryId: categoryId, name: name, ingredients: ingredients, directions: directions, images: images, servings: servings)
    }
    
    // creates recipe given ingredients
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
    
    // creates recipe with given parts
    func createRecipe(name: String, tempIngredients: [TempIngredient], directions: [Direction], images: [RecipeImage], servings: String) -> Recipe? {
        var createdRecipe: Recipe?
        if let recipe = RecipeCategoryVM.createRecipe(forCategoryId: category.id, name: name, tempIngredients: tempIngredients, directions: directions, images: images, servings: servings) {
            createdRecipe = recipe
            popullateRecipes()
            popullateImage()
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
        popullateImage()
    }
    
    // updates category name
    func updateCategory(toName name: String) {
        collection.updateCategory(forCategoryId: category.id, toName: name)
        refreshCategory()
    }
}
