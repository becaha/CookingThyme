//
//  CategoryView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/16/20.
//

import SwiftUI

struct CategoryView: View {
    var category: String
    var recipes: [Recipe]
    
    @State private var isCreatingRecipe = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Create Recipe")
                                                    
                        Spacer()
                        
                        UIControls.AddButton(action: createRecipe)
                    }
                }.sheet(isPresented: $isCreatingRecipe) {
                    EditRecipeView(isPresented: self.$isCreatingRecipe)
                }
            
                ForEach(recipes) { recipe in
                    NavigationLink("\(recipe.name)", destination: RecipeView(recipeVM: RecipeVM(recipe: recipe)))
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("\(category)", displayMode: .large)
        }
    }
    
    private func createRecipe() {
        isCreatingRecipe = true
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(category: "All", recipes: [
            Recipe(name: "Pasta", ingredients: [], directions: [], servings: 3),
            Recipe(name: "Salad", ingredients: [], directions: [], servings: 3),
            Recipe(name: "Bagels", ingredients: [], directions: [], servings: 3),
            Recipe(name: "Baguettes", ingredients: [], directions: [], servings: 3),
            Recipe(name: "Cinnamon Buns", ingredients: [], directions: [], servings: 3),
            Recipe(name: "Rolls", ingredients: [], directions: [], servings: 3),
            Recipe(name: "Pretzels", ingredients: [], directions: [], servings: 3),
            Recipe(name: "Milk", ingredients: [], directions: [], servings: 3)
        ])
    }
}
