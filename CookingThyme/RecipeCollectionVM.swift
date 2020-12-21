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
        sortShoppingList()
        popullateCategories()
    }
    
    // gets collection from db
    func refreshCollection() {
        if let collection = RecipeDB.shared.getCollection(withId: collection.id) {
            self.collection = collection
            self.tempShoppingList = RecipeDB.shared.getShoppingItems(byCollectionId: collection.id)
            sortShoppingList()
            popullateCategories()
        }
    }
    
    // sorts shopping list by alphabetical order
    func sortShoppingList() {
        tempShoppingList = tempShoppingList.sorted(by: { (itemA, itemB) -> Bool in
            if itemA.name.compare(itemB.name) == ComparisonResult.orderedAscending {
                return true
            }
            return false
        })
    }
    
    // gets categories from db
    func popullateCategories() {
        let categories = RecipeDB.shared.getCategories(byCollectionId: collection.id)
        self.categories = [RecipeCategory]()
        self.categories.append(RecipeCategory(name: "All", recipeCollectionId: collection.id))
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
    
    // the all category is appended first
    var allCategory: RecipeCategory {
        categories[0]
    }
    
    var categoryNames: [String] {
        var categoryNames = [String]()
        for category in categories {
            categoryNames.append(category.name)
        }
        return categoryNames.sorted()
    }
    
    // MARK: Intents
    
    func deleteRecipe(withId id: Int) {
        RecipeDB.shared.deleteRecipe(withId: id)
        RecipeDB.shared.deleteDirections(withRecipeId: id)
        RecipeDB.shared.deleteIngredients(withRecipeId: id)
        RecipeDB.shared.deleteImages(withRecipeId: id)
//        popullateRecipes()
    }
    
    // adds new category to collection
    func addCategory(_ category: String) -> Void {
        RecipeDB.shared.createCategory(withName: category, forCollectionId: collection.id)
        popullateCategories()
    }
    
//    func addRecipe(_ recipe: Recipe, toCategory category: String) {
//        var categoryRecipes = recipeCollection[category]
//        if categoryRecipes?.append(recipe) == nil {
//            print("\(category) category doesn't exist. Recipe not added.")
//            return
//        }
//    }
    
    // updates name of category
    func updateCategory(forCategoryId categoryId: Int, toName categoryName: String) {
        RecipeDB.shared.updateCategory(withId: categoryId, name: categoryName, recipeCollectionId: collection.id)
        popullateCategories()
    }
    
    // deletes category from collection
    func deleteCategory(withId id: Int) {
        RecipeDB.shared.deleteCategory(withId: id)
        RecipeDB.shared.deleteRecipes(withCategoryId: id)
        popullateCategories()
    }
    
    // MARK: - Shopping List
    // the shopping list belongs to the collection
    
    // MARK: - Access
    
    // items checked off/bought
    var completedItems: [ShoppingItem] {
        var items = [ShoppingItem]()
        for item in tempShoppingList {
            if item.completed {
                items.append(item)
            }
        }
        return items
    }
    
    // items not checked off/bought
    var notCompletedItems: [ShoppingItem] {
        var items = [ShoppingItem]()
        for item in tempShoppingList {
            if !item.completed {
                items.append(item)
            }
        }
        return items
    }
    
    // MARK: - Intents
    
    // adds given ingredients to shopping items
    private func addIngredientShoppingItems(ingredients: [Ingredient]) {
        for ingredient in ingredients {
            addIngredientShoppingItem(ingredient)
        }
    }
    
    // adds given ingredient to shopping items
    private func addIngredientShoppingItem(_ ingredient: Ingredient) {
        let item: ShoppingItem = ShoppingItem(name: ingredient.name, amount: ingredient.amount, unitName: ingredient.unitName, collectionId: collection.id, completed: false)
        tempShoppingList.append(item)
        sortShoppingList()
    }
    
    // adds to shopping items, temporary until saved
    func addTempShoppingItem(name: String, completed: Bool = false) {
        let item: ShoppingItem = ShoppingItem(name: name, amount: nil, unitName: UnitOfMeasurement.none, collectionId: collection.id, completed: completed)
        tempShoppingList.append(item)
        sortShoppingList()
        saveShoppingList()
    }
    
    private func removeTempShoppingItem(at index: Int) {
        tempShoppingList.remove(at: index)
    }
    
    func removeTempShoppingItem(_ item: ShoppingItem) {
        if let index = tempShoppingList.indexOf(element: item) {
            tempShoppingList.remove(at: index)
        }
        saveShoppingList()
    }
    
    // removes all completed shopping items
    func removeCompletedShoppingItems() {
        for item in tempShoppingList {
            if item.completed {
                if let index = tempShoppingList.indexOf(element: item) {
                    removeTempShoppingItem(at: index)
                }
            }
        }
        saveShoppingList()
    }
    
    // toggles completion/checked off of an item
    func toggleCompleted(_ item: ShoppingItem) {
        if let index = tempShoppingList.indexOf(element: item) {
            tempShoppingList[index].completed.toggle()
        }
        saveShoppingList()
    }
    
    // saves temp shopping list to db
    func saveShoppingList() {
        RecipeDB.shared.deleteShoppingItems(withCollectionId: collection.id)
        RecipeDB.shared.createShoppingItems(items: tempShoppingList, withCollectionId: collection.id)
    }
    
    // adds all ingredients of given recipe to shopping list
    func addToShoppingList(fromRecipe recipe: Recipe) {
        addIngredientShoppingItems(ingredients: recipe.ingredients)
        saveShoppingList()
    }
    
    // adds ingredient to shopping list
    func addToShoppingList(_ ingredient: Ingredient) {
        addIngredientShoppingItem(ingredient)
        saveShoppingList()
    }
}


