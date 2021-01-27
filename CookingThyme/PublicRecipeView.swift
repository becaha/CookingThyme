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
    
    @State private var confirmAddIngredient: Int?
    @State private var addedIngredients = [Int]()
    @State private var addedAllIngredients = false
    
    @State private var signinAlert = false
    @State private var signinAlertMessage: String = ""

    private var isLoading: Bool {
        return recipe.isPopullating && !recipe.recipeNotFound
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("\(recipe.name)")
                    .font(.title)
                    .multilineTextAlignment(.center)
            }
            .padding()
            
            
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
                    Section(header: Text("Photos")) {
                        ReadImagesView(uiImages: recipe.imageHandler.images)
                    }
                    
                    Section(header:
                        HStack {
                            Text("Ingredients")
                            
                            Spacer()
                            
                            VStack {
                                // should be changing servings but not in db
                                Picker(selection: $recipe.servings, label:
                                        HStack {
                                            Text("Serving Size: \(recipe.servings)")
                                    
                                            Image(systemName: "chevron.down")
                                        }
                                )
                                {
                                    ForEach(1..<101, id: \.self) { num in
                                        Text("\(num.toString())").tag(num.toString())
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                        },
                            footer:
                                HStack {
                                    RecipeControls.AddIngredientsButton(collection: user.collection, recipe: recipe.recipe, action: addAllIngredients)
                                }
                        ) {
                        List {
                            ForEach(recipe.ingredients) { ingredient in
                                HStack {
                                    if addedIngredients.contains(ingredient.id) || self.addedAllIngredients {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(mainColor())
                                    }
                                    else {
                                        UIControls.AddButton(action: {
                                            withAnimation {
                                                if user.isSignedIn {
                                                    confirmAddIngredient = ingredient.id
                                                }
                                                else {
                                                    signinAlert = true
                                                    signinAlertMessage = "Sign in to add ingredients to shopping list."
                                                }
                                            }
                                        })
                                    }
                                    
                                    RecipeControls.ReadIngredientText(ingredient)
                                }
                                if confirmAddIngredient == ingredient.id {
                                    HStack {
                                        Image(systemName: "cart.fill")
                                        
                                        Button("Add to Shopping List", action: {
                                            withAnimation {
                                                user.collection!.addToShoppingList(ingredient)
                                                confirmAddIngredient = nil
                                                addedIngredients.append(ingredient.id)
                                            }
                                        })
                                    }
                                    .foregroundColor(Color(UIColor.systemGray))
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Directions")) {
                        // TODO make list collapsable so after a step is done, it collapses
                        List {
                            ForEach(0..<recipe.directions.count, id: \.self) { index in
                                RecipeControls.ReadDirection(withIndex: index, recipe: recipe.recipe)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            withAnimation {
                recipe.popullateDetail()
            }
        }
        .sheet(isPresented: $categoriesPresented, content: {
            CategoriesSheet(actionWord: "Save", isPresented: $categoriesPresented) { categoryId in
                recipe.copyRecipe(toCategoryId: categoryId)
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
    
    func addAllIngredients() {
        if user.isSignedIn {
            self.addedAllIngredients = true
        }
        else {
            signinAlert = true
            signinAlertMessage = "Sign in to add ingredients to shopping list."
        }
    }
    
}
