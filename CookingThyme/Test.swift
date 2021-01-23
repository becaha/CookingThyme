//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct Test: View {
    var confirmAddIngredient = false
    
    var body: some View {
        Form {
            HStack {
                Text("Recipe Name")
                    .font(.system(size: 30, weight: .bold))
                    .multilineTextAlignment(.center)
            }
            .padding()
            
            Text("Image")
            
            Section(header:
                HStack {
                    Text("Ingredients")
                    
                    Spacer()
                    
                    VStack {
                        // should be changing servings but not in db
//                        Picker(selection: $recipe.servings, label:
//                                HStack {
//                                    Text("Serving Size: \(recipe.servings)")
//
//                                    Image(systemName: "chevron.down")
//                                }
//                        )
//                        {
//                            ForEach(1..<101, id: \.self) { num in
//                                Text("\(num.toString())").tag(num.toString())
//                            }
//                        }
//                        .pickerStyle(MenuPickerStyle())
                        Text("Servings Picker")
                    }
                },
                    footer:
                        Button(action: {
                            
                        }) {
                            Text("Add Ingredients to Shopping List")
                        }

            ) {
                List {
                    ForEach(0..<3, id: \.self) { index in
                        HStack {
//                            if addedIngredients.contains(ingredient.id) || self.addedAllIngredients {
//                                Image(systemName: "checkmark")
//                                    .foregroundColor(mainColor())
//                            }
//                            else {
                                UIControls.AddButton(action: {
//                                    withAnimation {
//                                        confirmAddIngredient = ingredient.id
//                                    }
                                })
//                            }
                            
//                            IngredientText(ingredient)
                            Text("Ingredient \(index)")
                        }
                        if confirmAddIngredient {
                            HStack {
                                Image(systemName: "cart.fill")
                                
                                Button("Add to Shopping List", action: {
//                                    withAnimation {
//                                        collection.addToShoppingList(ingredient)
//                                        confirmAddIngredient = nil
//                                        addedIngredients.append(ingredient.id)
//                                    }
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
                    ForEach(0..<3, id: \.self) { index in
                        Text("\(index) Direction")
                    }
                }
            }
        }
        
        VStack {
            ForEach(0..<3, id: \.self) { index in
                Text("\(index) Direction")
                    .formItem()
            }
        }
        .formed()
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
