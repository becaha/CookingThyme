//
//  CreateRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/10/21.
//

import SwiftUI

struct CreateRecipeView: View {
    //solves not saving recipe on save recipe
    // parent loads -> calls INIT which reinitializes
    // on new creaate, has old stuff
//    @EnvironmentObject var collection: RecipeCollectionVM
//    @ObservedObject var category: RecipeCategoryVM
//    @ObservedObject var recipe: RecipeVM
//
//    // child alert calls init
//    init(category: RecipeCategoryVM) {
//        self.category = category
//        recipe = RecipeVM(category: category)
//    }
//
//    var body: some View {
//        RecipeView(recipe: recipe, isEditingRecipe: true)
//            .environmentObject(category)
//            .onAppear {
//                print("")
//            }
//    }
    
    // solves reinit recipe with alert
    // problem: child loads -> calls view which reinitializes without calling init or onappear

    @EnvironmentObject var collection: RecipeCollectionVM
    @ObservedObject var category: RecipeCategoryVM
    @State var recipe: RecipeVM?
    
    init(category: RecipeCategoryVM) {
        self.category = category
    }

    var body: some View {
        Group {
            if recipe != nil {
                RecipeView(recipe: recipe!, isEditingRecipe: true)
            }
        }
        .environmentObject(category)
        .onAppear {
            recipe = RecipeVM(category: category)
        }
    }
}

