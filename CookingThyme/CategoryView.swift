//
//  CategoryView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/16/20.
//

import SwiftUI

struct CategoryView: View {
    @EnvironmentObject var category: RecipeCategoryVM
    
    @State private var isCreatingRecipe = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Create Recipe")
                                                
                    Spacer()
                    
                    UIControls.AddButton(action: createRecipe)
                }
            }.sheet(isPresented: $isCreatingRecipe) {
                CreateRecipeView(isPresented: self.$isCreatingRecipe)
            }
        
            ForEach(category.recipes) { recipe in
                NavigationLink("\(recipe.name)", destination:
                    RecipeView(recipeVM: RecipeVM(recipe: recipe))
                        .environmentObject(category)
                )
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("\(category.name)", displayMode: .large)
    }
    
    private func createRecipe() {
        isCreatingRecipe = true
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView()
            .environmentObject(RecipeCategoryVM(category: RecipeCategory(name: "All", recipeCollectionId: 1)))
    }
}
