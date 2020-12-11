//
//  PublicRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/10/20.
//

import SwiftUI

struct PublicRecipeView: View {
    @EnvironmentObject var collection: RecipeCollectionVM
    @ObservedObject var recipe: PublicRecipeVM
    
    @State private var actionSheetPresented = false
    @State private var categoriesPresented = false
    
    @State private var confirmAddIngredient: Int?
    
    private var isLoading: Bool {
        return recipe.isPopullating && !recipe.recipeNotFound
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("\(recipe.name)")
                    .font(.system(size: 30, weight: .bold))
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
                                RecipeControls.AddIngredientsButton(collection: collection, recipe: recipe.recipe)
                        ) {
                        List {
                            ForEach(recipe.ingredients) { ingredient in
                                HStack {
                                    UIControls.AddButton(action: {
                                        withAnimation {
                                            confirmAddIngredient = ingredient.id
                                        }
                                    })
                                    
                                    RecipeControls.ReadIngredientText(ingredient)
                                }
                                if confirmAddIngredient == ingredient.id {
                                    HStack {
                                        Image(systemName: "cart.fill")
                                        
                                        Button("Add to Shopping List", action: {
                                            withAnimation {
                                                collection.addToShoppingList(ingredient)
                                                confirmAddIngredient = nil
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
    
}

//struct PublicRecipeView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//        ReadRecipeView(isPresented: <#T##Binding<Bool>#>,
//            recipeVM: RecipeVM(recipe: Recipe(
//                name: "Water",
//                ingredients: [
//                    Ingredient(name: "water", amount: 1.05, unitName: UnitOfMeasurement.Cup),
//                    Ingredient(name: "water", amount: 2.1, unitName: UnitOfMeasurement.Cup),
//                    Ingredient(name: "water", amount: 1.3, unitName: UnitOfMeasurement.Cup),
//                    Ingredient(name: "water", amount: 1.8, unitName: UnitOfMeasurement.Cup),
//                    Ingredient(name: "water", amount: 1.95, unitName: UnitOfMeasurement.Cup)
//                ],
//                directions: [
//                    Direction(step: 1, recipeId: 1, direction: "Fetch a pail of water from the wishing well in the land of the good queen Casandra"),
//                    Direction(step: 2, recipeId: 1, direction: "Bring back the pail of water making sure as to not spill a single drop of it"),
//                    Direction(step: 3, recipeId: 1, direction: "Pour yourself a glass of nice cold water")],
//                servings: 1)
//        ))
//        }
//    }
//}

