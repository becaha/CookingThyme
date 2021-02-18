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

struct RecipeLists: View {
    @EnvironmentObject var recipe: RecipeVM
    @EnvironmentObject var user: UserVM

    var addToShoppingList: (Ingredient) -> Void
    var addAllToShoppingList: ([Ingredient]) -> Bool
    var onNotSignedIn: () -> Void
    
    var body: some View {
        VStack {
            IngredientsView(
                addToShoppingList: { ingredient in
                    addToShoppingList(ingredient)
                },
                addAllToShoppingList: { ingredients in
                    addAllToShoppingList(ingredients)
                },
                onNotSignedIn: onNotSignedIn)
                .environmentObject(recipe)
            
            DirectionsList()
            
            SourceCredit()
        }
    }
}

struct SourceCredit: View {
    @EnvironmentObject var recipe: RecipeVM

    var body: some View {
        if recipe.source != "" {
            HStack {
                Text("Source: \(recipe.tempRecipe.source)")
                    .font(.caption)
            }
            .padding()
        }
    }
}

struct IngredientsView: View {
    @EnvironmentObject var user: UserVM
    @EnvironmentObject var recipe: RecipeVM
    
    var addToShoppingList: (Ingredient) -> Void
    var addAllToShoppingList: ([Ingredient]) -> Bool
    var onNotSignedIn: () -> Void
    
    @State private var confirmAddIngredient: String?
    @State private var addedAllIngredients = false
    @State private var addedIngredients = [String]()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Ingredients")
                    .textCase(.uppercase)
                    .font(.subheadline)
                
                Spacer()
                
                VStack {
                    Picker(selection: $recipe.tempRecipe.servings, label:
                            HStack {
                                Text("Servings: \(recipe.tempRecipe.servings) ")
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
            
            // TODO have the read recipe just read the temps so it doesn't have to reload from db on the save
            VStack(spacing: 0) {
                ForEach(recipe.tempRecipe.ingredients, id: \.self) { ingredient in
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
                        .formSectionItem(isLastItem: ingredient.id == recipe.tempRecipe.ingredients[recipe.tempRecipe.ingredients.count - 1].id)
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
                            .formSectionItem(isLastItem: ingredient.id == recipe.tempRecipe.ingredients[recipe.tempRecipe.ingredients.count - 1].id, backgroundColor: mainColor())
                        }
                    }
                }
            }
            .formSection()
            
            HStack {
                VStack(alignment: .center) {
                    Button(action: {
                        withAnimation {
                            if addAllToShoppingList(recipe.tempRecipe.ingredients.filter({ (ingredient) -> Bool in
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
        if addedIngredients.count == recipe.tempRecipe.ingredients.count {
            addedAllIngredients = true
        }
    }
}
    
struct DirectionsList: View {
    @EnvironmentObject var recipe: RecipeVM

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
                ForEach(0..<recipe.tempRecipe.directions.count, id: \.self) { index in
                    RecipeControls.ReadDirection(withIndex: index, direction: recipe.tempRecipe.directions[index].direction)
                        .formSectionItem(isLastItem: index == recipe.tempRecipe.directions.count - 1)
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
