//
//  EditRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/17/20.
//

import SwiftUI

// TODO: edit, when ingredient item is clicked, all the ingredient bindings are pertaining to that item,
// off click, it saved to local recipe
struct EditRecipeView: View {
    @EnvironmentObject var category: RecipeCategoryVM
    @Binding var isPresented: Bool
    @ObservedObject var recipeVM: RecipeVM
    
    @State private var fieldMissing = false
    
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
                VStack(alignment: .leading) {
                    TextField("Recipe Name", text: $name)
                        .font(.title)
                    
                    if fieldMissing && name == "" {
                        ErrorMessage("Must have a name")
                            .padding(0)
                    }
                }
                
                HStack {
                    //TODO find a place to put cancel button
//                    Button(action: {
//                        isPresented = false
//                    })
//                    {
//                        Text("Cancel")
//                    }
                    
                    Spacer()
                    
                    Button(action: {
                        saveRecipe()
                    })
                    {
                        Text("Save")
                    }
                    
//                    EditButton()
                }
            }
            .padding()
                
            Form {
                
                Section(header:
                    HStack {
                        Text("Ingredients")
                        
                        Spacer()
                        
                        VStack {
                            // TODO make serving size look like you need to choose it
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
                        Group {
                            if fieldMissing && servings == "" {
                                ErrorMessage("Must have at least one ingredient and a serving size")
                            }
                        }
                        
                ) {
                    List {
                        ForEach(ingredients) { ingredient in
                            Text("\(ingredient.getFractionAmount()) \(ingredient.unitName.getName()) \(ingredient.name)")
//                            TextField("Amount ", text: $ingredientAmount)
//
//                            TextField("Unit ", text: $ingredientUnit)
//
//                            TextField("Name", text: $ingredientName)
                        }
                        .onDelete { indexSet in
                            indexSet.map{ $0 }.forEach { index in
                                ingredients.remove(at: index)
                            }
                        }
                        HStack {
                            TextField("Amount ", text: $ingredientAmount)
                            
                            TextField("Unit ", text: $ingredientUnit)

                            TextField("Name", text: $ingredientName)
                            
                            UIControls.AddButton(action: addIngredient)
                        }
                    }
                }
                
                Section(header: Text("Directions"),
                        footer:
                            Group {
                                if fieldMissing && directions.count == 0 {
                                    ErrorMessage("Must have at least one direction")
                                }
                            }
                ) {
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
                        .onDelete { indexSet in
                            indexSet.map{ $0 }.forEach { index in
                                directions.remove(at: index)
                            }
                        }
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
        .onAppear {
            setRecipe()
        }
    }
    
    private func setRecipe() {
        name = recipeVM.name
        servings = recipeVM.servings.toString()
        ingredients = recipeVM.ingredients
        for direction in recipeVM.directions {
            self.directions.append(direction.direction)
        }
    }
    
    @ViewBuilder
    private func ErrorMessage(_ message: String) -> some View {
        Text("\(message)")
            .foregroundColor(.red)
            .font(.footnote)
    }
    
    private func saveRecipe() {
        if name != "" && ingredients.count > 0 && directions.count > 0 && servings.toInt() > 0 {
            if recipeVM.isCreatingRecipe() {
                category.createRecipe(name: name, ingredients: ingredients, directionStrings: directions, servings: servings)
            }
            else {
                recipeVM.updateRecipe(withId: recipeVM.id, name: name, ingredients: ingredients, directionStrings: directions, servings: servings)
                category.popullateRecipes()
            }
            // have page shrink up into square and be brought to the recipe collection view showing the new recipe
            // flying into place
            isPresented = false
        }
        else {
            fieldMissing = true
        }
    }
    
    private func addDirection() {
        directions.append(direction)
        direction = ""
    }
    
    private func addIngredient() {
        let newIngredient = recipeVM.makeIngredient(name: ingredientName, amount: ingredientAmount, unit: ingredientUnit)
        ingredients.append(newIngredient)
        ingredientName = ""
        ingredientAmount = ""
        ingredientUnit = ""
    }
}

//struct EditRecipeView_Previews: PreviewProvider {
//    @State var isPresented = true
//    static var previews: some View {
//        EditRecipeView(isPresented: $isPresented)
//    }
//}
