//
//  RecipeCollectionView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import SwiftUI

// TODO: drag and drop recipes from one category to another
// TOOD: deletes
// TODO: edit category name
// TODO: click off of add new category to dismiss
// TODO: have images or icons for categories, imaage from recipe in category
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
    
    @State var addRecipeExpanded = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    ScrollView(.horizontal) {
                        HStack {
    //                        VStack {
    //                            ZStack {
    //                                Circle()
    //                                    .fill(Color.white)
    //
    //                                Image(systemName: "plus")
    //                                    .foregroundColor(.black)
    //
    //                                Circle()
    //                                    .stroke(Color.black, lineWidth: 1)
    //                                    .shadow(radius: 5)
    //                            }
    //                            .frame(width: 60, height: 60)
        //
        //                            Text("Add Category")
        //                                .font(.subheadline)
        //                                .foregroundColor(.black)
        //                        }
        //                        .padding()
                            
                            ForEach(collection.categories, id: \.self) { category in
                                Button(action: {
                                    currentCategory = RecipeCategoryVM(category: category, collection: collection)
                                }) {
                                    VStack {
                                        ZStack {
                                            CircleImage(width: 60, height: 60)
                                            
                                            Circle()
                                                .stroke(Color.white, lineWidth: 1)
                                                .shadow(radius: 5)
                                        }
                                        .frame(width: 60, height: 60)
                                        
                                        Text("\(category.name)")
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                            .fontWeight(category.id == currentCategory?.id ? .bold : .none)
                                    }
                                }
                                .padding()
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
                
//                Form {
//                Section(header:
//                    HStack(alignment: .center) {
//                        Spacer()
//
//                        if !addCategoryExpanded {
//                            Button(action: {
//                                addCategoryExpanded = true
//                            }) {
//                                ZStack {
//                                    Circle()
//                                        .frame(width: 40, height: 40)
//                                        .foregroundColor(.white)
//                                        .shadow(radius: 10)
//
//                                    Image(systemName: "plus")
//                                }
//                            }
//                        }
//                        else {
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(Color.white)
//                                    .shadow(radius: 10)
//
//                                HStack {
//                                    TextField("New Category", text: $newCategory, onCommit: {
//                                        addCategory()
//                                    })
//
//                                    Spacer()
//
//                                    UIControls.AddButton(action: addCategory, isPlain: false)
//                                }
//                                .padding()
//                            }
//                            .frame(width: 200, height: 60)
//                        }
//                    }
//                    .padding(.horizontal, 10)
//                    .padding(.bottom)
//                    .zIndex(1)
//                ) {
                    List {
                        ForEach(currentCategory?.recipes ?? []) { recipe in
                            NavigationLink("\(recipe.name)", destination:
                                        RecipeView(recipe: RecipeVM(recipe: recipe, category: currentCategory!))
                                            .environmentObject(currentCategory!)
                                            .environmentObject(collection)
                            )
                        }
                    }
                    .padding(.top, 0)
//                }
//                }
            }
//            List {
//                if isEditing {
//                    Section {
//                        HStack {
//                            TextField("Add New Category", text: $newCategory, onEditingChanged: { (isAddingCategory) in
//                                self.isAddingCategory = isAddingCategory
//                            }, onCommit: {
//                                addCategory()
//                            })
//
//                            Spacer()
//
//                            UIControls.AddButton(action: addCategory, isPlain: false)
//                        }
//                    }
//                }
//                ForEach(collection.categories, id: \.self) { category in
//                    if isEditing {
//                        Text("\(category.name)")
//                            .deletable(isDeleting: true, onDelete: {
//                                deleteCategoryId = category.id
//                                deleteCategoryAlert = true
//                            })
//                            .alert(isPresented: $deleteCategoryAlert) {
//                                Alert(title: Text("Delete Category"),
//                                      message: Text("Deleting this category will delete all of its recipes. Are you sure you want to delete it?"),
//                                      primaryButton: .default(Text("Ok")) {
//                                        if let deleteCategoryId = self.deleteCategoryId {
//                                            collection.deleteCategory(withId: deleteCategoryId)
//                                        }
//                                      },
//                                      secondaryButton: .cancel())
//                            }
//                    }
//                    else {
//                        NavigationLink(
//                            destination:
//                                CategoryView()
//                                    .environmentObject(RecipeCategoryVM(category: category, collection: collection))
//                                    .environmentObject(collection)
//                        ) {
//                            Text("\(category.name)")
//                        }
//                    }
//                }
//                .onDelete { indexSet in
//                    indexSet.map{ collection.categories[$0] }.forEach { category in
//                        collection.deleteCategory(withId: category.id)
//                    }
//                }
//            }
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
    
//    func ExpandableAddButton(expanded: Binding<Bool>, textString: String, textBinding: Binding<String>, addAction: @escaping () -> Void) -> some View {
//        var expanded = expanded
//
//        return HStack(alignment: .center) {
//            Spacer()
//
//            if !expanded {
//                Button(action: {
//                    expanded = true
//                }) {
//                    ZStack {
//                        Circle()
//                            .frame(width: 40, height: 40)
//                            .foregroundColor(.white)
//                            .shadow(radius: 10)
//
//                        Image(systemName: "plus")
//                    }
//                }
//            }
//            else {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 10)
//                        .fill(Color.white)
//                        .shadow(radius: 10)
//
//                    HStack {
//                        TextField(textString, text: textBinding, onCommit: {
//                            addAction()
//                        })
//
//                        Spacer()
//
//                        UIControls.AddButton(action: addAction, isPlain: false)
//                    }
//                    .padding()
//                }
//                .frame(width: 200, height: 60)
//            }
//        }
//        .padding(.horizontal, 10)
//        .padding(.bottom)
//        .zIndex(1)
//    }
    
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
