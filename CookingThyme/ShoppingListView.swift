//
//  ShoppingListView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/7/20.
//

import SwiftUI

// TODO: save when view changes from shopping list
struct ShoppingListView: View {
    @EnvironmentObject var collection: RecipeCollectionVM

    @State var newName = ""
    
    var body: some View {
        List {
            Section {
                HStack {
                    TextField("Add item", text: $newName,
                              onCommit: {
                                addItem()
                                saveItems()
                              })
                          
                    UIControls.AddButton(action: addItem)
                }
            }
            
            ForEach(collection.tempShoppingList) { item in
                HStack {
                    Button(action: {
                        collection.toggleCompleted(item)
                        saveItems()
                    }) {
                        ZStack {
                            Circle()
                                .fill(mainColor())
                                .frame(width: 30, height: 30)
                                .opacity(item.completed ? 1: 0)
                            
                            Circle()
                                .stroke(mainColor(), lineWidth: 3)
                                .frame(width: 30, height: 30)
                        }
                    }
                    
                    Text("\(item.toString())")
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    collection.removeTempShoppingItem(at: index)
                }
                saveItems()
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Shopping List", displayMode: .inline)
    }
    
    func addItem() {
        collection.addTempShoppingItem(name: newName)
        newName = ""
    }
    
    func saveItems() {
        collection.saveShoppingList()
    }
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView()
        .environmentObject(RecipeCollectionVM(collection: RecipeCollection(id: 1, name: "Becca")))
    }
}

