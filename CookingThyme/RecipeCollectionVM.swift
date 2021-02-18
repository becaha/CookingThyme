//
//  RecipeCollectionVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/15/20.
//

import Foundation
import Combine

// TODO photos reload too much
class RecipeCollectionVM: ObservableObject {
    @Published var collection: RecipeCollection
    @Published var categories: [RecipeCategoryVM]
    @Published var currentCategory: RecipeCategoryVM?
    @Published var refreshView: Bool = false
    
    @Published var isLoading: Bool?

    @Published var allRecipes = [Recipe]()
    var categoryRecipesAdded = 0

    private var currentCategoryCancellable: AnyCancellable?

    
    @Published var tempShoppingList: [ShoppingItem] = []
    var permShoppingList: [ShoppingItem] = []

    @Published var imageHandler = ImageHandler()
    private var imageHandlerCancellable: AnyCancellable?
    
    // stores recipes from db to local storage when recipe is retrieved from db or saved to db
    // recipeId to RecipeVM
    var recipesStore = [String: RecipeVM]()
    // stores categories from db to local storage when category is retrieved from db or saved to db
    // recipeCategoryId to RecipeCategoryVM
    var categoriesStore = [String: RecipeCategoryVM]()
    
    // MARK: - Init
    
    init(collection: RecipeCollection) {
        self.isLoading = true
        self.collection = collection
        self.categories = [RecipeCategoryVM]()
        self.popullateShoppingItems()
        
        self.imageHandlerCancellable = self.imageHandler.objectWillChange
            .sink { _ in
                self.objectWillChange.send()
            }
        
        self.currentCategoryCancellable = self.currentCategory?.objectWillChange.sink {
            _ in
            self.objectWillChange.send()
        }
        
//        self.sortShoppingList()
        self.popullateCategories() { success in
            if success {
                self.popullateImages() { imagesSuccess in
                    self.isLoading = false
                }
            }
        }
//        self.resetCurrentCategory()
    }
    
    // MARK: Access
    
    var id: String {
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
    
    func isAddable(recipe: Recipe?, toCategory category: RecipeCategoryVM) -> Bool {
        return category.name != "All" && recipe?.recipeCategoryId != category.id
    }
    
    func addableCategories(forRecipe recipe: Recipe) -> [RecipeCategoryVM] {
        return self.categories.filter { (category) -> Bool in
            isAddable(recipe: recipe, toCategory: category)
        }
    }
    
    func getCategory(withId id: String) -> RecipeCategoryVM? {
        let foundCategory = self.categories.filter { (category) -> Bool in
            category.id == id
        }
        if foundCategory.count == 1 {
            return foundCategory[0]
        }
        return nil
    }
    
    // MARK: - DB Loaders
    
    // gets categories from db
    // TODO is it just bad connection that makes a second call to geeet categories with error
    func popullateCategories(onCompletion: @escaping (Bool) -> Void) {
        if self.categoriesStore.count > 0 {
            // sets self.categories
            self.categories = Array(self.categoriesStore.values)
            // sorts categories
            self.sortCategories()
            // popullates allrecipes -> refreshes current category
            self.popullateAllRecipes() { success in
                if success {
                    self.refreshCurrrentCategory()
                    onCompletion(true)
                }
                else {
                    onCompletion(false)
                }
            }
            return
        }
        RecipeDB.shared.getCategories(byCollectionId: collection.id) { success, categories in
            if !success {
                onCompletion(false)
                return 
            }
            var popullatedCategories = [RecipeCategoryVM]()
            
            for category in categories {
                popullatedCategories.append(RecipeCategoryVM(category: category, collection: self))
            }
            
            self.categories = popullatedCategories
            self.sortCategories()
            
            self.popullateAllRecipes() { success in
                if success {
                    self.refreshCurrrentCategory()
                    onCompletion(true)
                }
                else {
                    onCompletion(false)
                }
            }
        }
    }
    
    func popullateAllRecipes(onCompletion: @escaping (Bool) -> Void) {
        RecipeDB.shared.getAllRecipes(withCollectionId: id) { recipes in
            self.allRecipes = recipes
            onCompletion(true)
        }
    }
    
    func popullateImages(onCompletion: @escaping (Bool) -> Void) {
        let imagesGroup = DispatchGroup()
        for category in self.categories {
            imagesGroup.enter()
            
            RecipeDB.shared.getImage(withCategoryId: category.id) { image in
                if let image = image {
                    self.imageHandler.setImage(image, at: 0)
                    imagesGroup.leave()
                }
                else {
                    imagesGroup.leave()
                }
            }
            
            imagesGroup.notify(queue: .main) {
                onCompletion(true)
            }
        }
    }
    
    func popullateShoppingItems() {
        RecipeDB.shared.getShoppingItems(byCollectionId: collection.id) { shoppingList in
            self.permShoppingList = shoppingList
            self.tempShoppingList = shoppingList
        }
    }
    
    // to refresh view
    func refreshCurrrentCategory() {
        if let currentCategory = self.currentCategory {
//            currentCategory.popullateCategory() { success in
//                if !success {
//                    print("error popullating category")
//                }
//            }
            self.currentCategory = currentCategory
        }
        else {
            resetCurrentCategory()
        }
    }
    
    func resetCurrentCategory() {
        if allCategory == nil {
            print("error")
        }
        else if currentCategory == nil {
            allCategory!.recipes = allRecipes
            currentCategory = allCategory!
        }
    }
    
    // MARK: - Sorters
    
    // TODO sort with auto all in first place
    func sortCategories() {
        var currentCategories = self.categories
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
    
    // sorts shopping list by alphabetical order
    func sortShoppingList() {
//        let sortedTempShoppingList = self.tempShoppingList.sorted(by: { (itemA, itemB) -> Bool in
//            if itemA.name.compare(itemB.name) == ComparisonResult.orderedAscending {
//                return true
//            }
//            return false
//        })
//        self.tempShoppingList = sortedTempShoppingList
    }
    
    // MARK: Intents
    
    // MARK: - Current Category
    
    func filterCurrentCategory(withSearch search: String) {
        if let currentCategory = self.currentCategory {
            currentCategory.filterRecipes(withSearch: search)
            self.currentCategory = currentCategory
        }
    }
    
    func setCurrentCategory(_ category: RecipeCategoryVM) {
        if let foundCategoryVM = self.categoriesStore[category.id] {
            category.recipes = foundCategoryVM.recipes
            category.imageHandler = foundCategoryVM.imageHandler
            self.currentCategory = category
            return
        }
        else {
//            category.popullateRecipes()
            category.popullateCategory() { success in
                if !success {
                    print("error popullating category")
                }
            }
            self.currentCategory = category
        }
    }
    
    // MARK: - Collection
    
    // called by user delete
    // deletes all collection, categories, shopping items
    func delete() {
        RecipeDB.shared.deleteCollection(withId: self.id)
        RecipeDB.shared.deleteShoppingItems(withCollectionId: self.id)
        for category in self.categories {
            self.deleteCategory(withId: category.id)
        }
        // resets store
        self.categoriesStore = [String: RecipeCategoryVM]()
        self.recipesStore = [String: RecipeVM]()
    }
    
    // MARK: - Category
    
    // called by delete above and ui delete category
    // deletes category and its recipes, udpates category store
    func deleteCategory(withId id: String) {
        RecipeDB.shared.deleteCategory(withId: id)
    
        for categoryRecipe in getCategory(withId: id)?.recipes ?? [] {
            self.deleteRecipeAndParts(withId: categoryRecipe.id)
        }
        
        // updates category store
        self.categoriesStore[id] = nil
        
        // TODO take out
        popullateCategories() { success in
            if let currentCategory = self.currentCategory, id == currentCategory.id {
    //            resetCurrentCategory()
            }
        }
    }
    
    // called by ui add category
    // adds new category to collection, udpates category store
    func addCategory(_ category: String) -> Void {
        RecipeDB.shared.createCategory(withName: category, forCollectionId: collection.id) { category in
            if let category = category {
                // updates category store
                self.categoriesStore[category.id] = RecipeCategoryVM(category: category, collection: self)
                // TODO take out
                self.popullateCategories() { categoriesSuccess in
                    if !categoriesSuccess {
                        print("error populating categories")
                    }
                }
            }
        }
    }
    
    // updates name of category, updates category store
    func updateCategory(forCategoryId categoryId: String, toName categoryName: String) {
        // updates category store
        let updatedCategory = self.categoriesStore[categoryId]
        if updatedCategory != nil {
            updatedCategory!.category.name = categoryName
            self.categoriesStore[categoryId] = updatedCategory!
        }
        
        RecipeDB.shared.updateCategory(withId: categoryId, name: categoryName, recipeCollectionId: collection.id) { success in
            if !success {
                print("error updating category")
            }
        }
    }
    
    // MARK: - Recipe
    
    // TODO: *
    
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
    
    func moveRecipe(withName name: String, toCategoryId categoryId: String) {
        if let recipe = getRecipe(withName: name) {
            RecipeDB.shared.updateRecipe(withId: recipe.id, name: recipe.name, servings: recipe.servings, source: recipe.source, recipeCategoryId: categoryId) { success in
                if !success {
                    print("error moving recipe")
                }
            }
        }
        refreshView = true
    }
    
    // called by unchecking its own category in move category view
    // removes recipe from category, if category is all, do not remove TODO: ?
    func removeRecipe(_ recipe: Recipe, fromCategoryId categoryId: String) {
        if let allCategory = self.allCategory {
            let allCategoryId = allCategory.id
            if categoryId != allCategoryId {
                RecipeDB.shared.updateRecipe(withId: recipe.id, name: recipe.name, servings: recipe.servings, source: recipe.source, recipeCategoryId: allCategoryId) { success in
                    if !success {
                        print("error moving recipe")
                    }
                }
            }
        }
        self.refreshView = true
//        self.popullateCategories()
    }
    
    // deletes recipe and associated parts
    func deleteRecipe(withId id: String) {
        self.deleteRecipeAndParts(withId: id)
        // TODO update categories store
        // need this for recipe on delete to disappear
        currentCategory?.popullateRecipes() { success in
            if !success {
                print("error popullating recipes")
            }
        }
//        refreshCurrrentCategory()
    }
    
    private func deleteRecipeAndParts(withId id: String) {
        RecipeDB.shared.deleteRecipe(withId: id)
        RecipeDB.shared.deleteDirections(withRecipeId: id)
        RecipeDB.shared.deleteIngredients(withRecipeId: id)
        RecipeDB.shared.deleteImages(withRecipeId: id)
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
    func addIngredientShoppingItems(ingredients: [Ingredient]) {
        for ingredient in ingredients {
            addIngredientShoppingItem(ingredient)
        }
        saveShoppingList()
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
    func removeShoppingItems(completed: Bool) {
        for item in tempShoppingList {
            if item.completed == completed {
                if let index = tempShoppingList.indexOf(element: item) {
                    removeTempShoppingItem(at: index)
                }
            }
        }
        saveShoppingList()
    }
    
    func removeAllShoppingItems() {
        for item in tempShoppingList {
            if let index = tempShoppingList.indexOf(element: item) {
                removeTempShoppingItem(at: index)
            }
        }
        saveShoppingList()
    }
    
    func completeAllShoppingItems(_ complete: Bool = true) {
        for index in 0..<tempShoppingList.count {
            tempShoppingList[index].completed = complete
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
        RecipeDB.shared.updateShoppingItems(withCollectionId: collection.id, shoppingItems: tempShoppingList, oldItems: permShoppingList) { success in
            if !success {
                print("error updating shopping list")
            }
            else {
//                self.popullateShoppingItems()
            }
        }
        
    }
    
    // adds all ingredients of given recipe to shopping list
    func addToShoppingList(fromRecipe recipe: Recipe) {
        addIngredientShoppingItems(ingredients: recipe.ingredients)
    }
    
    // adds ingredient to shopping list
    func addToShoppingList(_ ingredient: Ingredient) {
        addIngredientShoppingItem(ingredient)
        saveShoppingList()
    }
}


