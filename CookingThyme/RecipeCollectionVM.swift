//
//  RecipeCollectionVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/15/20.
//

import Foundation
import Combine

// TODO: action sheet titles
class RecipeCollectionVM: ObservableObject {
    @Published var collection: RecipeCollection
    @Published var categories: [RecipeCategoryVM]
    @Published var currentCategory: RecipeCategoryVM?
    
    @Published var tempShoppingList: [ShoppingItem] = []
    
    @Published var imageHandler = ImageHandler()
    private var imageHandlerCancellable: AnyCancellable?
    
    // MARK: - Init
    
    init(collection: RecipeCollection) {
        self.collection = collection
        self.categories = [RecipeCategoryVM]()
        self.tempShoppingList = RecipeDB.shared.getShoppingItems(byCollectionId: collection.id)
        
        self.imageHandlerCancellable = self.imageHandler.objectWillChange
            .sink { _ in
                self.objectWillChange.send()
            }
        
        sortShoppingList()
        popullateCategories()
        popullateImages()
        resetCurrentCategory()
    }
    
    func sortCategories() {
        var currentCategories = categories
        currentCategories.sort(by: { (a:RecipeCategoryVM, b:RecipeCategoryVM) -> Bool in
            if a.name == "All" {
                return true
            }
            if b.name == "All" {
                return false
            }
            return a.name < b.name
        })
        self.categories = currentCategories
    }
    
    // gets collection from db
    func refreshCollection() {
        if let collection = RecipeDB.shared.getCollection(withId: collection.id) {
            self.collection = collection
            self.tempShoppingList = RecipeDB.shared.getShoppingItems(byCollectionId: collection.id)
            sortShoppingList()
            popullateCategories()
            popullateImages()
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
        self.categories = [RecipeCategoryVM]()
        var hasAllCategory = false
        for category in categories {
            if category.name == "All" {
                hasAllCategory = true
            }
            self.categories.append(RecipeCategoryVM(category: category, collection: self))
        }
        sortCategories()
        
        if !hasAllCategory {
            RecipeDB.shared.createCategory(withName: "All", forCollectionId: collection.id)
        }
    }
    
    func popullateImages() {
        for category in categories {
            if let image = RecipeDB.shared.getImage(withCategoryId: category.id) {
                imageHandler.setImage(image, at: 0)
            }
        }
    }
    
    // MARK: Access
    
    var id: Int {
        collection.id
    }
    
    var name: String {
        collection.name
    }
    
    var allCategory: RecipeCategoryVM? {
        for category in categories {
            if category.name == "All" {
                return category
            }
        }
        return nil
    }
    
//    var categoryNames: [String] {
//        var categoryNames = [String]()
//        for category in categories {
//            categoryNames.append(category.name)
//        }
//        return categoryNames.sorted()
//    }
    
    // MARK: Intents
    
    func filterCurrentCategory(withSearch search: String) {
        if let currentCategory = self.currentCategory {
            currentCategory.filterRecipes(withSearch: search)
            self.currentCategory = currentCategory
        }
    }
    
    func setCurrentCategory(_ category: RecipeCategoryVM) {
        category.popullateCategory()
        currentCategory = category
    }
    
    func refreshCurrrentCategory() {
        if let currentCategory = self.currentCategory {
            currentCategory.popullateCategory()
            self.currentCategory = currentCategory
        }
    }
    
    func resetCurrentCategory() {
        if allCategory == nil {
            print("error")
        }
        else {
            currentCategory = allCategory!
        }
    }
    
    // TODO: delete recipe from category vs last recipe
    func deleteRecipe(withId id: Int) {
        RecipeDB.shared.deleteRecipe(withId: id)
        RecipeDB.shared.deleteDirections(withRecipeId: id)
        RecipeDB.shared.deleteIngredients(withRecipeId: id)
        RecipeDB.shared.deleteImages(withRecipeId: id)
        refreshCurrrentCategory()
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
//        popullateCategories()
    }
    
    // deletes category from collection
    func deleteCategory(withId id: Int) {
        RecipeDB.shared.deleteCategory(withId: id)
        RecipeDB.shared.deleteRecipes(withCategoryId: id)
        popullateCategories()
        if let currentCategory = self.currentCategory, id == currentCategory.id {
            resetCurrentCategory()
        }
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
    
    func getRecipe(withName name: String) -> Recipe? {
        if let currentCategory = self.currentCategory {
            for recipe in currentCategory.recipes {
                if recipe.name == name {
                    return recipe
                }
            }
        }
        return nil
    }
    
    func moveRecipe(withName name: String, toCategoryId categoryId: Int) {
        if let recipe = getRecipe(withName: name) {
            RecipeDB.shared.updateRecipe(withId: recipe.id, name: recipe.name, servings: recipe.servings, recipeCategoryId: categoryId)
        }
    }
    
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


