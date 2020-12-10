//
//  RecipeSearch.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/9/20.
//

import SwiftUI

struct RecipeSearch: View {
    @ObservedObject var recipeWebHandler = RecipesWebHandler()
    
    var body: some View {
        VStack {
            Button(action: {
                recipeWebHandler.listRecipes(withQuery: "pasta")
            }) {
                Text("RecipeSearch")
            }
            
            List {
                ForEach(recipeWebHandler.foundRecipes) { recipe in
                    Text("\(recipe.name!)")
                }
            }
        }
    }
}

struct RecipeSearch_Previews: PreviewProvider {
    static var previews: some View {
        RecipeSearch()
    }
}
