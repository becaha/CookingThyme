//
//  RecipeCollectionView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import SwiftUI

// TODO: drag and drop recipes from one category to another

struct RecipeCollectionView: View {
    @ObservedObject var recipeCollectionVM: RecipeCollectionVM
    
//    @State private var editMode: EditMode = .inactive
    @State private var isEditing = false
    
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

                            UIControls.AddButton(action: addCategory)
                        }
                    }
                }
                ForEach(recipeCollectionVM.categories, id: \.self) { category in
                    if isEditing {
                        EditableText(category.name, isEditing: isEditing,
                             onChanged: { categoryName in
                                 recipeCollectionVM.updateCategory(forCategoryId: category.id, toName: categoryName)
                             },
                            onDelete: {
                                recipeCollectionVM.deleteCategory(withId: category.id)
                            }
                        )
                    }
                    else {
                        NavigationLink(
                            destination:
                                CategoryView()
                                    .environmentObject(RecipeCategoryVM(category: category))
                        ) {
                            Text("\(category.name)")
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.map{ recipeCollectionVM.categories[$0] }.forEach { category in
                        recipeCollectionVM.deleteCategory(withId: category.id)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Recipe Book", displayMode: .inline)
            .navigationBarItems(trailing:
                UIControls.EditButton(
                    action: {
                        isEditing.toggle()
                    },
                    isEditing: isEditing)
            )
//            .environment(\.editMode, $editMode)
        }
    }
    
    func addCategory() {
        recipeCollectionVM.addCategory(newCategory)
        newCategory = ""
    }
}

struct RecipeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeCollectionView(recipeCollectionVM: RecipeCollectionVM(recipeCollectionId: 1))
    }
}
