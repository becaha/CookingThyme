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
    
    private func createRecipe() {
        isCreatingRecipe = true
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(category: "All", recipes: [
            Recipe(id: 0, name: "Pasta", servings: 3),
            Recipe(id: 1, name: "Salad", servings: 3),
            Recipe(id: 2, name: "Bagels", servings: 3),
            Recipe(id: 3, name: "Baguettes", servings: 3),
            Recipe(id: 4, name: "Cinnamon Buns", servings: 3),
            Recipe(id: 5, name: "Rolls", servings: 3),
            Recipe(id: 6, name: "Pretzels", servings: 3),
            Recipe(id: 7, name: "Milk", servings: 3)
        ])
    }
}
