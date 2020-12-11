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
    @Published var publicRecipe: WebRecipe
    @Published var recipe: Recipe
    @Published var recipesWebHandler = RecipesWebHandler()
    @Published var isPopullating = true
    @Published var recipeNotFound = false
    @Published var imageHandler = ImageHandler()

    private var webHandlerCancellable: AnyCancellable?
    private var recipeDetailCancellable: AnyCancellable?
    private var recipeDetailErrorCancellable: AnyCancellable?
    private var imageHandlerCancellable: AnyCancellable?
    
    // MARK: - Init

    init(publicRecipe: WebRecipe) {
        self.publicRecipe = publicRecipe
        self.recipe = Recipe()
        
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
                self.publicRecipe = recipe
                self.recipe = PublicRecipeVM.convertToRecipe(fromPublicRecipe: recipe)
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
        recipesWebHandler.listRecipeDetail(publicRecipe)
    }
    
    // MARK: - Model Access
    
    var name: String {
        if recipe.name != "" {
            return recipe.name.lowercased().capitalized
        }
        else {
            return publicRecipe.name.lowercased().capitalized
        }
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
    
    // converts Web Ingredients from api result to Temp Ingredients for ui
    static func convertIngredients(_ ingredients: [WebIngredient]) -> [TempIngredient] {
        var tempIngredients = [TempIngredient]()
        
        for ingredient in ingredients {
            let tempIngredient = TempIngredient(name: ingredient.name, amount: ingredient.measurements[0].quantity, unitName: ingredient.measurements[0].unit.name, recipeId: 0, id: nil)
            tempIngredients.append(tempIngredient)
        }
        
        return tempIngredients
    }
    
    // converts WebRecipe from api result to Recipe
    static func convertToRecipe(fromPublicRecipe publicRecipe: WebRecipe) -> Recipe {
        let directions = Direction.toDirections(directionStrings: publicRecipe.directions, withRecipeId: 0)
        let ingredients = Ingredient.toIngredients(PublicRecipeVM.convertIngredients(publicRecipe.sections[0].ingredients))
        var images = [RecipeImage]()
        if publicRecipe.imageURL != "" {
            images.append(RecipeImage(type: ImageType.url, data: publicRecipe.imageURL, recipeId: 0))
        }
        return Recipe(name: publicRecipe.name, ingredients: ingredients, directions: directions, images: images, servings: publicRecipe.servings)
    }
    
    // converts WebRecipe from api result to Recipe to be copied to the given category of user's collection
    func convertToRecipe(fromPublicRecipe publicRecipe: WebRecipe, withCategoryId categoryId: Int) -> Recipe {
        let recipe = PublicRecipeVM.convertToRecipe(fromPublicRecipe: publicRecipe)
        return RecipeCategoryVM.createRecipe(forCategoryId: categoryId, name: recipe.name, ingredients: recipe.ingredients, directions: recipe.directions, images: recipe.images, servings: recipe.servings.toString())!
    }
    
    // copies recipe to category of user's collection
    func copyRecipe(toCategoryId categoryId: Int) {
        RecipeVM.copy(recipe: self.recipe, toCategoryId: categoryId)
    }
}
