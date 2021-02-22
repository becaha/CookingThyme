//
//  ReadRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/24/20.
//

import SwiftUI

struct ReadRecipeView: View {
    @EnvironmentObject var collection: RecipeCollectionVM
    @EnvironmentObject var category: RecipeCategoryVM
    @Binding var isEditingRecipe: Bool
    @EnvironmentObject var recipe: RecipeVM
    
    @State private var categoriesPresented = false
    
    @State private var newAmount: String = ""
    @State private var newUnit: String = ""
    @State private var newName: String = ""
    @State private var newDirection: String = ""
    
    
    @State private var isCreatingRecipe = false
    
    var body: some View {
        ScrollView(.vertical) {
            RecipeNameTitle(name: recipe.tempRecipe.name)
            
            getImageView()
            
            RecipeLists(
                        addToShoppingList: { ingredient in
                            collection.addIngredientShoppingItem(ingredient)
                        },
                        addAllToShoppingList: { ingredients in
                            addAllIngredients(ingredients)
                        },
                        onNotSignedIn: {}
            )
            .environmentObject(recipe)
        }
        .loadable(isLoading: $recipe.isLoading)
        .background(formBackgroundColor().edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $categoriesPresented, content: {
            CategoriesSheet(currentCategoryId: recipe.categoryId, actionWord: "Move", isPresented: $categoriesPresented, onAction: { categoryId in
                recipe.moveRecipe(toCategoryId: categoryId)
            }, onRemove: { categoryId in
                collection.removeRecipe(recipe.recipe, fromCategoryId: categoryId)
            })
            .environmentObject(collection)
        })
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing:
                HStack {
                    Button(action: {
                        categoriesPresented = true
                    })
                    {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .padding(.trailing)
                    .frame(minWidth: 44, minHeight: 44)
                                    
                    Button(action: {
                        withAnimation {
                            isEditingRecipe = true
                        }
                    })
                    {
                        Text("Edit")
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
        )
    }
    
    // add all ingredients to shopping list is true, change + to checks
    func addAllIngredients(_ ingredients: [Ingredient]) -> Bool {
        collection.addIngredientShoppingItems(ingredients: ingredients)
        return true
    }
    
    @ViewBuilder
    func getImageView() -> some View {
        if recipe.imageHandler.images.count > 0 {
            ImagesView(isEditing: false)
        }
    }
}

extension Array where Element: Equatable {
    mutating func toggleElement(_ element: Element) {
        let found = contains(element)
        guard let foundIndex = found else {
            append(element)
            return
        }
        remove(at: foundIndex)
    }
    
    func contains(_ element: Element) -> Int? {
        var found: Int?
        for index in 0..<self.count {
            if self[index] == element {
                found = index
            }
        }
        return found
    }
}
