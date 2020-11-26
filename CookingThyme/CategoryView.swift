//
//  CategoryView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/16/20.
//

import SwiftUI

struct CategoryView: View {
    @EnvironmentObject var category: RecipeCategoryVM
    
//    @State private var editMode: EditMode = .inactive
    
    @State private var isEditing = false
    
    @State private var isCreatingRecipe = false
    
    var body: some View {
        List {
            if isEditing {
                Section {
                    HStack {
                        Text("Create Recipe")
                                                    
                        Spacer()
                        
                        UIControls.AddButton(action: createRecipe)
                    }
                }.sheet(isPresented: $isCreatingRecipe) {
                    CreateRecipeView(isPresented: self.$isCreatingRecipe, recipeVM: RecipeVM(category: category))
                }
            }
        
            Section {
                ForEach(category.recipes) { recipe in
                    if isEditing {
                        Text("\(recipe.name)")
                            .deletable(isDeleting: isEditing, onDelete: {
                                category.deleteRecipe(withId: recipe.id)
                            })
                    }
                    else {
                        NavigationLink("\(recipe.name)", destination:
                                        RecipeView(recipeVM: RecipeVM(recipe: recipe, category: category))
                                .environmentObject(category)
                        )
                    }
                }
                .onDelete { indexSet in
                    indexSet.map{ category.recipes[$0] }.forEach { recipe in
                        category.deleteRecipe(withId: recipe.id)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("\(category.name)", displayMode: .large)
        .navigationBarItems(trailing:
            UIControls.EditButton(
                action: {
                    isEditing.toggle()
                },
                isEditing: isEditing)
        )
//        .environment(\.editMode, $editMode)
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
