//
//  RecipeCollectionVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/15/20.
//

import Foundation

class RecipeCollectionVM: ObservableObject {
    private var recipeCollectionId: Int
    @Published var recipeCollection: [RecipeCategory: [Recipe]]
    
    // MARK: - Init
    
    init(recipeCollectionId: Int) {
        self.recipeCollectionId = recipeCollectionId
        self.recipeCollection = [RecipeCategory: [Recipe]]()
        popullateCategories()
    }
    
    func popullateCategories() {
        let categories = RecipeDB.shared.getCategories(byCollectionId: recipeCollectionId)
        for category in categories {
            self.recipeCollection[category] = []
        }
    }
    
//    init(recipes: [Recipe]) {
//        self.recipeCollection = ["All": recipes]
//    }
//
//    init(recipeCollection: [String: [Recipe]]) {
//        self.recipeCollection = recipeCollection
//    }
    
    // MARK: Access
    
    var categoryNames: [String] {
        var categoryNames = [String]()
        for category in recipeCollection.keys {
            categoryNames.append(category.name)
        }
        return categoryNames.sorted()
    }
    
    var categories: [RecipeCategory] {
        return [RecipeCategory](recipeCollection.keys)
    }
    
//    func recipes(inCategoryId categoryId: Int) -> [Recipe]? {
//        let recipes = RecipeDB.shared.getRecipes(byCategoryId: categoryId)
//        return recipes
//    }
    
    // MARK: Intents
    
    func addCategory(_ category: String) -> Void {
        RecipeDB.shared.createCategory(withName: category, forCollectionId: recipeCollectionId)
        popullateCategories()
    }
    
    func addRecipe(_ recipe: Recipe, toCategory category: String) {
//        var categoryRecipes = recipeCollection[category]
//        if categoryRecipes?.append(recipe) == nil {
//            print("\(category) category doesn't exist. Recipe not added.")
//            return
//        }
    }
}


