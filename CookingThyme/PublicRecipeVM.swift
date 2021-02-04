//
//  PublicRecipeVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/10/20.
//

import Foundation
import Combine

// recipe that comes from the Tasty API
class PublicRecipeVM: ObservableObject {
    @Published var recipe: Recipe
    @Published var recipesWebHandler = RecipeSearchApiHandler()
    @Published var isPopullating = true
    @Published var recipeNotFound = false
    @Published var imageHandler = ImageHandler()

    private var webHandlerCancellable: AnyCancellable?
    private var recipeDetailCancellable: AnyCancellable?
    private var recipeDetailErrorCancellable: AnyCancellable?
    private var imageHandlerCancellable: AnyCancellable?
    
    // MARK: - Init

    init(recipe: Recipe) {
        self.recipe = recipe
        
        self.imageHandlerCancellable = self.imageHandler.objectWillChange
            .sink { _ in
                self.objectWillChange.send()
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
    
    // calls api to get detail of a recipe (its parts)
    func popullateDetail() {
        recipesWebHandler.listRecipeDetail(recipe)
    }
    
    // MARK: - Model Access
    
    var name: String {
        return recipe.name.lowercased().capitalized
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
    
    // MARK: - Intents
    
    // copies recipe to category of user's collection
    func copyRecipe(toCategoryId categoryId: Int, inCollection collection: RecipeCollectionVM) {
        RecipeVM.copy(recipe: self.recipe, toCategoryId: categoryId, inCollection: collection)
    }
}
