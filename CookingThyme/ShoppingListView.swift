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

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                HStack {
                    TextField("Add item", text: $newName,
                              onCommit: {
                                withAnimation {
                                    addItem()
                                }
                              })
                        .customFont(style: .subheadline)

                    UIControls.AddButton(action: {
                        withAnimation {
                            addItem()
                        }
                    })
                    .foregroundColor(mainColor())
                }
                .formItem(isSearchBar: true)
                .padding(.bottom)

                if collection.notCompletedItems.count > 0 {
                    VStack(spacing: 0) {
                        ForEach(collection.notCompletedItems) { item in
                            ItemView(item: item)
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                collection.removeTempShoppingItem(collection.notCompletedItems[index])
                            }
                        }
                    }
                    .formSection()
                }
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Completed Items")
                            .textCase(.uppercase)
                            .customFont(style: .subheadline)

                        Spacer()
                        
                        Button(action: {
                            collection.completeAllShoppingItems(false)
                        }) {
                            Text("Uncheck All")
                                .textCase(.uppercase)
                                .customFont(style: .caption1)
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
                                .padding(.vertical, 2)
                                .padding(.horizontal, 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(Color(UIColor.tertiarySystemFill))
                                )
                        }
                    }
                    .formHeader()
                    
                    VStack(spacing: 0) {
                        ForEach(collection.completedItems) { item in
                            ItemView(item: item)
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                collection.removeTempShoppingItem(collection.completedItems[index])
                            }
                        }
                    }
                    .formSection()

                }
                .opacity(collection.completedItems.count > 0 ? 1 : 0)
            }
            .formed()
        }
        .background(formBackgroundColor())
    }
    
    @ViewBuilder
    func ItemView(item: ShoppingItem) -> some View {
        Button(action: {
            withAnimation {
                collection.toggleCompleted(item)
            }
        }) {
            HStack {
                ZStack {
                    Circle()
                        .fill(mainColor())
                        .frame(width: 20, height: 20)
                        .opacity(item.completed ? 1: 0)

                    Circle()
                        .stroke(mainColor(), lineWidth: 3)
                        .frame(width: 20, height: 20)
                }

                Text("\(item.toString())")
                    .customFont(style: .subheadline)
                    .foregroundColor(formItemFont())
            }
            .formSectionItem()
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

