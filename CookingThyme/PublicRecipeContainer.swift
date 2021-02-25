//
//  PublicRecipeContainer.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/25/21.
//

import SwiftUI

struct PublicRecipeContainer: View {
    @Environment(\.presentationMode) var presentation

    @EnvironmentObject var sheetNavigator: SheetNavigator
    @EnvironmentObject var user: UserVM
    @EnvironmentObject var recipeSearchHandler: RecipeSearchHandler

    @State var recipeVM: RecipeVM?
    
    var recipe: Recipe

    var body: some View {
        Group {
            if recipeVM != nil {
                PublicRecipeView(recipe: recipeVM!)
            }
            else {
                VStack {
                    UIControls.Loading()
                }
            }
        }
        .onAppear {
            // only if appearing for first time
            if recipeVM == nil {
                recipeVM = RecipeVM(recipe: recipe, recipeSearchHandler: recipeSearchHandler)
            }
        }
    }
}
