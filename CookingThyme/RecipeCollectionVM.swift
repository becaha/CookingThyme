//
//  RecipeCollectionVM.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/15/20.
//

import Foundation
import Combine

// TODO AttributeGraph: cycle detected through attribute 3286136, on sign in
// TODO photos reload too much
class RecipeCollectionVM: ObservableObject {
    @Published var collection: RecipeCollection
    @Published var categories: [RecipeCategoryVM]
    @Published var currentCategory: RecipeCategoryVM?
    @Published var refreshView: Bool = false
    
    @Published var isLoading: Bool?

    private var currentCategoryCancellable: AnyCancellable?

    
    @Published var tempShoppingList: [ShoppingItem] = []
    var permShoppingList: [ShoppingItem] = []
    
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
        
        self.currentCategoryCancellable = self.currentCategory?.objectWillChange.sink {
            _ in
            self.objectWillChange.send()
        }
        
//        self.sortShoppingList()
        self.popullateCategories() { success in
            if success {
                self.isLoading = false
            }
            else {
                // TODO change to error
                self.isLoading = false
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
    
    var allRecipes: [Recipe] {
//        allCategory?.recipes ?? []
        let allRecipes = Array(categoriesStore.values).reduce([]) { (recipes, recipeCategoryVM) -> [Recipe] in
            if recipeCategoryVM.name != "All" {
                var currentRecipes = recipes
                currentRecipes.append(contentsOf: recipeCategoryVM.recipes)
                return currentRecipes
            }
            return recipes
        }
        return allRecipes
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
    // TODO is it just bad connection that makes a second call to get categories with error?
    func popullateCategories(onCompletion: @escaping (Bool) -> Void) {
        if self.categoriesStore.count > 0 {
            self.categories = Array(self.categoriesStore.values)
            self.sortCategories()
            onCompletion(true)
            return
        }
        RecipeDB.shared.getCategories(byCollectionId: collection.id) { success, categories in
            if !success {
                onCompletion(false)
                return 
            }
            var popullatedCategories = [RecipeCategoryVM]()
            let categoriesGroup = DispatchGroup()
            
            for category in categories {
                categoriesGroup.enter()
                // initializing recipeCategoryVM adds that category to the category store
                popullatedCategories.append(RecipeCategoryVM(category: category, collection: self) { success in
                    categoriesGroup.leave()
                })
            }
            
            categoriesGroup.notify(queue: .main) {
                self.categories = popullatedCategories
                self.sortCategories()
                
                self.popullateAllRecipes() { success in
                    if success {
                        self.refreshCurrentCategory()
                        onCompletion(true)
                    }
                    else {
                        onCompletion(false)
                    }
                }
            }
        }
    }
    
    func popullateAllRecipes(onCompletion: @escaping (Bool) -> Void) {
        RecipeDB.shared.getAllRecipes(withCollectionId: id) { allRecipes in
            // sets all category with all recipes in category store
            if let allCategory = self.allCategory {
                let allCategoryId = allCategory.id
                self.categoriesStore[allCategoryId]?.recipes = allRecipes
            }
            onCompletion(true)
        }
    }
    
    func popullateShoppingItems() {
        RecipeDB.shared.getShoppingItems(byCollectionId: collection.id) { shoppingList in
            self.permShoppingList = shoppingList
            self.tempShoppingList = shoppingList
        }
    }
    
    // to refresh view
    func refreshCurrentCategory() {
        if let currentCategory = self.currentCategory {
            let currentCategoryRecipes = currentCategory.recipes
            let storeRecipes = self.categoriesStore[currentCategory.id]?.recipes

            currentCategory.recipes = storeRecipes ?? currentCategoryRecipes
            self.currentCategory = currentCategory
        }
        else {
            resetCurrentCategoryToAllCategory()
        }
    }
    
    func resetCurrentCategoryToAllCategory() {
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
        
        popullateCategories() { success in
            if let currentCategory = self.currentCategory, id == currentCategory.id {
                self.resetCurrentCategoryToAllCategory()
            }
        }
    }
    
    // called by ui add category
    // adds new category to collection, udpates category store
    func addCategory(_ category: String) -> Void {
        RecipeDB.shared.createCategory(withName: category, forCollectionId: collection.id) { category in
            if let category = category {
                // updates category store
                self.categoriesStore[category.id] = RecipeCategoryVM(category: category, collection: self) {
                    success in
                    if !success {
                        print("error adding category to store")
                    }
                }
                
                self.popullateCategories() { categoriesSuccess in
                    if !categoriesSuccess {
                        print("error populating categories")
                    }
                }
            }
        }
    }

    // TODO only refresh image if it has changed
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
        
    // gets recipe by name from current category
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
    
    // gets recipe by id from all recipes
    func getRecipe(withId id: String) -> Recipe? {
        for recipe in self.allRecipes {
            if recipe.id == id {
                return recipe
            }
        }
        return nil
    }
    
    // called by moveRecipe by drag/drop, update store
    func moveRecipe(withName name: String, toCategoryId categoryId: String) {
        if let recipe = getRecipe(withName: name) {
            // update categories and recipes store, moves recipe to new category
            moveRecipeInStore(recipe, toCategoryId: categoryId)
                        
            RecipeDB.shared.updateRecipe(withId: recipe.id, name: recipe.name, servings: recipe.servings, source: recipe.source, recipeCategoryId: categoryId) { success in
                if !success {
                    print("error moving recipe")
                }
            }
        }
    }
    
    // called by unchecking its own category in move category view
    // removes recipe from category
    func removeRecipe(_ recipe: Recipe, fromCategoryId categoryId: String) {
        if let allCategory = self.allCategory {
            let allCategoryId = allCategory.id
            // only remove from category if the category is not all
            if categoryId != allCategoryId {
                // updates category store
                removeRecipeFromStoreCategory(recipe)
                
                RecipeDB.shared.updateRecipe(withId: recipe.id, name: recipe.name, servings: recipe.servings, source: recipe.source, recipeCategoryId: allCategoryId) { success in
                    if !success {
                        print("error moving recipe")
                    }
                }
            }
        }
        // TODO remove
//        self.refreshView = true
//        self.popullateCategories()
    }
    
    // called by ui in collection edit, deletes recipe and associated parts
    func deleteRecipe(withId id: String) {
        self.deleteRecipeAndParts(withId: id)
        // update categories store
        removeRecipeFromStoreCategory(withId: id)
        updateAllRecipes()
        
        // need this for recipe on delete to disappear
        refreshCurrentCategory()
    }
    
    // called by deleteRecipe above and delete Category
    private func deleteRecipeAndParts(withId id: String) {
        RecipeDB.shared.deleteRecipe(withId: id)
        RecipeDB.shared.deleteDirections(withRecipeId: id)
        RecipeDB.shared.deleteIngredients(withRecipeId: id)
        RecipeDB.shared.deleteImages(withRecipeId: id)
    }
    
    // MARK: Stores
    
    func updateAllRecipes() {
        self.allCategory?.recipes = allRecipes
    }
    
    // add recipe to new category in category store
    func addRecipeToStore(_ recipe: Recipe, toCategoryId categoryId: String) {
        if let storeCategory = self.categoriesStore[categoryId] {
            let updatedCategory = storeCategory
            var updatedRecipe = recipe
            updatedRecipe.recipeCategoryId = categoryId
            updatedCategory.recipes.append(updatedRecipe)
            self.categoriesStore[categoryId] = updatedCategory
            self.updateAllRecipes()
            // updates current category
            self.refreshCurrentCategory()
        }
    }
    
    func moveRecipeInStore(_ recipe: Recipe, toCategoryId newCategoryId: String) {
        // update category store
        self.removeRecipeFromStoreCategory(recipe)
        self.addRecipeToStore(recipe, toCategoryId: newCategoryId)
        // update recipe store
        if let recipeVM = self.recipesStore[recipe.id] {
            recipeVM.recipe.recipeCategoryId = newCategoryId
            self.recipesStore[recipe.id] = recipeVM
        }
    }
    
    // remove recipe with id from old category in category store
    func removeRecipeFromStoreCategory(withId id: String) {
        if let recipe = getRecipe(withId: id) {
            removeRecipeFromStoreCategory(recipe)
        }
    }
    
    // remove recipe from old category in category store
    func removeRecipeFromStoreCategory(_ recipe: Recipe) {
        if let storeCategory = self.categoriesStore[recipe.recipeCategoryId] {
            var oldCategoryRecipes = storeCategory.recipes
            oldCategoryRecipes.remove(element: recipe)
            storeCategory.recipes = oldCategoryRecipes
            self.categoriesStore[recipe.recipeCategoryId] = storeCategory
            self.updateAllRecipes()
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


