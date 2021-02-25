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
    
    @State private var currentCategoryId: String?

    private var isLoading: Bool {
        return recipe.isLoading == true && !recipe.recipeNotFound
    }
    
    var body: some View {
        ScrollView(.vertical) {
            Group {
                RecipeNameTitle(name: recipe.tempRecipe.name)
                
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
                            ImagesView(isEditing: false)
                        }
                        
                        RecipeLists(
                            addToShoppingList: { ingredient in
                                user.collection!.addIngredientShoppingItem(ingredient)
                            },
                            addAllToShoppingList: { ingredients in
                                addAllIngredients(ingredients)
                            },
                            onNotSignedIn: {
                                signinAlert = true
                                signinAlertMessage = "Sign in to add ingredients to shopping list."
                            })
                    }
                }
                .environmentObject(recipe)
            }
            .sheet(isPresented: $categoriesPresented, content: {
                CategoriesSheet(currentCategoryId: currentCategoryId, actionWord: "Save", isPresented: $categoriesPresented, onAction: { categoryId in
                    if currentCategoryId == nil {
                        recipe.copyRecipe(toCategoryId: categoryId, inCollection: user.collection!)
                    }
                    else {
                        RecipeVM.moveRecipe(recipe.recipe, toCategoryId: categoryId)
                    }
                    currentCategoryId = categoryId

                }, onRemove: { categoryId in })
                .environmentObject(user.collection!)
            })
        }
        .navigationBarColor(UIColor(navBarColor()), text: "", style: .headline, textColor: UIColor(formItemFont()))
        .background(formBackgroundColor().edgesIgnoringSafeArea(.all))
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
                .disabled(isLoading || recipe.recipeNotFound == true || currentCategoryId != nil)
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
