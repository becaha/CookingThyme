//
//  CategoryView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/16/20.
//

import SwiftUI

struct CategoryView: View {
    @EnvironmentObject var category: RecipeCategoryVM
    @EnvironmentObject var collection: RecipeCollectionVM
        
    @State private var isEditing = false
    
    @State private var isCreatingRecipe = false
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(category.recipes) { recipe in
                    NavigationLink("\(recipe.name)", destination:
                                RecipeView(recipe: RecipeVM(recipe: recipe, category: category))
                                    .environmentObject(category)
                                    .environmentObject(collection)
                    )
                    .deletable(isDeleting: isEditing, onDelete: {
                        withAnimation {
                            collection.deleteRecipe(withId: recipe.id)
                        }
                    })
                }
                .onDelete { indexSet in
                    indexSet.map{ category.recipes[$0] }.forEach { recipe in
                        collection.deleteRecipe(withId: recipe.id)
                    }
                }
            }
            .padding(.top, 0)
        }
        .onAppear {
            category.popullateRecipes()
        }
        .background(formBackgroundColor())
        .listStyle(InsetGroupedListStyle())
    }
    
    private func createRecipe() {
        isCreatingRecipe = true
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView()
            .environmentObject(RecipeCategoryVM(category: RecipeCategory(name: "All", recipeCollectionId: 1), collection: RecipeCollectionVM(collection: RecipeCollection(id: 0, name: "Becca"))))
    }
}
