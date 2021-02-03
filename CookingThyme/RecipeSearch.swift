//
//  RecipeSearch.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/9/20.
//

import SwiftUI

// TODO dont scroll thorugh the battery life and clock at top
struct RecipeSearch: View {
    @EnvironmentObject var sheetNavigator: SheetNavigator
    @EnvironmentObject var user: UserVM
    
    @ObservedObject var recipeWebHandler = RecipesWebHandler()
    
    @State var hasSearched = false
        
    private var isLoading: Bool {
        return recipeWebHandler.listingRecipes && hasSearched
    }
    
    var body: some View {
        NavigationView {
            Form {                
                Section {
                    SearchBar(isAutoSearch: false)  { result in
                        hasSearched = true
                        recipeWebHandler.listRecipes(withQuery: result)
                    }
                }

                if recipeWebHandler.recipeList.count == 0 && !isLoading && hasSearched {
                    Section(header:
                        HStack {
                            Spacer()

                            Text("No Results")

                            Spacer()
                        }
                    ) {}
                }

                if recipeWebHandler.recipeList.count > 0 {
                    List {
                        ForEach(recipeWebHandler.recipeList) { recipe in
                            NavigationLink ("\(recipe.name)", destination:
                                PublicRecipeView(recipe: PublicRecipeVM(publicRecipe: recipe))
                            )
                        }
                    }

                    if !isLoading && recipeWebHandler.isMore {
                        Section {
                            Button(action: {
                                withAnimation {
                                    recipeWebHandler.listMoreRecipes()
                                }
                            }) {
                                HStack {
                                    Spacer()

                                    Text("More")

                                    Spacer()
                                }
                            }
                        }
                    }
                }

                if isLoading {
                    Section(header: UIControls.Loading()) {}
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct RecipeSearch_Previews: PreviewProvider {
    static var previews: some View {
        RecipeSearch()
    }
}
