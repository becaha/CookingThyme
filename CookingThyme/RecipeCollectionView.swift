//
//  RecipeCollectionView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import SwiftUI

// TODO: measurement page to ask how many tbsp in an ounce

// TODO: drag and drop recipes from one category to another
// TODO: have images or icons for categories, imaage from recipe in category

// TODO: edit all photo or not have a photo for all
// TODO: all category when click on recipe should be edited in own category if has one
// TODO: update images
// TODO: update categories
struct RecipeCollectionView: View {
    @EnvironmentObject var collection: RecipeCollectionVM
    
    @State private var isEditing = false
    
    @State var newCategoryMissingField: Bool = false
    @State var addCategoryExpanded = false
    @State var newCategory: String = ""
    
    @State var editCategory: RecipeCategoryVM?
    @State var isEditingCategory = false
    
    @State var deleteCategoryAlert = false
    @State var deleteCategoryId: Int?
    
    @State private var isCreatingRecipe = false
    
    @State private var presentAlert = false
    
    @State private var presentPasteAlert = false
    @State private var confirmPaste = false
    @State private var explainPaste = false

    @State private var cameraRollSheetPresented = false
    @State private var selectedImage: UIImage?
    
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
                                            collection.setCurrentCategory(category)
                                        }) {
                                            ZStack {
                                                VStack {
                                                    ZStack {
                                                        Circle()
                                                            .foregroundColor(Color.green.opacity(0.8))
                                                        
                                                        if category.imageHandler.images.count > 0 {
                                                            Image(uiImage: category.imageHandler.images[0])
                                                                    .scaleEffect(ImageHandler.getZoomScale(category.imageHandler.images[0], in: CGSize(width: 60, height: 60)))
                                                                    .frame(width: 60, height: 60, alignment: .center)
                                                                    .clipShape(Circle())
                                                        }
                                                    }
                                                }
                                                
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 2)
                                            }
                                            .frame(width: 60, height: 60)
                                            .shadow(color: Color.gray, radius: collection.currentCategory?.id == category.id ? 5 : 1)
                                        }
                                        .disabled(isEditing ? true : false)
                                        
                                        if isEditing && category.name != "All" {
                                            Menu {
                                                Menu {
                                                    Button(action: {
                                                        editCategory = category
                                                        cameraRollSheetPresented = true
                                                    }) {
                                                        Label("Pick from camera roll", systemImage: "photo.on.rectangle")
                                                    }

                                                    Button(action: {
                                                        editCategory = category
                                                        presentAlert = true
                                                        if UIPasteboard.general.url != nil {
                                                            confirmPaste = true
                                                        } else {
                                                            explainPaste = true
                                                        }
                                                    }) {
                                                        Label("Paste", systemImage: "doc.on.clipboard")
                                                    }
                                                } label: {
                                                    Label("Edit Photo", systemImage: "camera")
                                                }
                                                
                                                Button(action: {
                                                    deleteCategoryId = category.id
                                                    deleteCategoryAlert = true
                                                    presentAlert = true
                                                }) {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                                
                                                Button(action: {
                                                }) {
                                                    Label("Cancel", systemImage: "")
                                                }
                                            } label: {
                                                ZStack {
                                                    Circle()
                                                        .fill(Color.white)
                                                        .frame(width: 30, height: 30)
                                                        .opacity(0.8)

                                                    Image(systemName: "pencil")
                                                        .foregroundColor(.black)
                                                }
                                            }
                                        }
                                    }
                                    
                                    EditableText("\(category.name)", isEditing: isEditing, isSelected: category.id == collection.currentCategory?.id ? true : false, onChanged: { name in
                                        collection.updateCategory(forCategoryId: category.id, toName: name)
                                    })
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                }
                                .padding()
                                .padding(.horizontal, 7)
                                .environmentObject(category)
                            }
                        }
                    }
                    .padding(.trailing, 60)
                    .sheet(isPresented: $cameraRollSheetPresented, onDismiss: loadImage) {
                        ImagePicker(image: self.$selectedImage)
                    }
                    .alert(isPresented: $presentAlert) {
                        if confirmPaste {
                            return Alert(title: Text("Add Image"),
                                  message: Text(""),
                                  primaryButton: .default(Text("Ok")) {
                                    if let category = editCategory {
                                        category.setImage(url: UIPasteboard.general.url)
                                        editCategory = nil
                                    }
                                  },
                                  secondaryButton: .default(Text("Cancel")) {
                                    editCategory = nil
                                  })
                        }
                        if explainPaste {
                            return Alert(title: Text("Paste Image"),
                                  message: Text("Copy the URL of an image to the clipboard and tap this button to add the image"),
                                  dismissButton: .default(Text("Ok")))
                        }
                        // deleteCategoryAlert
                        return Alert(title: Text("Delete Category"),
                              message: Text("Deleting this category will delete all of its recipes. Are you sure you want to delete it?"),
                              primaryButton: .default(Text("Ok")) {
                                if let deleteCategoryId = self.deleteCategoryId {
                                    collection.deleteCategory(withId: deleteCategoryId)
                                }
                              },
                              secondaryButton: .cancel())
                    }
                    
                    HStack(alignment: .center) {
                        Spacer()
                        
                        if !addCategoryExpanded {
                            Button(action: {
                                withAnimation {
                                    addCategoryExpanded = true
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.white)
                                        .shadow(radius: 5)

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
                            .onTapGesture(count: 1, perform: {})
                            .frame(width: 200, height: 60)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom)
                    .zIndex(1)
                }
                .background(formBackgroundColor())
                .border(Color.white, width: 2)
                
//                    CategoryView()
//                        .environmentObject(collection.currentCategory!)
//                }
                
                if collection.currentCategory != nil {
                    List {
                        ForEach(collection.currentCategory!.recipes) { recipe in
                            Group {
                                if isEditing {
                                    Text("\(recipe.name)")
                                        .deletable(isDeleting: true, onDelete: {
                                            withAnimation {
                                                collection.deleteRecipe(withId: recipe.id)
                                            }
                                        })
                                }
                                else {
                                    NavigationLink(destination:
                                                RecipeView(recipe: RecipeVM(recipe: recipe, category: collection.currentCategory!))
                                                    .environmentObject(collection.currentCategory!)
                                                    .environmentObject(collection)
                                    ) {
                                        Text("\(recipe.name)")
                                            .fontWeight(.regular)
                                    }
                                    
                                }
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.map{ collection.currentCategory!.recipes[$0] }.forEach { recipe in
                                collection.deleteRecipe(withId: recipe.id)
                            }
                        }
                    }
                    .padding(.top, 0)
                }
                
                HStack(alignment: .center) {
                    Spacer()

                    Button(action: {
                        createRecipe()
                    }) {
                        ZStack {
                            Circle()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                                .shadow(radius: 5)

                            Image(systemName: "plus")
                        }
                    }
                    .sheet(isPresented: $isCreatingRecipe, onDismiss: {
                        if let currentCategory = collection.currentCategory {
                            collection.setCurrentCategory(currentCategory)
                        }
                    }) {
                        CreateRecipeView(isCreatingRecipe: self.$isCreatingRecipe)
                            .environmentObject(RecipeVM(category: collection.currentCategory!))
                            .environmentObject(RecipeCategoryVM(category: collection.currentCategory!.category, collection: collection))
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
            .gesture(addCategoryExpanded ? TapGesture(count: 1).onEnded {
                withAnimation {
                    addCategoryExpanded = false
                }
            } : nil)
        }
    }
    
    // loads image selected from camera roll
    func loadImage() {
        withAnimation {
            guard let inputImage = selectedImage else { return }
            if let category = self.editCategory {
                category.setImage(uiImage: inputImage)
                self.editCategory = nil
            }
        }
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
