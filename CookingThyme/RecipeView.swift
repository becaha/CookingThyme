//
//  RecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import SwiftUI

// TODO: edit, each item in list must have his own binding to be edited, a dictionary of string by id?
// for directions: by index?
struct RecipeView: View {
    @ObservedObject var recipeVM: RecipeVM
    
    @State private var directionIndicesCompleted = [Int]()
    @State private var inEditMode = false
    @State private var newAmount: String = ""
    @State private var newUnit: String = ""
    @State private var newName: String = ""
    @State private var newDirection: String = ""
    
    var body: some View {
        VStack {
            ZStack {
                Text("\(recipeVM.recipe.name)")
                    .font(.title)
                
                HStack {
                    inEditMode ? Button(action: {
                        inEditMode = false
//                        recipe.revert()
                    })
                    {
                        Text("Cancel")
                    } : nil
                    
                    Spacer()
                    
                    Button(action: {
                        inEditMode.toggle()
                        if !inEditMode {
//                            recipe.save()
                        }
                    })
                    {
                        Text(inEditMode ? "Save" : "Edit")
                    }
                }
                .padding()
            }
                
            Form {
                
                Section(header:
                    HStack {
                        Text("Ingredients")
                        
                        Spacer()
                        
                        Picker(selection: $recipeVM.recipe.servings, label: Text("Serving Size: \(recipeVM.recipe.servings)")) {
                            ForEach(1..<101, id: \.self) { num in
                                    Text("\(num)").tag(num)
                                }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
//                        Image(systemName: "")
                    }
                ) {
                    List {
                        ForEach(recipeVM.recipe.ingredients) { ingredient in
                            IngredientText(ingredient)
                        }
                    }
                }
                
                Section(header: Text("Directions")) {
                    // TODO make list collapsable so after a step is done, it collapses
                    List {
                        ForEach(0..<recipeVM.recipe.directions.count) { index in
                            Direction(withIndex: index)
                        }
                    }
                }
            }
        }
    }
    
//    @ViewBuilder func direction(withIndex index: Int) -> some View {
//        Group {
//            ZStack(alignment: .top) {
//                Circle()
//                    .stroke(lineWidth: 5)
//                Circle()
//                    .foregroundColor(directionIndicesCompleted.contains(index) ? .green : .white)
//                Text("\(index + 1)")
//                    .frame(width: 30, height: 30, alignment: .center)
//            }
//            .frame(width: 30, height: 30, alignment: .top)
//            .padding(.top, 5)
//            .padding(.leading, 5)
//
//            Text("\(recipeVM.recipe.directions[index])")
//        }
//        .foregroundColor(.black)
//        .padding(.vertical)
//    }
    
    @ViewBuilder func DirectionText(withIndex index: Int) -> some View {
        if inEditMode {
            Group {
                Text("\(index + 1)")
                    .frame(width: 20, height: 20, alignment: .center)

                TextField("\(recipeVM.recipe.directions[index])", text: $newDirection)
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

                    Text("\(recipeVM.recipe.directions[index])")
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
                TextField("\(ingredient.getFractionAmount()) ", text: $newAmount)
                
                TextField("\(ingredient.unit.rawValue) ", text: $newUnit)

                TextField("\(ingredient.name)", text: $newName)
            }
        }
        else {
            Text("\(ingredient.getFractionAmount()) \(ingredient.unit.rawValue) \(ingredient.name)")
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

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView(
            recipeVM: RecipeVM(recipe: Recipe(
                name: "Water",
                ingredients: [
                    Ingredient(name: "water", amount: 1.05, unit: UnitOfMeasurement.Cup),
                    Ingredient(name: "water", amount: 2.1, unit: UnitOfMeasurement.Cup),
                    Ingredient(name: "water", amount: 1.3, unit: UnitOfMeasurement.Cup),
                    Ingredient(name: "water", amount: 1.8, unit: UnitOfMeasurement.Cup),
                    Ingredient(name: "water", amount: 1.95, unit: UnitOfMeasurement.Cup)
                ],
                directions: ["Fetch a pail of water from the wishing well in the land of the good queen Casandra", "Bring back the pail of water making sure as to not spill a single drop of it", "Boil the water thoroughly for an hour over medium-high heat", "Let the water cool until it is not steaming", "Put the water in the fridge to cool for 30 minutes", "Pour yourself a glass of nice cold water"],
                servings: 1)
        ))
    }
}
