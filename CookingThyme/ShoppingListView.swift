//
//  ShoppingListView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/7/20.
//

import SwiftUI

struct ShoppingListView: View {
    @State var shoppingList: [Ingredient]
    
    var body: some View {
        List {
            ForEach(shoppingList) { item in
                HStack {
                    Button(action: {
                        
                    }) {
                        Circle()
                            .frame(width: 40, height: 40)
                    }
                    
                    Text("\(item.getFractionAmount()) \(item.unitName.getName()) \(item.name)")
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView(shoppingList: [
                      Ingredient(name: "water", amount: 1.05, unitName: UnitOfMeasurement.cup),
                      Ingredient(name: "water", amount: 2.1, unitName: UnitOfMeasurement.cup),
                      Ingredient(name: "water", amount: 1.3, unitName: UnitOfMeasurement.cup),
                      Ingredient(name: "water", amount: 1.8, unitName: UnitOfMeasurement.cup),
                      Ingredient(name: "water", amount: 1.95, unitName: UnitOfMeasurement.cup)
                  ])
    }
}
