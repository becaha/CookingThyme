//
//  RecipeCollectionVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/15/20.
//

import Foundation

class RecipeCollectionVM: ObservableObject {
    @Published var recipeCollection: [String: [Recipe]]
    
    // MARK: - Init
    
    init(recipes: [Recipe]) {
        self.recipeCollection = ["All": recipes]
    }
    
    init(recipeCollection: [String: [Recipe]]) {
        self.recipeCollection = recipeCollection
    }
    
    // MARK: Access
    
    var categories: [String] {
        return [String](recipeCollection.keys).sorted()
    }
    
    func recipes(inCategory category: String) -> [Recipe]? {
        let recipes = recipeCollection[category]
        return recipes
    }
    
    // MARK: Intents
    
    func addCategory(_ category: String) -> Void {
        recipeCollection[category.lowercased().capitalized] = []
    }
    
    func addRecipe(_ recipe: Recipe, toCategory category: String) {
        var categoryRecipes = recipeCollection[category]
        if categoryRecipes?.append(recipe) == nil {
            print("\(category) category doesn't exist. Recipe not added.")
            return
        }
    }
}
