//
//  DirectionTest.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/21/21.
//

import SwiftUI

struct DirectionTest: View {
    @State var isPresented = true
    @State var newDirection: String = "this is a verrrrrrrrrry long sentenece for sure double lines"
    
    var directions = ["mix", "drink"]
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Title")
                    .padding()
            
                List {
                    Section {
                        ForEach((1...20).reversed(), id: \.self) { num in
                            Text("\(num)")
                            
                            HStack {
                                Image(systemName: "cart.fill")
                                
                                Button("Add to Shopping List", action: {
                                    withAnimation {
        //                                confirmAddIngredient = nil
        //                                addedIngredients.append(ingredient.id)
        //                                addToShoppingList(ingredient)
                                    }
                                })
                            }
                            .foregroundColor(mainColor())
                        }
                    }
                    
                }
                .moveDisabled(true)
            }
            .navigationBarTitle("Recipes", displayMode: .inline)
        }
    }
}

struct DirectionTest_Previews: PreviewProvider {
    static var previews: some View {
        DirectionTest()
    }
}
