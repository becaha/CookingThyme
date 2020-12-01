//
//  EditRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/17/20.
//

import SwiftUI

// TODO: have cursor go to next item in list after one is entered
// TODO: editing ingredient name and then clicking done will not save name, only an enter or click off in page will
struct EditRecipeView: View {
    @EnvironmentObject var category: RecipeCategoryVM
    @Binding var isPresented: Bool
    @ObservedObject var recipeVM: RecipeVM
    
//    @State private var editMode: EditMode = .active
    @State private var isEditing = true
        
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
                        Text("Done")
                    }
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
                        VStack {
//                            UIControls.AddButton(action: addIngredient)
                            
                            Group {
                                if fieldMissing && servings == "" && ingredients.count == 0 {
                                    ErrorMessage("Must have at least one ingredient and a serving size")
                                }
                            }
                        }
                        
                ) {
                    List {
                        ForEach(0..<recipeVM.tempIngredients.count, id: \.self) { index in
                            HStack {
                                EditableIngredient(index: index)
                                    .environmentObject(recipeVM)
                            }
                            .deletable(isDeleting: true, onDelete: {
                                recipeVM.removeTempIngredient(at: index)
                            })
                        }
                        .onDelete { indexSet in
                            indexSet.map{ $0 }.forEach { index in
                                recipeVM.removeTempIngredient(at: index)
                            }
                        }
                        HStack {
                            TextField("Amount ", text: $ingredientAmount)
                            
                            TextField("Unit ", text: $ingredientUnit)
                                .autocapitalization(.none)


                            TextField("Name", text: $ingredientName,
                                onEditingChanged: { (isEditing) in
                                    self.isEditingIngredient = isEditing
                                },
                                onCommit: {
                                    addIngredient()
                                })
                                .autocapitalization(.none)
                            
                            UIControls.AddButton(action: addIngredient)

                        }
                    }
                }
                
                Section(header: Text("Directions"),
                        footer:
                            VStack {
//                                UIControls.AddButton(action: addDirection)
                                
                                Group {
                                    if fieldMissing && directions.count == 0 {
                                        ErrorMessage("Must have at least one direction")
                                    }
                                }
                            }
                ) {
                    // TODO make list collapsable so after a step is done, it collapses
                    List {
                        ForEach(0..<recipeVM.tempDirections.count, id: \.self) { index in
                            HStack(alignment: .top, spacing: 20) {
                                Text("\(index + 1)")
                                    .frame(width: 20, height: 20, alignment: .center)
                                
                                EditableDirection(index: index)
                                    .environmentObject(recipeVM)
                            }
                            .deletable(isDeleting: true, onDelete: {                                                   recipeVM.removeTempDirection(at: index)
                            })
                            .padding(.vertical)
                        }
                        .onDelete { indexSet in
                            indexSet.map{ $0 }.forEach { index in
                                recipeVM.removeTempDirection(at: index)
                            }
                        }
                        HStack(alignment: .top, spacing: 20) {
                            Text("\(recipeVM.tempDirections.count + 1)")
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
                recipeVM.updateRecipe(withId: recipeVM.id, name: name, tempIngredients: recipeVM.tempIngredients, directions: recipeVM.tempDirections, servings: servings)
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
        recipeVM.addTempDirection(direction)
        direction = ""
    }
    
    private func addIngredient() {
        recipeVM.addTempIngredient(name: ingredientName, amount: ingredientAmount, unit: ingredientUnit)
        ingredientName = ""
        ingredientAmount = ""
        ingredientUnit = ""
    }
}

extension Array where Element: Identifiable {
    func indexOf(element: Element) -> Int? {
        for index in 0..<self.count {
            if self[index].id == element.id {
                return index
            }
        }
        return nil
    }
    
    mutating func remove(element: Element) {
        if let index = indexOf(element: element) {
            self.remove(at: index)
        }
    }
}

//struct EditRecipeView_Previews: PreviewProvider {
//    @State var isPresented = true
//    static var previews: some View {
//        EditRecipeView(isPresented: $isPresented)
//    }
//}
