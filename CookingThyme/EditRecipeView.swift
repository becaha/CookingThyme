//
//  EditRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/17/20.
//

import SwiftUI

// TODO: edit, each item in list must have his own binding to be edited, a dictionary of string by id?
// for directions: by index?
struct EditRecipeView: View {
    @ObservedObject var recipeVM: RecipeVM = RecipeVM()
    
    @State private var isEditingDirection = false
    @State private var isEditingIngredient = false
    
    @State private var ingredients = [Ingredient]()
    @State private var directions = [String]()

    @State private var name: String = ""
    @State private var servings: String = ""
    @State private var ingredientAmount: String = ""
    @State private var ingredientUnit: String = ""
    @State private var ingredientName: String = ""
    @State private var direction: String = ""
    
    var body: some View {
        VStack {
            ZStack {
                TextField("Recipe Name", text: $name)
                    .font(.title)
                
                HStack {
                    Spacer()
                    
                    Button(action: {
    //                        recipe.save()
                    })
                    {
                        Text("Save")
                    }
                }
            }
            .padding()
                
            Form {
                
                Section(header:
                    HStack {
                        Text("Ingredients")
                        
                        Spacer()
                        
                        // TODO make serving size look like you need to choose it
                        Picker(selection: $servings, label: Text("Serving Size: \(servings)")) {
                            ForEach(1..<101, id: \.self) { num in
                                    Text("\(num)").tag(num)
                                }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
//                        Image(systemName: "")
                    }
                ) {
                    List {
                        ForEach(ingredients) { ingredient in
                            Text("\(ingredient.getFractionAmount()) \(ingredient.unit.rawValue) \(ingredient.name)")
                        }
                        HStack {
                            TextField("Amount ", text: $ingredientAmount)
                            
                            TextField("Unit ", text: $ingredientUnit)

                            TextField("Name", text: $ingredientName)
                            
                            UIControls.AddButton(action: addIngredient)
                        }
                    }
                }
                
                Section(header: Text("Directions")) {
                    // TODO make list collapsable so after a step is done, it collapses
                    List {
                        ForEach(0..<directions.count, id: \.self) { index in
                            HStack(alignment: .top, spacing: 20) {
                                Text("\(index + 1)")
                                    .frame(width: 20, height: 20, alignment: .center)

                                Text("\(directions[index])")
                            }
                            .padding(.vertical)
                        }
                        Text("\(directions[directions.count - 1])")
                        HStack(alignment: .top, spacing: 20) {
                            Text("\(directions.count + 1)")
                                .frame(width: 20, height: 20, alignment: .center)

                            TextField("Direction", text: $direction, onEditingChanged: { (isEditing) in
                                self.isEditingDirection = isEditing
                            }, onCommit: {
                                addDirection()
                            })

                            UIControls.AddButton(action: addDirection)
                        }
                        .padding(.vertical)
                    }
                    .foregroundColor(.black)
                }
            }
        }
    }
    
    private func addDirection() -> Void {
        directions.append(direction)
        direction = ""
    }
    
    private func addIngredient() -> Void {
        let newIngredient = recipeVM.makeIngredient(name: ingredientName, amount: ingredientAmount, unit: ingredientUnit)
        ingredients.append(newIngredient)
        ingredientName = ""
        ingredientAmount = ""
        ingredientUnit = ""
    }
}

struct EditRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        EditRecipeView()
    }
}
