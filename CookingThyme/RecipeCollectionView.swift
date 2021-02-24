//
//  RecipeCollectionView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/13/20.
//

import SwiftUI

// TODO: focus new category
struct RecipeCollectionView: View {
    // the view knows when sheet is dismissed
    @Environment(\.presentationMode) var presentation

    // portrait or landscape
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    var isLandscape: Bool {
        return horizontalSizeClass == .regular && verticalSizeClass == .compact
    }
    
    @EnvironmentObject var collection: RecipeCollectionVM
    
    @State private var isEditing = false
    
    @State var newCategoryMissingField: Bool = false
    @State var addCategoryExpanded = false
    @State var newCategory: String = ""
    
    @State var editCategory: RecipeCategoryVM?
    @State var isEditingCategory = false
    
    @State var deleteCategoryAlert = false
    @State var deleteCategoryId: String?
    
    @State private var isCreatingRecipe = false
        
    @State private var presentAlert = false
    
    @State private var photoEditAlert = false
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
    
//    @State private var search: String = ""

    let categoryNameMaxCount = 15
            
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                Group {
                    if isLandscape {
                        CollectionViewLandscape(width: geometry.size.width, height: geometry.size.height)
                    }
                    else {
                        CollectionView(width: geometry.size.width)
                    }
                }
                .background(formBackgroundColor().edgesIgnoringSafeArea(.all))
            }
            .gesture(addCategoryExpanded ? TapGesture(count: 1).onEnded {
                withAnimation {
                    addCategoryExpanded = false
                }
            } : nil)
            .simultaneousGesture(
                TapGesture().onEnded { _ in
                    unfocusEditable()
                }
            )
            .loadable(isLoading: $collection.isLoading)
        }
        .navigationBarColor(UIColor(navBarColor()), text: "Recipe Book", style: .headline, textColor: UIColor(formItemFont()))
        .navigationBarTitle(Text(""), displayMode: .inline)
        .navigationBarItems(trailing:
            UIControls.EditButton(
                action: {
                    isEditing.toggle()
                    if !isEditing {
                        unfocusEditable()
                        withAnimation {
                            collection.popullateCategories() {
                                success in
                                if !success {
                                    print("error populating categories")
                                }
                            }
                        }
                    }
                },
                isEditing: isEditing)
        )
    }
    
    @ViewBuilder
    func CollectionView(width: CGFloat) -> some View {
        VStack(spacing: 0) {
            CategoriesView(width: width)
            
            if collection.currentCategory != nil {
                CurrentCategoryView()
                
                AddNewRecipeView()
            }
        }
    }
    
    @ViewBuilder
    func CollectionViewLandscape(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            HStack(spacing: 0) {
                CategoriesView(width: width)

                if collection.currentCategory != nil {
                    VStack(spacing: 0) {
                        CurrentCategoryView()
                        
                        AddNewRecipeView()
                    }
                }
            }
            
            AddCategoryViewLandscape(width: width)
        }
    }
    
    @ViewBuilder
    func CurrentCategoryView() -> some View {
        GeometryReader { frameGeometry in
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    HStack {
                        AutoSearchBar(search: $collection.search) { result in
                            searchRecipes(result)
                        }
                        .opacity(getOpacity(frameMinY: frameGeometry.frame(in: .global).minY, searchMinY: geometry.frame(in: .global).minY))
                    }
                    .formItem(isSearchBar: true)
                    .scaleEffect(y: getScale(frameMinY: frameGeometry.frame(in: .global).minY, searchMinY: geometry.frame(in: .global).minY))
                }
                .frame(height: 35)
                .padding(.bottom)

                if collection.currentCategory!.filteredRecipes.count == 0 {
                    Text("No recipes found.")
                        .customFont(style: .subheadline)
                }

                ForEach(collection.currentCategory!.filteredRecipes) { recipe in
                    Group {
                        if isEditing {
                            Text("\(recipe.name)")
                                .customFont(style: .subheadline)
                                .deletable(isDeleting: true, onDelete: {
                                    withAnimation {
                                        collection.deleteRecipe(withId: recipe.id)
                                    }
                                })
                            .formItem()
                        }
                        else {
                            NavigationLink(destination:
                                            RecipeView(recipe: recipe, isEditingRecipe: false)
                                    .environmentObject(collection.currentCategory!)
                                    .environmentObject(collection)
                            ) {
                                Text("\(recipe.name)")
                                    .customFont(style: .subheadline)
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
    }
    
    @ViewBuilder
    func AddNewRecipeView() -> some View {
        VStack {
            HStack {
                if isLandscape {
                    Spacer()
                }
                
                NavigationLink(destination:
                    CreateRecipeView(category: collection.currentCategory!)
                        .environmentObject(collection)
                ) {
                    UIControls.AddViewHorizontal(withLabel: "New Recipe")
                }
                // when change view to create new recipe, clear search
                .simultaneousGesture(
                    TapGesture(count: 1).onEnded { _ in
                        withAnimation {
                            collection.search = ""
                        }
                    }
                )
                
                if !isLandscape {
                    Spacer()
                }
            }
        }
        .padding()
        .overlay(
            Rectangle()
                .frame(width: nil, height: bottomScrollY <= frameMaxY ? 0 : 1, alignment: .top)
                .foregroundColor(borderColor()),
            alignment: .top
        )
    }
    
    @ViewBuilder
    func CategoryCircleView(_ category: RecipeCategoryVM) -> some View {
        ZStack {
            Button(action: {
                collection.setCurrentCategory(category)
                collection.search = ""
            }) {
                CircleImage()
                    .shadow(color: selectedShadowColor(), radius: collection.currentCategory?.id == category.id ? 5 : 1)
            }
            .disabled(isEditing ? true : false)
            
            CategoryEditMenu(category)
        }
    }
    
    // TODO: categories with long name, character limit or 2 lines?
    @ViewBuilder
    func CategoryView(_ category: RecipeCategoryVM) -> some View {
        VStack {
            CategoryCircleView(category)

            EditableText("\(category.name)", isEditing: category.name == "All" ? false : isEditing, isSelected: category.id == collection.currentCategory?.id ? true : false, onChanged: { name in
//                if name.count < categoryNameMaxCount {
                    collection.updateCategory(forCategoryId: category.id, toName: name)
//                }
//                else {
//
//                }
            })
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .customFont(style: .subheadline)
            .lineSpacing(0)
            .frame(width: 80, height: 40)
        }
        .droppable(if: isDroppable(toCategory: category), of: ["public.image", "public.text"], isTargeted: nil) { providers in
            return drop(providers: providers, category: category)
        }
        .sheet(isPresented: $cameraRollSheetPresented, onDismiss: loadImage) {
            ZStack {
                NavigationView {
                }
                .background(Color.white.edgesIgnoringSafeArea(.all))
                
                ImagePicker(image: self.$selectedImage)
            }
        }
        .padding(isLandscape ? [.horizontal, .top] : .all)
        .environmentObject(category)
    }
    
    @ViewBuilder
    func CategoriesScroll() -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(collection.categories, id: \.self) { category in
                    CategoryView(category)
                }
            }
        }
        .padding(.trailing, 60) // leaves space for add category button
    }
    
    @ViewBuilder
    func CategoriesScrollLandscape(width: CGFloat) -> some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                ForEach(collection.categories, id: \.self) { category in
                    CategoryView(category)
                }
            }
        }
        .frame(width: width / 7)
        .padding(.bottom, 60) // leaves space for add category button
    }

    @ViewBuilder
    func CategoriesView(width: CGFloat) -> some View {
        ZStack {
            Group {
                if isLandscape {
                    CategoriesScrollLandscape(width: width)
                }
                else {
                    CategoriesScroll()
                }
            }
            .alert(isPresented: $presentAlert) {
                if photoEditAlert {
                    if confirmPaste {
                        return Alert(title: Text("Add Image"),
                              message: Text(""),
                              primaryButton: .default(Text("Ok")) {
                                if let category = editCategory {
                                    category.setImage(url: UIPasteboard.general.url)
                                    editCategory = nil
                                    confirmPaste = false
                                    photoEditAlert = false
                                }
                              },
                              secondaryButton: .default(Text("Cancel")) {
                                editCategory = nil
                                confirmPaste = false
                                photoEditAlert = false
                              })
                    }
                    if explainPaste {
                        return Alert(title: Text("Paste Image"),
                              message: Text("Copy the URL of an image to the clipboard and tap this button to add the image"),
                              dismissButton: .default(Text("Ok")) {
                                explainPaste = false
                                photoEditAlert = false
                              })
                    }
                    return Alert(title: Text("Delete Image"),
                                 message: Text("Are you sure you want to delete the image for this category?"),
                                 primaryButton: .default(Text("Ok")) {
                                    if let category = editCategory {
                                        withAnimation {
                                            category.removeImage()
                                        }
                                    }
                                    photoEditAlert = false
                                 },
                                 secondaryButton: .default(Text("Cancel")) {
                                    editCategory = nil
                                    photoEditAlert = false
                                 })
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
            
            if !isLandscape {
                AddCategoryView()
            }
        }
        .background(formBackgroundColor())
        
        Divider()
    }
    
    @ViewBuilder
    func AddCategoryView() -> some View {
        HStack(alignment: .center) {
            Spacer()
            
            AddCategoryButton()
        }
        .padding()
        .padding(.bottom)
        .zIndex(1)
    }
    
    @ViewBuilder
    func AddCategoryViewLandscape(width: CGFloat) -> some View {
        HStack {
            VStack(alignment: .center) {
                Spacer()
                
                AddCategoryButton()
                    .padding(.horizontal, 23)
            }
            .padding()
            .frame(width: width / 7)
            
            Spacer()
        }
    }
    
    
    @ViewBuilder
    func AddCategoryButton() -> some View {
        if !addCategoryExpanded {
            Button(action: {
                withAnimation {
                    addCategoryExpanded = true
                }
            }) {
                UIControls.AddButtonView()
            }
            .onTapGesture(count: 1, perform: {})
        }
        else {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("FormItem"))
                    .shadow(color: buttonBorder(), radius: 10)

                HStack {
                    TextField("New Category", text: $newCategory, onCommit: {
                        addCategory()
                    })
                    .customFont(style: .subheadline)
                    .foregroundColor(formItemFont())

                    Spacer()

                    UIControls.AddButton(action: addCategory, isPlain: false)
                }
                .padding()
            }
            .onTapGesture(count: 1, perform: {})
            .padding(.leading)
            .frame(width: 200, height: 30)
        }
    }
    
    @ViewBuilder
    func CategoryEditMenu(_ category: RecipeCategoryVM) -> some View {
        if isEditing {
            // TODO: edit menu color and font of text
            Menu {
                Menu {
                    Button(action: {
                        editCategory = category
                        cameraRollSheetPresented = true
                    }) {
                        Label("Pick from camera roll", systemImage: "photo.on.rectangle")
                            .customFont(style: .subheadline)
                    }

                    Button(action: {
                        editCategory = category
                        photoEditAlert = true
                        presentAlert = true
                        if UIPasteboard.general.url != nil {
                            confirmPaste = true
                        } else {
                            explainPaste = true
                        }
                    }) {
                        Label("Paste", systemImage: "doc.on.clipboard")
                            .customFont(style: .subheadline)
                    }
                    
                    if category.imageHandler.images.count > 0 {
                        Button(action: {
                            editCategory = category
                            photoEditAlert = true
                            presentAlert = true
                        }) {
                            Label("Delete", systemImage: "trash")
                                .customFont(style: .subheadline)
                        }
                    }
                    
                    Button(action: {
                    }) {
                        Text("Cancel")
                            .customFont(style: .subheadline)
                            .foregroundColor(mainColor())
                    }
                } label: {
                    Label("Edit Photo", systemImage: "camera")
                        .customFont(style: .subheadline)
                }
                
                if category.name != "All" {
                    Button(action: {
                        deleteCategoryId = category.id
                        deleteCategoryAlert = true
                        presentAlert = true
                    }) {
                        Label("Delete Category", systemImage: "trash")
                            .customFont(style: .subheadline)
                    }
                }
                
                Button(action: {
                }) {
                    Text("Cancel")
                        .customFont(style: .subheadline)
                        .foregroundColor(mainColor())
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 30, height: 30)
                        .opacity(0.8)

                    Image(systemName: "pencil")
                        .foregroundColor(formItemFont())
                }
            }
        }
    }
    
    func searchRecipes(_ search: String) {
        withAnimation {
            collection.filterCurrentCategory(withSearch: search)
        }
    }
    
    func getScale(frameMinY: CGFloat, searchMinY: CGFloat) -> CGFloat {
        if frameMinY - searchMinY >= -5 && frameMinY - searchMinY <= 35 {
            return CGFloat(35 - (frameMinY - searchMinY + 5)) / 35.0
        }
        return 1
    }
    
    func getOpacity(frameMinY: CGFloat, searchMinY: CGFloat) -> Double {
        if frameMinY - searchMinY >= 0 && frameMinY - searchMinY <= 35 {
            return Double(35 - (3 * (frameMinY - searchMinY))) / 35.0
        }
        return 1
    }
    
    // a recipe is droppable into a category that is not All and is not their current category
    func isDroppable(toCategory category: RecipeCategoryVM) -> Bool {
        return collection.isAddable(recipe: droppableRecipe, toCategory: category)
    }
    
    func moveRecipe(_ recipeName: String, toCategory category: RecipeCategoryVM) {
        collection.moveRecipe(withName: recipeName, toCategoryId: category.id)
        resetDrag()
    }
    
    func resetDrag() {
        withAnimation {
            collection.refreshCurrentCategory()
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
            selectedImage = nil
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
