//
//  RecipeCollectionVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/15/20.
//

import Foundation
import Combine

class RecipeCollectionVM: ObservableObject {
    @Published var collection: RecipeCollection
    @Published var categories: [RecipeCategory]
    
    @Published var tempShoppingList: [ShoppingItem] = []
    
    // MARK: - Init
    
    init(collection: RecipeCollection) {
        self.collection = collection
        self.categories = [RecipeCategory]()
        self.tempShoppingList = RecipeDB.shared.getShoppingItems(byCollectionId: collection.id)
        popullateCategories()
    }
    
    func refreshCollection() {
        if let collection = RecipeDB.shared.getCollection(withId: collection.id) {
            self.collection = collection
            self.tempShoppingList = RecipeDB.shared.getShoppingItems(byCollectionId: collection.id)
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
    
    // MARK: Access
    
    var id: Int {
        collection.id
    }
    
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
    
    // Shopping List
    
    func addIngredientShoppingItems(ingredients: [Ingredient]) {
        for ingredient in ingredients {
            addIngredientShoppingItem(ingredient)
        }
    }
    
    func addIngredientShoppingItem(_ ingredient: Ingredient) {
        let item: ShoppingItem = ShoppingItem(name: ingredient.name, amount: ingredient.amount, unitName: ingredient.unitName, collectionId: collection.id, completed: false)
        tempShoppingList.append(item)
    }
    
    func addTempShoppingItem(name: String, completed: Bool = false) {
        let item: ShoppingItem = ShoppingItem(name: name, amount: nil, unitName: UnitOfMeasurement.none, collectionId: collection.id, completed: completed)
        tempShoppingList.append(item)
    }
    
    func removeTempShoppingItem(at index: Int) {
        tempShoppingList.remove(at: index)
    }
    
    func toggleCompleted(_ item: ShoppingItem) {
        if let index = tempShoppingList.indexOf(element: item) {
            tempShoppingList[index].completed.toggle()
        }
    }
    
    func saveShoppingList() {
        RecipeDB.shared.deleteShoppingItems(withCollectionId: collection.id)
        RecipeDB.shared.createShoppingItems(items: tempShoppingList, withCollectionId: collection.id)
    }
    
    func addToShoppingList(fromRecipe recipe: Recipe) {
        addIngredientShoppingItems(ingredients: recipe.ingredients)
        saveShoppingList()
    }
    
    func addToShoppingList(_ ingredient: Ingredient) {
        addIngredientShoppingItem(ingredient)
        saveShoppingList()
    }
}


