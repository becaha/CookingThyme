//
//  RecipeCollectionView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import SwiftUI

// TODO: drag and drop recipes from one category to another

struct RecipeCollectionView: View {
    @ObservedObject var collection: RecipeCollectionVM
    
    @State private var isEditing = false
    
    @State var newCategoryMissingField: Bool = false
    
    @State var newCategory: String = ""
    @State var isAddingCategory = false
    
    @State var updatedCategory: String = ""
    @State var isEditingCategory = false
    
    var body: some View {
        NavigationView {
            List {
                if isEditing {
                    Section {
                        HStack {
                            TextField("Add New Category", text: $newCategory, onEditingChanged: { (isAddingCategory) in
                                self.isAddingCategory = isAddingCategory
                            }, onCommit: {
                                addCategory()
                            })

                            Spacer()

                            UIControls.AddButton(action: addCategory, isPlain: false)
                        }
                    }
                }
                ForEach(collection.categories, id: \.self) { category in
                    if isEditing {
//                        EditableText(category.name, isEditing: isEditing,
//                             onChanged: { categoryName in
//                                 recipeCollectionVM.updateCategory(forCategoryId: category.id, toName: categoryName)
//                             },
//                            onDelete: {
//                                recipeCollectionVM.deleteCategory(withId: category.id)
//                            }
//                        )
                        Text("\(category.name)")
                            .deletable(isDeleting: true, onDelete: {
                                collection.deleteCategory(withId: category.id)
                            })
                    }
                    else {
                        NavigationLink(
                            destination:
                                CategoryView()
                                    .environmentObject(RecipeCategoryVM(category: category, collection: collection))
                                    .environmentObject(collection)
                        ) {
                            Text("\(category.name)")
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.map{ collection.categories[$0] }.forEach { category in
                        collection.deleteCategory(withId: category.id)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("\(collection.name)", displayMode: .inline)
            .navigationBarItems(trailing:
                UIControls.EditButton(
                    action: {
                        isEditing.toggle()
                    },
                    isEditing: isEditing)
            )
        }
    }
    
    func addCategory() {
        if newCategory != "" {
            newCategoryMissingField = false
            collection.addCategory(newCategory)
            newCategory = ""
        }
        else {
            newCategoryMissingField = true
        }
    }
}

struct RecipeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeCollectionView(collection: RecipeCollectionVM(collection: RecipeCollection(id: 0, name: "Becca")))
    }
}
