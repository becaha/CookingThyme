//
//  ShoppingListView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/7/20.
//

import SwiftUI
import Combine

struct ShoppingListView: View {
    @EnvironmentObject var collection: RecipeCollectionVM

    @State var completeAll = false
    @State var newName = ""
    
    @State var keyboardPresented = false

    
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
                    .onTapGesture(count: 1, perform: {})
                }
            }

            if collection.notCompletedItems.count > 0 {
                Section {
                    ForEach(collection.notCompletedItems) { item in
                        ItemView(item: item)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            collection.removeTempShoppingItem(collection.notCompletedItems[index])
                        }
                    }
                }
            }

            Section(header:
                    HStack {
                        Text("Completed Items")

                        Spacer()
                        
                        Button(action: {
                            collection.completeAllShoppingItems(false)
                        }) {
                            Text("Uncheck All")
                                .padding(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(Color(UIColor.tertiarySystemFill))
                                )
                        }

                        Button(action: {
                            withAnimation {
                                collection.removeShoppingItems(completed: true)
                            }
                        }) {
                            Image(systemName: "trash")
                                .padding(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(Color(UIColor.tertiarySystemFill))
                                )
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
        .onReceive(Publishers.keyboardHeight) { height in
            keyboardPresented = height == 0 ? false : true
        }
        .gesture(keyboardPresented ?
                    TapGesture(count: 1).onEnded {
            withAnimation {
                unfocusEditable()
            }
        } : nil)
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
        if newName != "" {
            collection.addTempShoppingItem(name: newName)
            newName = ""
        }
    }
}

//struct ShoppingListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ShoppingListView()
//        .environmentObject(RecipeCollectionVM(collection: RecipeCollection(id: 1, name: "Becca")))
//    }
//}

