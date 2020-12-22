//
//  PublicRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/10/20.
//

import SwiftUI

// TODO: make sure serving size doesnt change actual recipe that gets saved

struct PublicRecipeView: View {
    @EnvironmentObject var collection: RecipeCollectionVM
    @ObservedObject var recipe: PublicRecipeVM
    
    @State private var actionSheetPresented = false
    @State private var categoriesPresented = false
    
    @State private var confirmAddIngredient: Int?
    @State private var addedIngredients = [Int]()
    @State private var addedAllIngredients = false

    
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
                            RecipeControls.AddIngredientsButton(collection: collection, recipe: recipe.recipe, action: addAllIngredients)
                        ) {
                        List {
                            ForEach(recipe.ingredients) { ingredient in
                                HStack {
                                    if addedIngredients.contains(ingredient.id) || self.addedAllIngredients {                                        Image(systemName: "checkmark")
                                            .foregroundColor(mainColor())
                                    }
                                    else {
                                        UIControls.AddButton(action: {
                                            withAnimation {
                                                confirmAddIngredient = ingredient.id
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
                                                collection.addToShoppingList(ingredient)
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
            List{
                ForEach(collection.categories, id: \.self) { category in
                    Button(action: {
                        recipe.copyRecipe(toCategoryId: category.id)
                        categoriesPresented = false
                    }) {
                        Text("\(category.name)")
                            .foregroundColor(.black)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        })
        .actionSheet(isPresented: $actionSheetPresented, content: {
            ActionSheet(title: Text(""), message: nil, buttons:
                [
                    .default(Text("Add to category"), action: {
                        categoriesPresented = true
                    }),
                    .cancel()
                ])
        })
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing:
                HStack {
                    Button(action: {
                        actionSheetPresented = true
                    })
                    {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .padding(.trailing)
                }
                .disabled(isLoading || recipe.recipeNotFound)
        )
    }
    
    func addAllIngredients() {
        self.addedAllIngredients = true
    }
    
}
