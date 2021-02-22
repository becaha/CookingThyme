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
                    Picker(selection: $recipe.tempRecipe.ratioServings, label:
                            HStack {
                                Text("Servings: \(recipe.tempRecipe.ratioServings) ")
                                    .textCase(.uppercase)
                                    .font(.subheadline)
                                    .fixedSize()
                        
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
                ForEach(0..<recipe.tempRecipe.ratioIngredients.count, id: \.self) { index in
                    VStack(spacing: 0) {
                        Button(action: {
                            if confirmAddIngredient == recipe.tempRecipe.ratioIngredients[index].id {
                                withAnimation {
                                    confirmAddIngredient = nil
                                }
                            }
                            else {
                                withAnimation {
                                    if user.isSignedIn {
                                        // for the first added ingredients, confirm
                                        if addedIngredients.count == 0 {
                                            confirmAddIngredient = recipe.tempRecipe.ratioIngredients[index].id
                                        }
                                        // for the rest, just add
                                        else if addedIngredients.count > 0 {
                                            callAddToShoppingList(recipe.tempRecipe.ratioIngredients[index])
                                        }
                                    }
                                    else {
                                        onNotSignedIn()
                                    }
                                }
                            }
                        }) {
                            HStack {
                                if addedIngredients.contains(recipe.tempRecipe.ratioIngredients[index].id) || self.addedAllIngredients {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(mainColor())

                                }
                                else {
                                    Image(systemName: "plus")
                                        .font(Font.subheadline.weight(.semibold))
                                        .frame(width: 20, height: 20, alignment: .center)
                                        .foregroundColor(.black)
                                }
                                
                                RecipeControls.ReadIngredientText(recipe.tempRecipe.ratioIngredients[index])
                                    .foregroundColor(.black)
                            }
                            .formSectionItem(isLastItem: recipe.tempRecipe.ratioIngredients[index].id == recipe.tempRecipe.ratioIngredients[recipe.tempRecipe.ratioIngredients.count - 1].id)
                        }
                        
                        if confirmAddIngredient == recipe.tempRecipe.ratioIngredients[index].id {
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        callAddToShoppingList(recipe.tempRecipe.ratioIngredients[index])
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
                            .formSectionItem(isLastItem: recipe.tempRecipe.ratioIngredients[index].id == recipe.tempRecipe.ratioIngredients[recipe.tempRecipe.ratioIngredients.count - 1].id, backgroundColor: mainColor())
                        }
                    }
                }
            }
            .formSection()
            
            HStack {
                VStack(alignment: .center) {
                    Button(action: {
                        withAnimation {
                            if addAllToShoppingList(recipe.tempRecipe.ratioIngredients.filter({ (ingredient) -> Bool in
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
            .onAppear {
                // sets ratio servings and ingredients
                if recipe.tempRecipe.servings != 0 {
                    recipe.tempRecipe.ratioServings = recipe.tempRecipe.servings
                }
                if recipe.tempRecipe.ratioIngredients.count > 0 {
                    recipe.tempRecipe.ratioIngredients = recipe.tempRecipe.ingredients
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
