//
//  ShoppingListView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/7/20.
//

import SwiftUI

// TODO: cannot add ingredients twice
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
                                withAnimation {
                                    addItem()
                                }
                              })
                          
                    UIControls.AddButton(action: {
                        withAnimation {
                            addItem()
                        }
                    })
                    .foregroundColor(mainColor())
                }
            }
            
            Section(header: Text("")) {
                ForEach(collection.notCompletedItems) { item in
                    ItemView(item: item)
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        collection.removeTempShoppingItem(collection.notCompletedItems[index])
                    }
                }
            }

            
            Section(header:
                    HStack {
                        Text("Completed Items")
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                collection.removeCompletedShoppingItems()
                            }
                        }) {
                            Image(systemName: "trash")
                                .imageScale(.large)
                        }
                    }
            ) {
                ForEach(collection.completedItems) { item in
                    ItemView(item: item)
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        collection.removeTempShoppingItem(collection.completedItems[index])
                    }
                }
                
            }
            .opacity(collection.completedItems.count > 0 ? 1 : 0)
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Shopping List", displayMode: .inline)
    }
    
    @ViewBuilder
    func ItemView(item: ShoppingItem) -> some View {
        HStack {
            Button(action: {
                withAnimation {
                    collection.toggleCompleted(item)
                }
            }) {
                ZStack {
                    Circle()
                        .fill(mainColor())
                        .frame(width: 20, height: 20)
                        .opacity(item.completed ? 1: 0)
                    
                    Circle()
                        .stroke(mainColor(), lineWidth: 3)
                        .frame(width: 20, height: 20)
                }
            }
            
            Text("\(item.toString())")
        }
    }
    
    func addItem() {
        collection.addTempShoppingItem(name: newName)
        newName = ""
    }
}

//struct ShoppingListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ShoppingListView()
//        .environmentObject(RecipeCollectionVM(collection: RecipeCollection(id: 1, name: "Becca")))
//    }
//}

