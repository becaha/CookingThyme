//
//  RecipeSearch.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/9/20.
//

import SwiftUI
import Combine

// TODO: no nav bar
struct RecipeSearch: View {
    @EnvironmentObject var sheetNavigator: SheetNavigator
    @EnvironmentObject var user: UserVM
    @EnvironmentObject var recipeSearchHandler: RecipeSearchHandler
    
    @State var hasSearched = false
    @State var keyboardPresented = false

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
                                    PublicRecipeView(recipe: recipe)
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
                            .onTapGesture(count: 1, perform: {})
                        }
                    }

                    if isLoading {
                        UIControls.Loading()
                            .padding()
                    }
                    
                }
                Spacer()
            }
            .background(formBackgroundColor())
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarColor(UIColor(navBarColor()), text: "Spoonacular Recipe Search", style: .headline, textColor: UIColor(formItemFont()))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onReceive(Publishers.keyboardHeight) { height in
            keyboardPresented = height == 0 ? false : true
        }
        .gesture(keyboardPresented ?
                    TapGesture(count: 1).onEnded {
            withAnimation {
                unfocusEditable()
            }
        } : nil)
    }
}

