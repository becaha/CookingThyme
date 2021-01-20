//
//  RecipeCollectionView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import SwiftUI

// TODO: measurement page to ask how many tbsp in an ounce

// TODO: if edit name of category and then its photo, will not update the photo
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
    
    @State private var droppableRecipe: Recipe?
    
    @State private var bottomScrollY: CGFloat = 0
    @State private var topScrollY: CGFloat = 0
    @State private var frameMinY: CGFloat = 0
    @State private var frameMaxY: CGFloat = 0
    
    @State private var searchMinY: CGFloat = 0
    
    @State private var search: String = ""
            
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
                                                CircleImage(width: 60, height: 60)
                                                
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 2)
                                            }
                                            .frame(width: 60, height: 60)
                                            .shadow(color: Color.gray, radius: collection.currentCategory?.id == category.id ? 5 : 1)
                                        }
                                        .disabled(isEditing ? true : false)
                                        
                                        if isEditing {
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
                                    
                                    EditableText("\(category.name)", isEditing: category.name == "All" ? false : isEditing, isSelected: category.id == collection.currentCategory?.id ? true : false, onChanged: { name in
                                        // without this, the image will update, it causes an early refresh
                                        collection.updateCategory(forCategoryId: category.id, toName: name)
                                    })
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                }
                                .droppable(if: isDroppable(toCategory: category), of: ["public.image", "public.text"], isTargeted: nil) { providers in
                                    return drop(providers: providers, category: category)
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
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.white)
                                        .shadow(radius: 1)

                                    Image(systemName: "plus")
                                        .font(Font.subheadline.weight(.bold))
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
                    .padding()
                    .padding(.bottom)
                    .zIndex(1)
                }
                .background(formBackgroundColor())
                .border(Color.white, width: 2)
                
                if collection.currentCategory != nil {
                    GeometryReader { frameGeometry in
                        VStack(spacing: 0) {
                            GeometryReader { geometry in
                                HStack {
                                    TextField("Search", text: $search, onCommit: {
                                        print("\(search)")
                                    })
                                    .font(Font.body.weight(.regular))
                                    .foregroundColor(.black)
                                    .opacity(getOpacity(frameMinY: frameGeometry.frame(in: .global).minY, searchMinY: geometry.frame(in: .global).minY))
                                    
                                    Button(action: {
                                        print("\(search)")
                                    }) {
                                        Image(systemName: "magnifyingglass")
                                            .font(Font.body.weight(.regular))
                                            .foregroundColor(searchFontColor())
                                            .opacity(getOpacity(frameMinY: frameGeometry.frame(in: .global).minY, searchMinY: geometry.frame(in: .global).minY))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .formItem(isSearchBar: true)
                                .scaleEffect(y: getScale(frameMinY: frameGeometry.frame(in: .global).minY, searchMinY: geometry.frame(in: .global).minY))
                            }
                            .frame(height: 35)
                            .padding(.bottom)
                            
                            ForEach(collection.currentCategory!.recipes) { recipe in
                                Group {
                                    if isEditing {
                                        Text("\(recipe.name)")
                                            .deletable(isDeleting: true, onDelete: {
                                                withAnimation {
                                                    collection.deleteRecipe(withId: recipe.id)
                                                }
                                            })
                                        .formItem()
                                    }
                                    else {
                                        NavigationLink(destination:
                                            RecipeView(recipe: RecipeVM(recipe: recipe, category: collection.currentCategory!))
                                                .environmentObject(collection.currentCategory!)
                                                .environmentObject(collection)
                                        ) {
                                            Text("\(recipe.name)")
                                                .fontWeight(.regular)
                                                .formItem(isNavLink: true)
                                        }
                                    }
                                }
                                .onDrag {
                                    droppableRecipe = recipe
                                    return NSItemProvider(object: recipe.name as NSString)
                                }
                            }
                            .onDelete { indexSet in
                                indexSet.map{ collection.currentCategory!.recipes[$0] }.forEach { recipe in
                                    collection.deleteRecipe(withId: recipe.id)
                                }
                            }
                            
                            Spacer()
                            
                            GeometryReader { geometry -> Text in
                                bottomScrollY = geometry.frame(in: .global).minY
                                frameMaxY = frameGeometry.frame(in: .global).maxY
                                return Text("")
                            }
                        }
                        .formed()
                    }

                    VStack {
                        
                        HStack {
                            Button(action: {
                                createRecipe()
                            }) {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(.white)
                                            .shadow(radius: 1)

                                        Image(systemName: "plus")
                                            .font(Font.subheadline.weight(.bold))
                                            .foregroundColor(mainColor())
                                    }
                                    
                                    Text("New Recipe")
                                        .bold()
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .overlay(
                        Rectangle()
                            .frame(width: nil, height: bottomScrollY <= frameMaxY ? 0 : 1, alignment: .top)
                            .foregroundColor(borderColor()),
                        alignment: .top)
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
            .background(formBackgroundColor())
            .navigationBarTitle("\(collection.name)'s Recipes", displayMode: .inline)
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
            .onAppear {
                collection.refreshCurrrentCategory()
            }
        }
    }
    
    func getScale(frameMinY: CGFloat, searchMinY: CGFloat) -> CGFloat {
        self.frameMinY = frameMinY
        self.searchMinY = searchMinY
        if frameMinY - searchMinY >= -5 && frameMinY - searchMinY <= 35 {
            return CGFloat(35 - (frameMinY - searchMinY + 5)) / 35.0
        }
        return 1
    }
    
    func getOpacity(frameMinY: CGFloat, searchMinY: CGFloat) -> Double {
        self.frameMinY = frameMinY
        self.searchMinY = searchMinY
        if frameMinY - searchMinY >= 0 && frameMinY - searchMinY <= 35 {
            return Double(35 - (3 * (frameMinY - searchMinY))) / 35.0
        }
        return 1
    }
    
    // a recipe is droppable into a category that is not All and is not their current category
    func isDroppable(toCategory category: RecipeCategoryVM) -> Bool {
        return category.name != "All" && droppableRecipe?.recipeCategoryId != category.id
    }
    
    func moveRecipe(_ recipeName: String, toCategory category: RecipeCategoryVM) {
        collection.moveRecipe(withName: recipeName, toCategoryId: category.id)
        resetDrag()
    }
    
    func resetDrag() {
        withAnimation {
            collection.refreshCurrrentCategory()
        }
    }
    
    private func drop(providers: [NSItemProvider], category: RecipeCategoryVM) -> Bool {
        if let provider = providers.first(where: { $0.canLoadObject(ofClass: String.self) }) {
            let _ = provider.loadObject(ofClass: String.self) { object, error in
                if let recipeName = object {
                    DispatchQueue.main.async {
                        moveRecipe(recipeName, toCategory: category)
                    }
                }
            }

            return true
        }

        return false
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

//struct RecipeCollectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipeCollectionView()
//            .environmentObject(UserVM(username: "Becca"))
//    }
//}
