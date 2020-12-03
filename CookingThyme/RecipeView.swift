//
//  RecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import SwiftUI

struct RecipeView: View {
    @EnvironmentObject var category: RecipeCategoryVM
    @ObservedObject var recipeVM: RecipeVM
        
    @State private var inEditMode = false
    
    @State private var isCreatingRecipe = false
    
    var body: some View {
        VStack {
            if !isCreatingRecipe {
                ZStack {
                    Text("\(recipeVM.name)")
                        .font(.system(size: 34, weight: .bold))
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            isCreatingRecipe = true
                        })
                        {
                            Text("Edit")
                        }
                    }
                    .padding()
                }
                ReadRecipeView(isPresented: self.$isCreatingRecipe, recipeVM: recipeVM)
            }
            else {
                EditRecipeView(isPresented: self.$isCreatingRecipe, recipeVM: recipeVM)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
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
                    servings: 1),
               category: RecipeCategoryVM(category: RecipeCategory(name: "All", recipeCollectionId: 1))
        ))
        }
    }
}
