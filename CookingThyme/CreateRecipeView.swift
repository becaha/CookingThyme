//
//  CreateRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/24/20.
//

import SwiftUI

struct CreateRecipeView: View {
    @EnvironmentObject var categoryVM: RecipeCategoryVM
    @Binding var isPresented: Bool
    @ObservedObject var recipeVM: RecipeVM
    
    var body: some View {
        EditRecipeView(isPresented: $isPresented, recipeVM: recipeVM)
    }
}
