//
//  RecipeCollectionVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/15/20.
//

import Foundation

class RecipeCollectionVM: ObservableObject {
    @Published var collection: RecipeCollection
    @Published var categories: [RecipeCategory]
    
    // MARK: - Init
    
    init(collection: RecipeCollection) {
        self.collection = collection
        self.categories = [RecipeCategory]()
        popullateCategories()
    }
    
    func refreshCollection() {
        if let collection = RecipeDB.shared.getCollection(withId: collection.id) {
            self.collection = collection
            popullateCategories()
        }
    }
    
    func popullateCategories() {
        let categories = RecipeDB.shared.getCategories(byCollectionId: collection.id)
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
    
    var name: String {
        collection.name
    }
    
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
        RecipeDB.shared.createCategory(withName: category, forCollectionId: collection.id)
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
        RecipeDB.shared.updateCategory(withId: categoryId, name: categoryName, recipeCollectionId: collection.id)
        popullateCategories()
    }
    
    func deleteCategory(withId id: Int) {
        RecipeDB.shared.deleteCategory(withId: id)
        // TODO: we need to let the users know that this will happen
        RecipeDB.shared.deleteRecipes(withCategoryId: id)
        popullateCategories()
    }
}


