//
//  ReadRecipeInfo.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/26/21.
//

import SwiftUI

struct RecipeNameTitle: View {
    var name: String
    
    var body: some View {
        Text("\(name)")
            .recipeTitle()
            .recipeTitleBorder()
    }
}

struct IngredientsView: View {
    @Binding var servings: Int
    
    @EnvironmentObject var user: UserVM
    var ingredients: [Ingredient]
    var addToShoppingList: (Ingredient) -> Void
    var addAllToShoppingList: ([Ingredient]) -> Bool
    var onNotSignedIn: () -> Void
    
    @State private var confirmAddIngredient: Int?
    @State private var addedAllIngredients = false
    @State private var addedIngredients = [Int]()

    var body: some View {
        Section(header:
                    HStack {
                        Text("Ingredients")
                        
                        Spacer()
                        
                        VStack {
                            // should be changing servings but not in db
                            Picker(selection: $servings, label:
                                    HStack {
                                        Text("Serving Size: \(servings)")
                                
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
                        VStack(alignment: .center) {
                            Button(action: {
                                withAnimation {
                                    if addAllToShoppingList(ingredients.filter({ (ingredient) -> Bool in
                                        !addedIngredients.contains(ingredient.id)
                                    })) {
                                        addedAllIngredients = true
                                    }
                                    else {
                                        addedAllIngredients = false
                                    }
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color(UIColor.tertiarySystemFill))
                                    
                                    HStack {
                                        Image(systemName: "cart.fill")
                                        
                                        Text("Add All to Shopping List")
                                            .padding(.vertical)
                                    }
                                }
                            }
                            .disabled(addedAllIngredients)
                        }
                    }
        ) {
            List {
                ForEach(ingredients) { ingredient in
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
                                        onNotSignedIn()
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
                                    confirmAddIngredient = nil
                                    addedIngredients.append(ingredient.id)
                                    addToShoppingList(ingredient)
                                }
                            })
                        }
                        .foregroundColor(mainColor())
                    }
                }
            }
        
        }
    }
}
    
struct DirectionsList: View {
    var directions: [Direction]
    
    var body: some View {
        Section(header: Text("Directions")) {
            List {
                ForEach(0..<directions.count, id: \.self) { index in
                    RecipeControls.ReadDirection(withIndex: index, direction: directions[index].direction)
                }
            }
        }
    }
}
