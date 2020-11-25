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
    
    @State private var editMode: EditMode = .inactive
    
    @State var newCategory: String = ""
    @State var isAddingCategory = false
    
    @State var updatedCategory: String = ""
    @State var isEditingCategory = false
    
    var body: some View {
        NavigationView {
            List {
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
                ForEach(recipeCollectionVM.categories, id: \.self) { category in
                    NavigationLink(
                        destination:
                            CategoryView()
                                .environmentObject(RecipeCategoryVM(category: category))
                    ) {
//                        Text("\(category.name)")
                        EditableText(category.name, isEditing: editMode.isEditing) { categoryName in
                            updateCategory(forCategoryId: category.id, toName: categoryName)
                        }
                    }
                }
                .onDelete { indexSet in
                    // todo
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Recipe Book", displayMode: .inline)
            .navigationBarItems(trailing: EditButton())
            .environment(\.editMode, $editMode)
        }
    }
    
    func updateCategory(forCategoryId categoryId: Int, toName name: String) {
        
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
