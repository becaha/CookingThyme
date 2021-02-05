//
//  PublicRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/10/20.
//

import SwiftUI

struct PublicRecipeView: View {
    @Environment(\.presentationMode) var presentation

    @EnvironmentObject var sheetNavigator: SheetNavigator
    @EnvironmentObject var user: UserVM
    @ObservedObject var recipe: RecipeVM
    
    @State private var categoriesPresented = false
    
    @State private var signinAlert = false
    @State private var signinAlertMessage: String = ""
    
    @State private var currentCategoryId: Int?

    private var isLoading: Bool {
        return recipe.isPopullating && !recipe.recipeNotFound
    }
    
    var body: some View {
        ScrollView(.vertical) {
            RecipeNameTitle(name: recipe.name)
            
            VStack {
                if isLoading {
                    UIControls.Loading()
                    
                    Spacer()
                }
                else if recipe.recipeNotFound {
                    HStack {
                        Spacer()
                        
                        Text("Error finding details for this recipe.")

                        Spacer()
                    }
                    
                    Spacer()
                }
                else {
                    if recipe.imageHandler.images.count > 0 {
                        ReadImagesView(uiImages: recipe.imageHandler.images)
                    }
                    
                    RecipeLists(
                        addToShoppingList: { ingredient in
                            user.collection!.addToShoppingList(ingredient)
                        },
                        addAllToShoppingList: { ingredients in
                            addAllIngredients(ingredients)
                        },
                        onNotSignedIn: {
                            signinAlert = true
                            signinAlertMessage = "Sign in to add ingredients to shopping list."
                        })
                        .environmentObject(recipe)
                }
            }
        }
        .navigationBarColor(offWhiteUIColor())
        .background(formBackgroundColor().edgesIgnoringSafeArea(.all))
        .onAppear {
            withAnimation {
                recipe.popullateDetail()
            }
        }
        .sheet(isPresented: $categoriesPresented, content: {
            CategoriesSheet(currentCategoryId: currentCategoryId, actionWord: "Save", isPresented: $categoriesPresented) { categoryId in
                if currentCategoryId == nil {
                    recipe.copyRecipe(toCategoryId: categoryId, inCollection: user.collection!)
                }
                else {
                    RecipeVM.moveRecipe(recipe.recipe, toCategoryId: categoryId)
                }
                currentCategoryId = categoryId

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
