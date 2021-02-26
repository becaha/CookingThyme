//
//  RecipeSearch.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/9/20.
//

import SwiftUI
import Combine

struct RecipeSearch: View {
    @EnvironmentObject var sheetNavigator: SheetNavigator
    @EnvironmentObject var user: UserVM
    @EnvironmentObject var recipeSearchHandler: RecipeSearchHandler
    
    @State var hasSearched = false

    @State var receivedRecipes = false

    private var isLoading: Bool {
        return recipeSearchHandler.listingRecipes && hasSearched
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    HStack {
                        SearchBar(isAutoSearch: false)  { result in
                            hasSearched = true
                            recipeSearchHandler.listRecipes(withQuery: result)
                        }
                    }
                    .formItem(isSearchBar: true)
                    .padding(.top)

                    if recipeSearchHandler.recipeList.count == 0 && !isLoading && hasSearched {
                        HStack {
                            Spacer()

                            Text("No Results.")

                            Spacer()
                        }
                        .formItem()
                    }

                    if recipeSearchHandler.recipeList.count > 0 {
                        VStack(spacing: 0) {
                            ForEach(recipeSearchHandler.recipeList, id: \.self) { recipe in
                                NavigationLink(destination:
                                    PublicRecipeContainer(recipe: recipe)
                                                .environmentObject(recipeSearchHandler)
                                ) {
                                    Text("\(recipe.name)")
                                        .customFont(style: .subheadline)
                                        .formItem(isNavLink: true)
                                }
                            }
                        }

                        if !isLoading && recipeSearchHandler.isMore {
                            Button(action: {
                                withAnimation {
                                    recipeSearchHandler.listMoreRecipes()
                                }
                            }) {
                                HStack {
                                    Spacer()

                                    Text("More")
                                        .bold()
                                        .foregroundColor(.white)

                                    Spacer()
                                }
                                .formItem(backgroundColor: mainColor())
                            }
                            .padding(.vertical)
                        }
                    }

                    if isLoading {
                        UIControls.Loading()
                            .padding()
                    }
                    
                    
                }
            }
            .background(formBackgroundColor())
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarColor(UIColor(navBarColor()), text: "Spoonacular Recipe Search", style: .headline, textColor: UIColor(formItemFont()))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

