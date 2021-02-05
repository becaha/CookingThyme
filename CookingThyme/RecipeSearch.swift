//
//  RecipeSearch.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/9/20.
//

import SwiftUI

// TODO: no nav bar
struct RecipeSearch: View {
    @EnvironmentObject var sheetNavigator: SheetNavigator
    @EnvironmentObject var user: UserVM
    
    @ObservedObject var recipeWebHandler = RecipeSearchHandler()
    
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
                                                PublicRecipeView(recipe: RecipeVM(recipe: recipe))
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
            .navigationBarTitle("Recipe Search", displayMode: .inline)
            .navigationBarColor(offWhiteUIColor())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct RecipeSearch_Previews: PreviewProvider {
    static var previews: some View {
        RecipeSearch()
    }
}
