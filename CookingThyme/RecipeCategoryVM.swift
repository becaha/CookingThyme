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
    
    private var categoryGroup: DispatchGroup?

    init(category: RecipeCategory, collection: RecipeCollectionVM) {
        self.category = category
        self.collection = collection
        recipes = []
        
        self.imageHandlerCancellable = self.imageHandler.objectWillChange
            .sink { _ in
                self.objectWillChange.send()
            }
        
        // initialized when collection.popullateCategories
//        if let foundCategoryVM = self.collection.categoriesStore[category.id] {
//            self.recipes = foundCategoryVM.recipes
//            self.imageHandler = foundCategoryVM.imageHandler
//            return
//        }
        
        popullateCategory() { success in
            if success {
                collection.categoriesStore[category.id] = self
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
    
    func popullateCategory(onCompletion: @escaping (Bool) -> Void) {
        var popullateSuccess = true
        self.categoryGroup = DispatchGroup()
        
        categoryGroup!.enter()
        popullateRecipes() { success in
            if !success {
                print("error popullating recipe")
                popullateSuccess = false
            }
            if self.categoryGroup != nil {
                self.categoryGroup!.leave()
            }
        }
        
        categoryGroup!.enter()
        popullateImage() { success in
            if !success {
                print("error popullating image")
                popullateSuccess = false
            }
            if self.categoryGroup != nil {
                self.categoryGroup!.leave()
            }
        }
        
        categoryGroup!.notify(queue: .main) {
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
    
    func popullateImage(onCompletion: @escaping (Bool) -> Void) {
        RecipeDB.shared.getImage(withCategoryId: id) { image in
            if let image = image {
                self.imageHandler.setImages([image]) { success in
                    if !success {
                        print("error popullating image")
                    }
                    onCompletion(success)
                    return
                }
            }
            onCompletion(true)
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
        if let image = RecipeVM.toRecipeImage(fromUIImage: uiImage, withRecipeId: Recipe.defaultId) {
            var recipeImage = image
            recipeImage.recipeId = nil
            recipeImage.categoryId = id
            setImage(recipeImage, replace: true)
        }
    }
    
    // replaces category image if exists and sends image to be created by createImage
    private func setImage(_ image: RecipeImage, replace: Bool) {
        if imageHandler.image == nil {
            createImage(image)
        }
        else if replace == true {
            RecipeDB.shared.deleteImage(withCategoryId: id)
            createImage(image)
        }
    }
    
    // creates image in db and sets images in ui by image handler
    private func createImage(_ image: RecipeImage) {
        RecipeDB.shared.createImage(image, withCategoryId: id)
        self.imageHandler.setImages([image]) { success in
            if !success {
                print("error creating image")
            }
            // update category store
            self.updateCategoriesStore()
        }
    }
    
    private func updateCategoriesStore() {
        self.collection.categoriesStore[self.id] = self
    }
    
    // called by ui to remove category image, removes in db and ui by image handler
    func removeImage() {
        RecipeDB.shared.deleteImage(withCategoryId: id)
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
    
    // updates recipe given temp ingredients
    static func updateRecipe(forCategoryId categoryId: String, id: String, name: String, tempIngredients: [TempIngredient], directions: [Direction], images: [RecipeImage], servings: String, source: String, oldRecipe recipe: Recipe, onCompletion: @escaping (Bool) -> Void) {
        let ingredients = Ingredient.toIngredients(tempIngredients)
        updateRecipe(forCategoryId: categoryId, id: id, name: name, ingredients: ingredients, directions: directions, images: images, servings: servings, source: source, oldRecipe: recipe, onCompletion: onCompletion)
    }
    
    // updates recipe given ingredients
    static func updateRecipe(forCategoryId categoryId: String, id: String, name: String, ingredients: [Ingredient], directions: [Direction], images: [RecipeImage], servings: String, source: String, oldRecipe recipe: Recipe, onCompletion: @escaping (Bool) -> Void) {
        var updateSuccess = true
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
        RecipeDB.shared.updateIngredients(withRecipeId: id, ingredients: ingredients, oldRecipe: recipe) { success in
            if !success {
                updateSuccess = false
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
                onCompletion(updateSuccess)
            }
            else {
                onCompletion(false)
            }
        }
    }
    
    // called by ui by saving in edit recipe (by actually creating new recipe)
    // creates recipe with given parts
    func createRecipe(name: String, tempIngredients: [TempIngredient], directions: [Direction], images: [RecipeImage], servings: String, source: String, onCreation: @escaping (Recipe?) -> Void) {
        // update categories store
//        let updatedCategory = collection.categoriesStore[category.id]
//        updatedCategory.recipes.append(recipe)
//        collection.categoriesStore[category.id] = updatedCategory
        
        RecipeCategoryVM.createRecipe(forCategoryId: category.id, name: name, tempIngredients: tempIngredients, directions: directions, images: images, servings: servings, source: source) { recipe in
            onCreation(recipe)
            return
//            popullateRecipes()
//            popullateImage()
        }
//        collection.refreshCurrrentCategory()
        onCreation(nil)
    }
    
    // called by createRecipe above
    // creates recipe given temp ingredients
    static func createRecipe(forCategoryId categoryId: String, name: String, tempIngredients: [TempIngredient], directions: [Direction], images: [RecipeImage], servings: String, source: String, onCreation: @escaping (Recipe?) -> Void) {
        let ingredients = Ingredient.toIngredients(tempIngredients)
        return createRecipe(forCategoryId: categoryId, name: name, ingredients: ingredients, directions: directions, images: images, servings: servings, source: source, onCreation: onCreation)
    }
    
    // called by createRecipe above and RecipeVM.copy
    // creates recipe given ingredients, recipe created by user, no source
    static func createRecipe(forCategoryId categoryId: String, name: String, ingredients: [Ingredient], directions: [Direction], images: [RecipeImage], servings: String, source: String, onCreation: @escaping (Recipe?) -> Void) {
        RecipeDB.shared.createRecipe(name: name, servings: servings.toInt(), source: source, recipeCategoryId: categoryId) { recipe in
            if let recipe = recipe {
                RecipeDB.shared.createDirections(directions: directions, withRecipeId: recipe.id)
                RecipeDB.shared.createIngredients(ingredients: ingredients, withRecipeId: recipe.id)
                RecipeDB.shared.createImages(images: images, withRecipeId: recipe.id)
                onCreation(recipe)
            }
            else {
                onCreation(nil)
            }
        }
    }
    
//    // deletes recipe and associated parts
//    func deleteRecipe(withId id: String) {
//        RecipeCategoryVM.deleteRecipe(withId: id)
//        // TODO update categories store
//        // need this for recipe on delete to disappear
//        popullateRecipes() { success in
//            if !success {
//                print("error popullating recipes")
//            }
//        }
////        popullateImage()
//    }
//    
//    static func deleteRecipe(withId id: String) {
//        RecipeDB.shared.deleteRecipe(withId: id)
//        RecipeDB.shared.deleteDirections(withRecipeId: id)
//        RecipeDB.shared.deleteIngredients(withRecipeId: id)
//        RecipeDB.shared.deleteImages(withRecipeId: id)
//    }
}
