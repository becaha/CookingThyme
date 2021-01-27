//
//  ReadRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/24/20.
//

import SwiftUI

// TODO can cancel add to shpping list
// TODO change from form
// TODO deal with plural ingredient unitNames
// TODO have title not sticky
struct ReadRecipeView: View {
    @EnvironmentObject var collection: RecipeCollectionVM
    @EnvironmentObject var category: RecipeCategoryVM
    @Binding var isEditingRecipe: Bool
    @EnvironmentObject var recipe: RecipeVM
    
    @State private var categoriesPresented = false
    
//    @State private var directionIndicesCompleted = [Int]()
    @State private var newAmount: String = ""
    @State private var newUnit: String = ""
    @State private var newName: String = ""
    @State private var newDirection: String = ""
    
    
    @State private var isCreatingRecipe = false
    
    var body: some View {
        VStack {
            RecipeNameTitle(name: recipe.name)
            
            getImageView()
            
            RecipeLists(servings: $recipe.servings, ingredients: recipe.ingredients,
                        addToShoppingList: { ingredient in
                            collection.addToShoppingList(ingredient)
                        },
                        addAllToShoppingList: { ingredients in
                            addAllIngredients(ingredients)
                        },
                        onNotSignedIn: {},
                        directions: recipe.directions
            )
        }
        .sheet(isPresented: $categoriesPresented, content: {
            CategoriesSheet(currentCategoryId: recipe.categoryId, actionWord: "Move", isPresented: $categoriesPresented) { categoryId in
                recipe.moveRecipe(toCategoryId: categoryId)
            }
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
                                    
                    Button(action: {
                        withAnimation {
                            isEditingRecipe = true
                        }
                    })
                    {
                        Text("Edit")
                    }
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
    
    @ViewBuilder
    func DirectionText(withIndex index: Int) -> some View {
        Group {
            Text("\(index + 1)")

            TextField("\(recipe.directions[index].direction)", text: $newDirection)
        }
        .padding(.vertical)
    }
    
    @ViewBuilder func IngredientText(_ ingredient: Ingredient) -> some View {
        RecipeControls.ReadIngredientText(ingredient)
    }
    
    @ViewBuilder func Direction(withIndex index: Int) -> some View {
        RecipeControls.ReadDirection(withIndex: index, direction: recipe.directions[index].direction)
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

//struct ReadRecipeView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//        ReadRecipeView(isPresented: <#T##Binding<Bool>#>,
//            recipeVM: RecipeVM(recipe: Recipe(
//                name: "Water",
//                ingredients: [
//                    Ingredient(name: "water", amount: 1.05, unitName: UnitOfMeasurement.Cup),
//                    Ingredient(name: "water", amount: 2.1, unitName: UnitOfMeasurement.Cup),
//                    Ingredient(name: "water", amount: 1.3, unitName: UnitOfMeasurement.Cup),
//                    Ingredient(name: "water", amount: 1.8, unitName: UnitOfMeasurement.Cup),
//                    Ingredient(name: "water", amount: 1.95, unitName: UnitOfMeasurement.Cup)
//                ],
//                directions: [
//                    Direction(step: 1, recipeId: 1, direction: "Fetch a pail of water from the wishing well in the land of the good queen Casandra"),
//                    Direction(step: 2, recipeId: 1, direction: "Bring back the pail of water making sure as to not spill a single drop of it"),
//                    Direction(step: 3, recipeId: 1, direction: "Pour yourself a glass of nice cold water")],
//                servings: 1)
//        ))
//        }
//    }
//}
