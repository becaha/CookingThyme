//
//  CreateRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/24/20.
//

import SwiftUI

struct CreateRecipeView: View {
    @EnvironmentObject var category: RecipeCategoryVM
    @Binding var isCreatingRecipe: Bool
    @EnvironmentObject var recipe: RecipeVM
    @State var isImportingRecipe: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                    VStack {
//                        VStack {
//                            if !isEditingRecipe {
//                                ReadRecipeView(isEditingRecipe: self.$isEditingRecipe)
//                            }
//                            else {
//                                EditRecipeView(isEditingRecipe: self.$isEditingRecipe, isImportingRecipe: self.$isEditingRecipe)
//                            }
//                        }
                        EditRecipeView(isEditingRecipe: $isCreatingRecipe)
                    }
                    .navigationBarTitle("", displayMode: .inline)
            }
            .background(formBackgroundColor())
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
