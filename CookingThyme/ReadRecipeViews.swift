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

// TODO: add all should be disabled if all have been added
struct RecipeLists: View {
    @EnvironmentObject var recipe: RecipeVM
    
    @EnvironmentObject var user: UserVM
    var ingredients: [Ingredient]
    var addToShoppingList: (Ingredient) -> Void
    var addAllToShoppingList: ([Ingredient]) -> Bool
    var onNotSignedIn: () -> Void
    
    var directions: [Direction]
    
    var body: some View {
        VStack {
            IngredientsView(ingredients: ingredients,
                addToShoppingList: { ingredient in
                    addToShoppingList(ingredient)
                },
                addAllToShoppingList: { ingredients in
                    addAllToShoppingList(ingredients)
                },
                onNotSignedIn: onNotSignedIn)
            
            DirectionsList(directions: directions)
        }
    }
}

struct IngredientsView: View {
    @EnvironmentObject var recipe: RecipeVM
    
    @EnvironmentObject var user: UserVM
    var ingredients: [Ingredient]
    var addToShoppingList: (Ingredient) -> Void
    var addAllToShoppingList: ([Ingredient]) -> Bool
    var onNotSignedIn: () -> Void
    
    @State private var confirmAddIngredient: Int?
    @State private var addedAllIngredients = false
    @State private var addedIngredients = [Int]()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Ingredients")
                    .textCase(.uppercase)
                    .font(.subheadline)
                
                Spacer()
                
                VStack {
                    Picker(selection: $recipe.servings, label:
                            HStack {
                                Text("Servings: \(recipe.servings) ")
                                    .textCase(.uppercase)
                                    .font(.subheadline)
                        
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
            }
            .formHeader()
            
            VStack(spacing: 0) {
                ForEach(ingredients) { ingredient in
                    VStack(spacing: 0) {
                        HStack {
                            if addedIngredients.contains(ingredient.id) || self.addedAllIngredients {
                                Image(systemName: "checkmark")
                                    .foregroundColor(mainColor())
                            }
                            else {
                                UIControls.AddButton(action: {
                                    withAnimation {
                                        if user.isSignedIn {
                                            // for the first added ingredients, confirm
                                            if addedIngredients.count == 0 {
                                                confirmAddIngredient = ingredient.id
                                            }
                                            // for the rest, just add
                                            else if addedIngredients.count > 0 {
                                                callAddToShoppingList(ingredient)
                                            }
                                        }
                                        else {
                                            onNotSignedIn()
                                        }
                                    }
                                })
                            }
                            
                            RecipeControls.ReadIngredientText(ingredient)
                        }
                        .formSectionItem(isLastItem: ingredient.id == ingredients[ingredients.count - 1].id)
                        if confirmAddIngredient == ingredient.id {

                            HStack {
                                Button(action: {
                                    withAnimation {
                                        callAddToShoppingList(ingredient)
                                    }
                                }) {
                                    Image(systemName: "cart.fill.badge.plus")

                                    Text("Add to Shopping List")
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation {
                                        confirmAddIngredient = nil
                                    }
                                }) {
                                    Image(systemName: "xmark.circle")
                                }
                            }
                            .foregroundColor(formBackgroundColor())
                            .formSectionItem(isLastItem: ingredient.id == ingredients[ingredients.count - 1].id, backgroundColor: mainColor())
                        }
                    }
                }
            }
            .formSection()
            
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
                        HStack {
                            Spacer()
                            
                            Image(systemName: "cart.fill.badge.plus")
                            
                            Text("Add All to Shopping List")
                                .padding(.vertical)
                            
                            Spacer()
                        }
                        .overlay(RoundedRectangle(cornerRadius: 5)
                                    .fill(Color(UIColor.tertiarySystemFill)))
                    }
                    .disabled(addedAllIngredients)
                }
            }
            .padding([.horizontal, .bottom])
            .padding(.top, 5)
        }
    }
    
    func callAddToShoppingList(_ ingredient: Ingredient) {
        confirmAddIngredient = nil
        addedIngredients.append(ingredient.id)
        addToShoppingList(ingredient)
    }
}
    
struct DirectionsList: View {
    var directions: [Direction]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Directions")
                    .textCase(.uppercase)
                    .font(.subheadline)
                
                Spacer()
            }
            .formHeader()

            VStack(spacing: 0) {
                ForEach(0..<directions.count, id: \.self) { index in
                    RecipeControls.ReadDirection(withIndex: index, direction: directions[index].direction)
                        .formSectionItem(isLastItem: index == directions.count - 1)
                }
            }
            .formSection()
        }
    }
}

struct FormHeader: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding([.horizontal, .top])
            .padding(.bottom, 5)
            .foregroundColor(Color.gray)
    }
}

extension View {
    func formHeader() -> some View {
        modifier(FormHeader())
    }
}

struct FormFooter: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding([.horizontal, .bottom])
            .padding(.top, 5)
            .foregroundColor(Color.gray)
    }
}

extension View {
    func formFooter() -> some View {
        modifier(FormFooter())
    }
}
