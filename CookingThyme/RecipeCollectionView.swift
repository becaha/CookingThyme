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
    
    @State var newCategory: String = ""
    @State var isEditing = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        TextField("Add New Category", text: $newCategory, onEditingChanged: { (isEditing) in
                            self.isEditing = isEditing
                        }, onCommit: {
                            addCategory()
                        })

                        Spacer()

                        UIControls.AddButton(action: addCategory)
                    }
                }
                ForEach(recipeCollectionVM.categories, id: \.self) { category in
                    NavigationLink("\(category)", destination:
                        CategoryView(category: category, recipes: recipeCollectionVM.recipes(inCategory: category) ?? [])
                    )
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Recipe Book", displayMode: .inline)
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
