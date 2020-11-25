//
//  RecipeCollectionVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/15/20.
//

import Foundation

class RecipeCollectionVM: ObservableObject {
    private var recipeCollectionId: Int
    @Published var categories: [RecipeCategory]
    
    // MARK: - Init
    
    init(recipeCollectionId: Int) {
        self.recipeCollectionId = recipeCollectionId
        self.categories = [RecipeCategory]()
        popullateCategories()
    }
    
    func popullateCategories() {
        let categories = RecipeDB.shared.getCategories(byCollectionId: recipeCollectionId)
        self.categories = [RecipeCategory]()
        for category in categories {
            self.categories.append(category)
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
        for category in categories {
            categoryNames.append(category.name)
        }
        return categoryNames.sorted()
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
    
    func updateCategory(forCategoryId categoryId: Int, toName categoryName: String) {
        RecipeDB.shared.updateCategory(withId: categoryId, name: categoryName, recipeCollectionId: recipeCollectionId)
        popullateCategories()
    }
    
    func deleteCategory(withId id: Int) {
        RecipeDB.shared.deleteCategory(withId: id)
        // TODO: we need to let the users know that this will happen
        RecipeDB.shared.deleteRecipes(withCategoryId: id)
        popullateCategories()
    }
}


