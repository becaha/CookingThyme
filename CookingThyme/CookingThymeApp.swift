//
//  CookingThymeApp.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/18/20.
//

import SwiftUI

@main
struct CookingThymeApp: App {
    var body: some Scene {
        WindowGroup {
//            EditRecipeView()
            
//            RecipeView(
//                recipeVM: RecipeVM(recipe: Recipe(
//                    name: "Water",
//                    ingredients: [
//                        Ingredient(name: "water", amount: 1.05, unit: UnitOfMeasurement.Cup),
//                        Ingredient(name: "water", amount: 2.1, unit: UnitOfMeasurement.Cup),
//                        Ingredient(name: "water", amount: 1.3, unit: UnitOfMeasurement.Cup),
//                        Ingredient(name: "water", amount: 1.8, unit: UnitOfMeasurement.Cup),
//                        Ingredient(name: "water", amount: 1.95, unit: UnitOfMeasurement.Cup)
//                    ],
//                    directions: ["Fetch a pail of water from the wishing well in the land of the good queen Casandra", "Bring back the pail of water making sure as to not spill a single drop of it", "Boil the water thoroughly for an hour over medium-high heat", "Let the water cool until it is not steaming", "Put the water in the fridge to cool for 30 minutes", "Pour yourself a glass of nice cold water"],
//                    servings: 1)
//            ))
            
            
//            Form {
//                Section(header: Text("Photos")) {
//                    ImageView()
//                        .environmentObject(RecipeVM(
//                            recipe: Recipe(
//                                name: "Water",
//                                ingredients: [
//                                    Ingredient(name: "water", amount: 1.05, unitName: UnitOfMeasurement.cup),
//                                    Ingredient(name: "water", amount: 2.1, unitName: UnitOfMeasurement.cup),
//                                    Ingredient(name: "water", amount: 1.3, unitName: UnitOfMeasurement.cup),
//                                    Ingredient(name: "water", amount: 1.8, unitName: UnitOfMeasurement.cup),
//                                    Ingredient(name: "water", amount: 1.95, unitName: UnitOfMeasurement.cup)
//                                ],
//                                directions: [
//                                    Direction(step: 1, recipeId: 1, direction: "Fetch a pail of water from the wishing well in the land of the good queen Casandra"),
//                                    Direction(step: 2, recipeId: 1, direction: "Bring back the pail of water making sure as to not spill a single drop of it"),
//                                    Direction(step: 3, recipeId: 1, direction: "Pour yourself a glass of nice cold water")],
//                                images: [RecipeImage](),
//                                servings: 1),
//                            category: RecipeCategoryVM(category: RecipeCategory(name: "All", recipeCollectionId: 1), collection: RecipeCollectionVM(collection: RecipeCollection(id: 0, name: "Becca")))
//                    ))
//                }
//            }
            
//            RecipeCollectionView(collection: RecipeCollectionVM(collection: RecipeCollection(id: 1, name: "Becca")))
            
            HomeView(collection: RecipeCollectionVM(collection: RecipeCollection(id: 1, name: "Becca")))
            
//            AddImageView()
        }
    }
}
