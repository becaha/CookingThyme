//
//  ReadRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/24/20.
//

import SwiftUI

struct ReadRecipeView: View {
    @EnvironmentObject var collection: RecipeCollectionVM
    @EnvironmentObject var category: RecipeCategoryVM
    @Binding var isEditingRecipe: Bool
    @EnvironmentObject var recipe: RecipeVM
    
    @State private var actionSheetPresented = false
    @State private var categoriesPresented = false
    
    @State private var directionIndicesCompleted = [Int]()
    @State private var inEditMode = false
    @State private var newAmount: String = ""
    @State private var newUnit: String = ""
    @State private var newName: String = ""
    @State private var newDirection: String = ""
    
    @State private var isCreatingRecipe = false
    
    @State private var confirmAddIngredient: Int?
    
    var body: some View {
        VStack {
            HStack {
                Text("\(recipe.name)")
                    .font(.system(size: 30, weight: .bold))
                    .multilineTextAlignment(.center)
            }
            .padding()
            
            Form {
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
                            AddIngredientsButton()
                ) {
                    List {
                        ForEach(recipe.ingredients) { ingredient in
                            HStack {
                                UIControls.AddButton(action: {
                                    confirmAddIngredient = ingredient.id
                                })
                                
                                IngredientText(ingredient)
                            }
                            if confirmAddIngredient == ingredient.id {
                                HStack {
                                    Image(systemName: "cart.fill")
                                    
                                    Button("Add to Shopping List", action: {
                                            collection.addToShoppingList(ingredient)
                                            confirmAddIngredient = nil
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
                        ForEach(0..<recipe.directions.count) { index in
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
                                    
                    Button(action: {
                        isEditingRecipe = true
                    })
                    {
                        Text("Edit")
                    }
                }
        )
    }
    
    @ViewBuilder
    func AddIngredientsButton() -> some View {
        VStack(alignment: .center) {
            Button(action: {
                collection.addToShoppingList(fromRecipe: recipe.recipe)
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
        }
    }
    
    @ViewBuilder func getImageView() -> some View {
        if recipe.imageHandler.image != nil {
            Section(header: Text("Photos")) {
                ImagesView(isEditing: false)
            }
        }
    }
    
    @ViewBuilder func DirectionText(withIndex index: Int) -> some View {
        if inEditMode {
            Group {
                Text("\(index + 1)")
                    .frame(width: 20, height: 20, alignment: .center)

                TextField("\(recipe.directions[index].direction)", text: $newDirection)
            }
            .padding(.vertical)
        }
        else {
            if directionIndicesCompleted.contains(index) {
                HStack(alignment: .center) {
                    Text("\(index + 1)")

                    Spacer()

                    Image(systemName: "plus").imageScale(.medium)
                }
            }
            else {
                Group {
                    Text("\(index + 1)")
                        .frame(width: 20, height: 20, alignment: .center)

                    Text("\(recipe.directions[index].direction)")
                }
                .padding(.vertical)
            }
        }
    }
    
    // on click to edit an ingredient, this will be added to that ingredient, off click will save that to
    // temporary changed ingredients
    @ViewBuilder func IngredientText(_ ingredient: Ingredient) -> some View {
        if inEditMode {
            HStack {
                TextField("\(ingredient.getAmountString()) ", text: $newAmount)
                
                TextField("\(ingredient.unitName.getName()) ", text: $newUnit)

                TextField("\(ingredient.name)", text: $newName)
            }
        }
        else {
            Text("\(ingredient.getAmountString()) \(ingredient.unitName.getName()) \(ingredient.name)")
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
            Button(action: {
                withAnimation {
                    directionIndicesCompleted.toggleElement(index)
                }
            }) {
                HStack(alignment: .top, spacing: 20) {
                    DirectionText(withIndex: index)
                }
                .foregroundColor(.black)
            }
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
