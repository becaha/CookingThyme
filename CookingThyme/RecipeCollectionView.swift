//
//  RecipeCollectionView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import SwiftUI

// TODO: measurement page to ask how many tbsp in an ounce

// TODO: drag and drop recipes from one category to another
// TODO: click off of add new category to dismiss
// TODO: have images or icons for categories, imaage from recipe in category

// TODO: cant add recipe to All category, can delete recipe from All category?
// TODO: all category only have a unique recipe
// TODO: cannot add same recipe twice to category
struct RecipeCollectionView: View {
    @EnvironmentObject var collection: RecipeCollectionVM
    
    @State private var isEditing = false
    
    @State var newCategoryMissingField: Bool = false
    
    @State var newCategory: String = ""
    
    @State var updatedCategory: String = ""
    @State var isEditingCategory = false
    
    @State var deleteCategoryAlert = false
    @State var deleteCategoryId: Int?
    
    @State var addCategoryExpanded = false
    @State var currentCategory: RecipeCategoryVM?
    
    @State private var isCreatingRecipe = false

    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(collection.categories, id: \.self) { category in
                                VStack {
                                    ZStack {
                                        Button(action: {
                                            currentCategory = RecipeCategoryVM(category: category, collection: collection)
                                        }) {
                                            ZStack {
                                                CircleImage(isSelected: currentCategory?.id == category.id, width: 60, height: 60)
                                                
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 1)
                                                    .shadow(radius: 5)
                                            }
                                            .frame(width: 60, height: 60)
                                        }
                                        .disabled(isEditing ? true : false)
                                        
                                        if isEditing && category.name != "All" {
                                            Button(action: {
                                                deleteCategoryId = category.id
                                                deleteCategoryAlert = true
                                            }) {
                                                ZStack {
                                                    Image(systemName: "trash")
                                                        .foregroundColor(.black)
                                                }
                                            }
                                        }
                                    }
                                    EditableText("\(category.name)", isEditing: isEditing, isSelected: category.id == currentCategory?.id ? true : false, onChanged: { name in
                                        collection.updateCategory(forCategoryId: category.id, toName: name)
                                    })
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                }
                                .padding()
                                .alert(isPresented: $deleteCategoryAlert) {
                                    Alert(title: Text("Delete Category"),
                                          message: Text("Deleting this category will delete all of its recipes. Are you sure you want to delete it?"),
                                          primaryButton: .default(Text("Ok")) {
                                            if let deleteCategoryId = self.deleteCategoryId {
                                                collection.deleteCategory(withId: deleteCategoryId)
                                            }
                                          },
                                          secondaryButton: .cancel())
                                }
                            }
                        }
                    }
                    .padding(.trailing, 60)
                    
                    HStack(alignment: .center) {
                        Spacer()
                        
                        if !addCategoryExpanded {
                            Button(action: {
                                addCategoryExpanded = true
                            }) {
                                ZStack {
                                    Circle()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.white)
                                        .shadow(radius: 10)

                                    Image(systemName: "plus")
                                }
                            }
                        }
                        else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .shadow(radius: 10)

                                HStack {
                                    TextField("New Category", text: $newCategory, onCommit: {
                                        addCategory()
                                    })

                                    Spacer()

                                    UIControls.AddButton(action: addCategory, isPlain: false)
                                }
                                .padding()
                            }
                            .frame(width: 200, height: 60)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom)
                    .zIndex(1)
                }
                .background(formBackgroundColor())
                .border(Color.white, width: 2)
                
                RecipesList()
                
                HStack(alignment: .center) {
                    Spacer()

                    Button(action: {
                        createRecipe()
                    }) {
                        ZStack {
                            Circle()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                                .shadow(radius: 10)

                            Image(systemName: "plus")
                        }
                    }
                    .sheet(isPresented: $isCreatingRecipe) {
                        CreateRecipeView(isCreatingRecipe: self.$isCreatingRecipe)
                            .environmentObject(RecipeVM(category: currentCategory!))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom)
                .background(formBackgroundColor())
                .zIndex(1)
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
        .onAppear {
            currentCategory = RecipeCategoryVM(category: collection.allCategory, collection: collection)
        }
    }
    
    private func RecipesList() -> some View {
        List {
            ForEach(currentCategory?.recipes ?? []) { recipe in
                NavigationLink("\(recipe.name)", destination:
                            RecipeView(recipe: RecipeVM(recipe: recipe, category: currentCategory!))
                                .environmentObject(currentCategory!)
                                .environmentObject(collection)
                )
                .deletable(isDeleting: isEditing, onDelete: {
                    withAnimation {
                        collection.deleteRecipe(withId: recipe.id)
                        currentCategory = RecipeCategoryVM(category: currentCategory!.category, collection: collection)
                    }
                })
            }
            .onDelete { indexSet in
                indexSet.map{ currentCategory!.recipes[$0] }.forEach { recipe in
                    collection.deleteRecipe(withId: recipe.id)
                    currentCategory = RecipeCategoryVM(category: currentCategory!.category, collection: collection)
                }
            }
        }
        .padding(.top, 0)
    }
    
    private func createRecipe() {
        isCreatingRecipe = true
    }
    
    // adds new category
    func addCategory() {
        withAnimation {
            if newCategory != "" {
                newCategoryMissingField = false
                collection.addCategory(newCategory)
                newCategory = ""
            }
            else {
                newCategoryMissingField = true
            }
        }
        dismissAddCategory()
    }
    
    func dismissAddCategory() {
        withAnimation {
            addCategoryExpanded = false
        }
    }
}

struct RecipeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeCollectionView()
            .environmentObject(RecipeCollectionVM(collection: RecipeCollection(id: 0, name: "Becca")))
    }
}
