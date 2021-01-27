//
//  PublicRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/10/20.
//

import SwiftUI

// TODO: make compatible with recipe
// TODO: make sure serving size doesnt change actual recipe that gets saved
// tODO: popovers to explain disabled buttons
struct PublicRecipeView: View {
    @EnvironmentObject var sheetNavigator: SheetNavigator
    @EnvironmentObject var user: UserVM
    @ObservedObject var recipe: PublicRecipeVM
    
    @State private var categoriesPresented = false
    
    @State private var signinAlert = false
    @State private var signinAlertMessage: String = ""

    private var isLoading: Bool {
        return recipe.isPopullating && !recipe.recipeNotFound
    }
    
    var body: some View {
        VStack {
            RecipeNameTitle(name: recipe.name)
            
            Form {
                if isLoading {
                    Section(header: UIControls.Loading()) {}
                }
                else if recipe.recipeNotFound {
                    HStack {
                        Spacer()
                        
                        Text("Error finding details for this recipe.")

                        Spacer()
                    }
                }
                else {
                    if recipe.imageHandler.images.count > 0 {
                        ReadImagesView(uiImages: recipe.imageHandler.images)
                    }
                    
                    IngredientsView(servings: $recipe.servings, ingredients: recipe.ingredients,
                        addToShoppingList: { ingredient in
                            user.collection!.addToShoppingList(ingredient)
                        },
                        addAllToShoppingList: { ingredients in
                            addAllIngredients(ingredients)
                        },
                        onNotSignedIn: {
                            signinAlert = true
                            signinAlertMessage = "Sign in to add ingredients to shopping list."
                        }
                    )
                    
                    DirectionsList(directions: recipe.directions)
                }
            }
        }
        .onAppear {
            withAnimation {
                recipe.popullateDetail()
            }
        }
        .sheet(isPresented: $categoriesPresented, content: {
            CategoriesSheet(currentCategoryId: nil, actionWord: "Save", isPresented: $categoriesPresented) { categoryId in
                recipe.copyRecipe(toCategoryId: categoryId, inCollection: user.collection!)
            }
            .environmentObject(user.collection!)
        })
        .alert(isPresented: $signinAlert, content: {
            Alert(title: Text("\(signinAlertMessage)"),
                  primaryButton: .default(Text("Sign in")) {
                    withAnimation {
                        sheetNavigator.showSheet = true
                        sheetNavigator.sheetDestination = .signin
                    }
                  },
                  secondaryButton: .cancel())
        })
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing:
                Button(action: {
                    if user.isSignedIn {
                        categoriesPresented = true
                    }
                    else {
                        signinAlert = true
                        signinAlertMessage = "Sign in to add recipe to your collection."
                    }
                })
                {
                    Image(systemName: "square.and.arrow.up")
                }
                .padding(.trailing)
                .disabled(isLoading || recipe.recipeNotFound)
        )
    }
    
    func addAllIngredients(_ ingredients: [Ingredient]) -> Bool {
        if user.isSignedIn {
            if user.collection != nil {
                user.collection!.addIngredientShoppingItems(ingredients: ingredients)
                return true
            }
        }
        else {
            signinAlert = true
            signinAlertMessage = "Sign in to add ingredients to shopping list."
        }
        return false
    }
    
}
