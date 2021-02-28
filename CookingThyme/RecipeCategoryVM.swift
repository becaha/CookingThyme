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
    
    // these are unpopullated recipes (only id, name, servings, recipeCategoryId, source)
    @Published var recipes: [Recipe] {
        didSet {
            filteredRecipes = recipes
        }
    }
    @Published var filteredRecipes: [Recipe] = []
    
    @Published var imageHandler = ImageHandler()
    private var imageHandlerCancellable: AnyCancellable?
    private var imageHandlerLoadingCancellable: AnyCancellable?

    private var categoryGroup: DispatchGroup?

    init(category: RecipeCategory, collection: RecipeCollectionVM, onCompletion: @escaping (Bool) -> Void) {
        self.category = category
        self.collection = collection
        recipes = []
        
        self.imageHandlerCancellable = self.imageHandler.objectWillChange
            .sink { _ in
                self.objectWillChange.send()
            }
        
        self.imageHandlerLoadingCancellable = self.imageHandler.$loadingImages.sink(receiveValue: { (loadingImages) in
            if !loadingImages {
                self.updateCategoriesStore()
            }
        })
        
        // initialized when collection.popullateCategories
//        if let foundCategoryVM = self.collection.categoriesStore[category.id] {
//            self.recipes = foundCategoryVM.recipes
//            self.imageHandler = foundCategoryVM.imageHandler
//            return
//        }
        
        popullateCategory() { success in
            if success {
                collection.categoriesStore[category.id] = self
                onCompletion(true)
            }
            else {
                onCompletion(false)
            }
        }
    }
    
    // MARK: - Model Access
    
    var id: String {
        category.id
    }
    
    var name: String {
        category.name
    }
    
    // MARK: - DB Loaders
    
    func sortRecipes(recipeA: Recipe, _ recipeB: Recipe) -> Bool {
        recipeA.name < recipeB.name
    }
    
    func popullateCategory(onCompletion: @escaping (Bool) -> Void) {
        let store = self.collection.categoriesStore[category.id]
        // check for category in category store
        if let foundCategoryVM = self.collection.categoriesStore[category.id] {
            self.recipes = foundCategoryVM.recipes.sorted(by: { (recipeA, recipeB) -> Bool in
                recipeA.name < recipeB.name
            })
            // popullate image
            self.imageHandler = foundCategoryVM.imageHandler
            onCompletion(true)
            return
        }
        
        var popullateSuccess = true
        self.categoryGroup = DispatchGroup()
        
        categoryGroup?.enter()
        popullateRecipes() { success in
            if !success {
                print("error popullating recipe")
                popullateSuccess = false
            }
            if self.categoryGroup != nil {
                self.categoryGroup?.leave()
            }
        }
        
        popullateImage()
        
        categoryGroup?.notify(queue: .main) {
            onCompletion(popullateSuccess)
            self.categoryGroup = nil
        }
    }

    // gets recipes of category from db
    func popullateRecipes(onCompletion: @escaping (Bool) -> Void) {
        if category.name == "All" {
            collection.popullateAllRecipes() { success in
                if success {
                    self.recipes = self.collection.allRecipes
                    onCompletion(true)
                }
                else {
                    onCompletion(false)
                }
            }
        }
        else {
            RecipeDB.shared.getRecipes(byCategoryId: category.id) { recipes in
                var sortedRecipes = recipes

                sortedRecipes.sort { (recipeA, recipeB) -> Bool in
                    return recipeA.name < recipeB.name
                }
                
                self.recipes = sortedRecipes
                onCompletion(true)
            }
        }
    }
    
    func popullateImage() {
        RecipeDB.shared.getImage(withCategoryId: id) { image in
            if let image = image {
                self.imageHandler.setImages([image])
            }
        }
    }
    
    // gets category from db
    func refreshCategory() {
//        RecipeDB.shared.getCategory(withId: category.id) { category in
//            if let category = category {
//                self.category = category
//                self.popullateCategory()
//            }
//        }
//        collection.refreshCurrrentCategory()
    }
    
    // MARK: - Intents
    
    private func updateCategoriesStore() {
        if let category = self.collection.categoriesStore[self.id] {
            self.collection.categoriesStore[self.id] = self
        }
    }
    
    // updates category name
    func updateCategory(toName name: String) {
        collection.updateCategory(forCategoryId: category.id, toName: name)
        
//        refreshCategory()
        // updates category store
        self.updateCategoriesStore()
    }
    
    // MARK: - Image

    // called from ui to set category image from pasted url
    func setImage(url: URL?) {
        if let url = url {
            var image = RecipeVM.toRecipeImage(fromURL: url, withRecipeId: Recipe.defaultId)
            image.recipeId = nil
            image.categoryId = id
            setImage(image, replace: true)
        }
    }

    // called from ui to set category image from selected ui image
    func setImage(uiImage: UIImage) {
        // reduce size
        if let resizedImage = uiImage.resized(toWidth: ImageHandler.pictureWidth, toHeight: ImageHandler.pictureHeight) {
            if let image = RecipeVM.toRecipeImage(fromUIImage: resizedImage, withRecipeId: Recipe.defaultId) {
                var recipeImage = image
                recipeImage.recipeId = nil
                recipeImage.categoryId = id
                setImage(recipeImage, replace: true)
            }
        }
    }
    
    // replaces category image if exists and sends image to be created by createImage
    private func setImage(_ image: RecipeImage, replace: Bool) {
        if imageHandler.image == nil {
            createImage(image)
        }
        else if replace == true {
            RecipeDB.shared.deleteImage(withCategoryId: id)  { success in
                if !success {
                    print("error")
                }
            }
            createImage(image)
        }
    }
    
    // creates image in db and sets images in ui by image handler, updates category store
    private func createImage(_ image: RecipeImage) {
        RecipeDB.shared.createImage(image, withCategoryId: id)
        self.imageHandler.setImages([image])
    }
    
    // called by ui to remove category image, removes in db and ui by image handler
    func removeImage() {
        RecipeDB.shared.deleteImage(withCategoryId: id) { success in
            if !success {
                print("error")
            }
        }
        imageHandler.removeImage(at: 0)
        // update category store
        self.updateCategoriesStore()
    }
    
    // MARK: - Recipes
    
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
    
    // called by ui by saving in edit recipe (by actually creating new recipe)
    // creates recipe with given parts in category, updates category store
    func createRecipe(name: String, tempIngredients: [Ingredient], directions: [Direction], images: [RecipeImage], servings: String, source: String, recipeSearchHandler: RecipeSearchHandler, onCreation: @escaping (Recipe?) -> Void) {
        RecipeCategoryVM.createRecipe(forCategoryId: category.id, name: name, tempIngredients: tempIngredients, directions: directions, images: images, servings: servings, source: source) { recipe in
            // updates category store
            if let recipe = recipe {
                // saves new recipe to recipe store
                self.collection.recipesStore[recipe.id] = RecipeVM(recipe: recipe, category: self, collection: self.collection, recipeSearchHandler: recipeSearchHandler)
                
                // saves new recipe to category in category store
                self.collection.addRecipeToStore(recipe, toCategoryId: self.category.id)
                self.collection.updateAllRecipes()
            }
            
            onCreation(recipe)
//            popullateRecipes()
//            popullateImage()
        }
//        collection.refreshCurrrentCategory()
//        onCreation(nil)
    }
    
    // called by createRecipe above
    // creates recipe given temp ingredients
    static func createRecipe(forCategoryId categoryId: String, name: String, tempIngredients: [Ingredient], directions: [Direction], images: [RecipeImage], servings: String, source: String, onCreation: @escaping (Recipe?) -> Void) {
        let ingredients = Ingredient.toIngredients(tempIngredients)
        return createRecipe(forCategoryId: categoryId, name: name, ingredients: ingredients, directions: directions, images: images, servings: servings, source: source, onCreation: onCreation)
    }
    
    // called by createRecipe above and RecipeVM.copy
    // creates recipe given ingredients, recipe created by user, no source
    static func createRecipe(forCategoryId categoryId: String, name: String, ingredients: [Ingredient], directions: [Direction], images: [RecipeImage], servings: String, source: String, onCreation: @escaping (Recipe?) -> Void) {
        RecipeDB.shared.createRecipe(name: name, servings: servings.toInt(), source: source, recipeCategoryId: categoryId) { recipe in
            if let recipe = recipe {
                let recipeGroup = DispatchGroup()
                var updatedRecipe = recipe
                
                recipeGroup.enter()
                RecipeDB.shared.createDirections(directions: directions, withRecipeId: recipe.id) {
                    createdDirections in
                    updatedRecipe.directions = createdDirections
                    recipeGroup.leave()
                }
                
                recipeGroup.enter()
                RecipeDB.shared.createIngredients(ingredients: ingredients, withRecipeId: recipe.id) { createdIngredients in
                    updatedRecipe.ingredients = createdIngredients
                    recipeGroup.leave()
                }
                
                recipeGroup.enter()
                RecipeDB.shared.createImages(images: images, withRecipeId: recipe.id) { createdImages in
                    updatedRecipe.images = createdImages
                    recipeGroup.leave()
                }
                
                recipeGroup.notify(queue: .main) {
                    onCreation(updatedRecipe)
                }
            }
            else {
                onCreation(nil)
            }
        }
    }
}
