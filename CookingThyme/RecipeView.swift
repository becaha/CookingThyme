//
//  RecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import SwiftUI

struct RecipeView: View {
    @EnvironmentObject var collection: RecipeCollectionVM
    @EnvironmentObject var category: RecipeCategoryVM
    @ObservedObject var recipeVM: RecipeVM
            
    @State private var isEditingRecipe = false
    
    var body: some View {
        VStack {
            if !isEditingRecipe {
                ReadRecipeView(isEditingRecipe: self.$isEditingRecipe)
            }
            else {
                EditRecipeView(isEditingRecipe: self.$isEditingRecipe)
            }
        }
        .environmentObject(recipeVM)
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
        RecipeView(
            recipeVM: RecipeVM(
                recipe: Recipe(
                    name: "Water",
                    ingredients: [
                        Ingredient(name: "water", amount: 1.05, unitName: UnitOfMeasurement.cup),
                        Ingredient(name: "water", amount: 2.1, unitName: UnitOfMeasurement.cup),
                        Ingredient(name: "water", amount: 1.3, unitName: UnitOfMeasurement.cup),
                        Ingredient(name: "water", amount: 1.8, unitName: UnitOfMeasurement.cup),
                        Ingredient(name: "water", amount: 1.95, unitName: UnitOfMeasurement.cup)
                    ],
                    directions: [
                        Direction(step: 1, recipeId: 1, direction: "Fetch a pail of water from the wishing well in the land of the good queen Casandra"),
                        Direction(step: 2, recipeId: 1, direction: "Bring back the pail of water making sure as to not spill a single drop of it"),
                        Direction(step: 3, recipeId: 1, direction: "Pour yourself a glass of nice cold water")],
                    images: [RecipeImage](),
                    servings: 1),
                category: RecipeCategoryVM(category: RecipeCategory(name: "All", recipeCollectionId: 1), collection: RecipeCollectionVM(collection: RecipeCollection(id: 0, name: "Becca")))
        ))
        }
    }
}
