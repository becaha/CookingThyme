//
//  EditRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/17/20.
//

import SwiftUI

// TODO: have cursor go to next item in list after one is entered
struct EditRecipeView: View {
    @EnvironmentObject var category: RecipeCategoryVM
    @Binding var isEditingRecipe: Bool
    @EnvironmentObject var recipe: RecipeVM
    var isCreatingRecipe: Bool = false
            
    private var fieldMissing: Bool {
        return nameFieldMissing || newIngredientFieldMissing || newDirectionFieldMissing || ingredientsFieldMissing || directionsFieldMissing || servingsFieldMissing
    }
    @State private var nameFieldMissing = false
    @State private var newIngredientFieldMissing = false
    @State private var newDirectionFieldMissing = false
    @State private var ingredientsFieldMissing = false
    @State private var directionsFieldMissing = false
    @State private var servingsFieldMissing = false
        
    @State private var isEditingDirection = false
    @State private var isEditingIngredient = false
    
    @State private var name: String = ""
    @State private var servings: String = ""
    @State private var ingredientAmount: String = ""
    @State private var ingredientUnit: String = ""
    @State private var ingredientName: String = ""
    @State private var direction: String = ""
    
    var body: some View {
        VStack {
            if isCreatingRecipe {
                HStack {
                    Button(action: {
                        withAnimation {
                            isEditingRecipe = false
                        }
                    }) {
                        Text("Cancel")
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        saveRecipe()
                    }) {
                        Text("Done")
                    }
                }
                .padding([.top, .leading, .trailing])
            }
            
            HStack {
                VStack(alignment: .leading) {
                    TextField("Recipe Name", text: $name, onEditingChanged: { isEditing in
                        if name != "" {
                            withAnimation {
                                nameFieldMissing = false
                            }
                        }
                    })
                    .multilineTextAlignment(.center)
                    .font(.system(size: 30, weight: .bold))
                    
                    ErrorMessage("Must have a name", isError: $nameFieldMissing)
                        .padding(0)
                }
                .padding(.bottom, 0)
            }
            .padding()
                            
            Form {
                Section(header: Text("Photos")) {
                    ImagesView()
                        .frame(minHeight: 200)
                }
                
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
                        VStack(alignment: .leading) {                            
                            ErrorMessage("Must have at least one ingredient", isError: $ingredientsFieldMissing)
                            
                            ErrorMessage("Must have a serving size", isError: $servingsFieldMissing)
                        }
                        
                ) {
                    List {
                        ForEach(0..<recipe.tempIngredients.count, id: \.self) { index in
                            HStack {
                                EditableIngredient(index: index)
                                    .environmentObject(recipe)
                            }
                            .deletable(isDeleting: true, onDelete: {
                                withAnimation {
                                    recipe.removeTempIngredient(at: index)
                                }
                            })
                        }
                        .onDelete { indexSet in
                            indexSet.map{ $0 }.forEach { index in
                                recipe.removeTempIngredient(at: index)
                            }
                        }
                        VStack(alignment: .leading) {
                            HStack {
                                TextField("Amount ", text: $ingredientAmount)
                                    .keyboardType(.numbersAndPunctuation)
                                    
                                TextField("Unit ", text: $ingredientUnit)
                                    .autocapitalization(.none)


                                TextField("Name", text: $ingredientName,
                                    onEditingChanged: { (isEditing) in
                                        self.isEditingIngredient = isEditing
                                    },
                                    onCommit: {
                                        withAnimation {
                                            addIngredient()
                                        }
                                    })
                                    .autocapitalization(.none)
                                
                                UIControls.AddButton(action: {
                                    withAnimation {
                                        addIngredient()
                                    }
                                })
                            }
                            
                            ErrorMessage("Must fill in an ingredient slot", isError: $newIngredientFieldMissing)
                        }
                    }
                }
                
                Section(header: Text("Directions"),
                        footer:
                            VStack {
                                Group {
                                    ErrorMessage("Must have at least one direction", isError: $directionsFieldMissing)
                                }
                            }
                ) {
                    // TODO make list collapsable so after a step is done, it collapses
                    List {
                        ForEach(0..<recipe.tempDirections.count, id: \.self) { index in
                            HStack(alignment: .top, spacing: 20) {
                                Text("\(index + 1)")
                                    .frame(width: 20, height: 20, alignment: .center)
                                
                                EditableDirection(index: index)
                                    .environmentObject(recipe)
                            }
                            .deletable(isDeleting: true, onDelete: {
                                withAnimation {
                                    recipe.removeTempDirection(at: index)
                                }
                            })
                            .padding(.vertical)
                        }
                        .onDelete { indexSet in
                            indexSet.map{ $0 }.forEach { index in
                                recipe.removeTempDirection(at: index)
                            }
                        }
                        VStack(alignment: .leading) {
                            HStack(alignment: .top, spacing: 20) {
                                Text("\(recipe.tempDirections.count + 1)")
                                    .frame(width: 20, height: 20, alignment: .center)

                                TextField("Direction", text: $direction, onEditingChanged: { (isEditing) in
                                    self.isEditingDirection = isEditing
                                }, onCommit: {
                                    withAnimation {
                                        addDirection()
                                    }
                                })
                                
                                UIControls.AddButton(action: {
                                    withAnimation {
                                        addDirection()
                                    }
                                })
                            }
                            
                            ErrorMessage("Must fill in a direction", isError: $newDirectionFieldMissing)
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
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading:
                Button(action: {
                    withAnimation {
                        isEditingRecipe = false
                    }
                }) {
                    Text("Cancel")
                }
                .padding(.leading, 0)
            ,
            trailing:
                Button(action: {
                    saveRecipe()
                })
                {
                    Text("Done")
                }
        )
    }
    
    private func setRecipe() {
        name = recipe.name
        servings = recipe.servings.toString()
    }
    
    private func saveRecipe() {
        if name == "" {
            nameFieldMissing = true
        }
        if recipe.tempIngredients.count == 0 {
            ingredientsFieldMissing = true
        }
        if recipe.tempDirections.count == 0 {
            directionsFieldMissing = true
        }
        if servings.toInt() < 1 {
            servingsFieldMissing = true
        }
        if !fieldMissing {
            if recipe.isCreatingRecipe() {
                let createdRecipe = category.createRecipe(name: name, tempIngredients: recipe.tempIngredients, directions: recipe.tempDirections, images: recipe.tempImages, servings: servings)
                if createdRecipe == nil {
                    print("error")
                }
            }
            else {
                recipe.updateRecipe(withId: recipe.id, name: name, tempIngredients: recipe.tempIngredients, directions: recipe.tempDirections, images: recipe.tempImages, servings: servings)
            }
            // have page shrink up into square and be brought to the recipe collection view showing the new recipe
            // flying into place
            withAnimation {
                isEditingRecipe = false
            }
        }
    }
    
    private func addDirection() {
        if direction != "" {
            newDirectionFieldMissing = false
            recipe.addTempDirection(direction)
            direction = ""
        }
        else {
            newDirectionFieldMissing = true
        }
        if recipe.tempDirections.count > 0 {
            directionsFieldMissing = false
        }
    }
    
    private func addIngredient() {
        if ingredientName != "" || ingredientAmount != "" || ingredientUnit != "" {
            newIngredientFieldMissing = false
            recipe.addTempIngredient(name: ingredientName, amount: ingredientAmount, unit: ingredientUnit)
            ingredientName = ""
            ingredientAmount = ""
            ingredientUnit = ""
        }
        else {
            newIngredientFieldMissing = true
        }
        if recipe.tempIngredients.count > 0 {
            ingredientsFieldMissing = false
        }
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
//    @State var num = 0
//    static var previews: some View {
//        HStack {
//            Text("hi")
//            
//            Spacer()
//            
//            UIControls.AddButton(action: {
//                print("was called")
//            })
//                .padding(0)
//        }
//    }
//}
