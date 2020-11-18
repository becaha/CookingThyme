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
    
    var body: some View {
        NavigationView {
            List {
                ForEach(recipes) { recipe in
                    NavigationLink("\(recipe.name)", destination: RecipeView(recipeVM: RecipeVM(recipe: recipe)))
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("\(category)", displayMode: .large)
        }
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
