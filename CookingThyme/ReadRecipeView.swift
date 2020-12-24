//
//  ReadRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/24/20.
//

import SwiftUI

// TODO deal with plural ingredient unitNames
// TODO have title not sticky
struct ReadRecipeView: View {
    @EnvironmentObject var collection: RecipeCollectionVM
    @EnvironmentObject var category: RecipeCategoryVM
    @Binding var isEditingRecipe: Bool
    @EnvironmentObject var recipe: RecipeVM
    
    @State private var actionSheetPresented = false
    @State private var categoriesPresented = false
    
//    @State private var directionIndicesCompleted = [Int]()
    @State private var inEditMode = false
    @State private var newAmount: String = ""
    @State private var newUnit: String = ""
    @State private var newName: String = ""
    @State private var newDirection: String = ""
    
    
    @State private var isCreatingRecipe = false
    
    @State private var confirmAddIngredient: Int?
    @State private var addedAllIngredients = false
    @State private var addedIngredients = [Int]()


    
    var body: some View {
        VStack {
            Form {
                HStack {
                    Text("\(recipe.name)")
                        .font(.system(size: 30, weight: .bold))
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                getImageView()
                
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
                                if addedIngredients.contains(ingredient.id) || self.addedAllIngredients {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(mainColor())
                                }
                                else {
                                    UIControls.AddButton(action: {
                                        withAnimation {
                                            confirmAddIngredient = ingredient.id
                                        }
                                    })
                                }
                                
                                IngredientText(ingredient)
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
                                .foregroundColor(mainColor())
                            }
                        }
                    }
                }
                
                Section(header: Text("Directions")) {
                    // TODO make list collapsable so after a step is done, it collapses
                    List {
                        ForEach(0..<recipe.directions.count, id: \.self) { index in
                            Direction(withIndex: index)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $categoriesPresented, content: {
            List{
                ForEach(collection.categories, id: \.self) { category in
                    Button(action: {
                        recipe.moveRecipe(toCategoryId: category.id)
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
            ActionSheet(title: Text("Move recipe"), message: nil, buttons:
                [
                    .default(Text("Move to category"), action: {
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
                                    
                    Button(action: {
                        withAnimation {
                            isEditingRecipe = true
                        }
                    })
                    {
                        Text("Edit")
                    }
                }
        )
    }
    
    // add all ingredients to shopping list is true, change + to checks
    func addAllIngredients() {
        self.addedAllIngredients = true
    }
    
    @ViewBuilder
    func getImageView() -> some View {
        if recipe.imageHandler.image != nil {
            Section(header: Text("Photos")) {
                ImagesView(isEditing: false)
            }
        }
    }
    
    @ViewBuilder
    func DirectionText(withIndex index: Int) -> some View {
        Group {
            Text("\(index + 1)")
                .frame(width: 20, height: 20, alignment: .center)

            TextField("\(recipe.directions[index].direction)", text: $newDirection)
        }
        .padding(.vertical)
    }
    
    @ViewBuilder func IngredientText(_ ingredient: Ingredient) -> some View {
        if inEditMode {
            HStack {
                TextField("\(ingredient.getAmountString()) ", text: $newAmount)
                
                TextField("\(ingredient.unitName.getName()) ", text: $newUnit)

                TextField("\(ingredient.name)", text: $newName)
            }
        }
        else {
            RecipeControls.ReadIngredientText(ingredient)
        }
    }
    
    @ViewBuilder func Direction(withIndex index: Int) -> some View {
        if inEditMode {
            HStack(alignment: .top, spacing: 20) {
                DirectionText(withIndex: index)
            }
            .foregroundColor(.black)
        }
        else {
            RecipeControls.ReadDirection(withIndex: index, recipe: recipe.recipe)
        }
    }
}

extension Array where Element: Equatable {
    mutating func toggleElement(_ element: Element) {
        let found = contains(element)
        guard let foundIndex = found else {
            append(element)
            return
        }
        remove(at: foundIndex)
    }
    
    func contains(_ element: Element) -> Int? {
        var found: Int?
        for index in 0..<self.count {
            if self[index] == element {
                found = index
            }
        }
        return found
    }
}

//struct ReadRecipeView_Previews: PreviewProvider {
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
