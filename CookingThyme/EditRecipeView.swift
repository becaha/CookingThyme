//
//  EditRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/17/20.
//

import SwiftUI
import Combine

// TODO: dark mode

// TODO: touchy self-plus buttons i want to click
// TODO: add category button, lots of space, do i want it there only when isediting?

// TODO: don't cllear ing/dir if not entered but clicked away from


// TODO: keyboard avoid dont move scroll up, just down
// https://www.hackingwithswift.com/forums/100-days-of-swiftui/jump-focus-between-a-series-of-textfields-pin-code-style-entry-widget/765
struct EditRecipeView: View {
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var category: RecipeCategoryVM
    @Binding var isEditingRecipe: Bool
    @EnvironmentObject var recipe: RecipeVM
            
    private var fieldMissing: Bool {
        return nameFieldMissing || ingredientsFieldMissing || directionsFieldMissing || servingsFieldMissing
    }
    
    @State var presentErrorAlert = false
    
    var nameFieldMissingMessage = "Must have a name."
    var newIngredientFieldMissingMessage = "Must fill in an ingredient slot."
    var newDirectionFieldMissingMessage = "Must fill in a direction."
    var ingredientsFieldMissingMessage = "Must have at least one ingredient."
    var directionsFieldMissingMessage = "Must have at least one direction."
    var servingsFieldMissingMessage = "Must have a serving size."
        
    @State private var nameFieldMissing = false
    @State private var newIngredientFieldMissing = false
    @State private var newDirectionFieldMissing = false
    @State private var ingredientsFieldMissing = false
    @State private var directionsFieldMissing = false
    @State private var servingsFieldMissing = false
            
    @State private var name: String = ""
    @State private var nameFieldPlaceholder: String = "Recipe Name"
    @State private var servings: String = ""
    @State private var ingredientPlaceholder = "New Ingredient"
    @State private var ingredient: String = ""
    @State private var directionPlaceholder = "New Direction"
    @State private var direction: String = ""
    
    @State private var source: String = ""
    
    @State private var cameraRollSheetPresented = false
    @State private var importRecipePresented = false
    @State private var selectedImage: UIImage?
    
    @State private var urlString: String = ""
    
    @State var isImportingRecipe: Bool = false
    
    @State private var presentRecipeText = false
    
    @State private var editingIngredientIndex: Int?
    @State private var editingDirectionIndex: Int?
    
    @State private var editingName = false
    
    @State private var partialRecipeAlert = false
    @State private var alertShown = false
    
    @State var buttonFlashOpacity: Double = 1 // 0.6
    @State var buttonScale: CGFloat = 1 // 0.9
    
    @State var startPos : CGPoint = .zero
    @State var isSwipping = true
    
    @State var isSaving = false
    
    var body: some View {
        VStack(spacing: 0) {
            if recipe.isImportingFromURL && !recipe.invalidURL {
                UIControls.Loading()
                    .padding()
                
                Spacer()
            }
            else if recipe.importFromURL {
                VStack(spacing: 0) {
                    HStack {
                        Text("Import from:")
                            .customFont(style: .subheadline)
                        
                        TextField("URL", text: $urlString, onCommit: {
                            transcribeWeb()
                        })
                        .customFont(style: .subheadline)
                        .foregroundColor(nil)
                    }
                    .formItem()
                    
                    HStack {
                        ErrorMessage("Invalid URL", isError: $recipe.invalidURL)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Button(action: {
                            withAnimation {
                                recipe.importFromURL = false
                            }
                        }) {
                            Text("Cancel")
                                .customFont(style: .subheadline)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                transcribeWeb()
                            }
                        }) {
                            Text("Import")
                                .customFont(style: .subheadline)
                        }
                    }
                    .padding()
                }
                .formed()
            }
            else {
                Group {
                    if presentRecipeText {
                        RecipeTextView()
                    }
                    else {
                        EditableRecipe()
                    }
                }
                .onReceive(recipe.$recipe, perform: { _ in
                    setRecipe()
                })
            }
        }
        .gesture(DragGesture()
                .onChanged { gesture in
                    if self.isSwipping {
                       self.startPos = gesture.location
                       self.isSwipping.toggle()
                   }
                }
                .onEnded { gesture in
                    let xDist =  abs(gesture.location.x - self.startPos.x)
                    let yDist =  abs(gesture.location.y - self.startPos.y)
                    if self.startPos.x < gesture.location.x && yDist < xDist {
                        // clear search/filters
                        clearSearchFilters()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    self.isSwipping.toggle()
                }
             )
        .background(formBackgroundColor().edgesIgnoringSafeArea(.all))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading:
                Button(action: {
                    withAnimation {
                        if recipe.isCreatingRecipe() {
                            // clear search/filters
                            clearSearchFilters()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        else {
                            isEditingRecipe = false
                        }
                    }
                }) {
                    Text("Cancel")
                }
                .padding(.leading, 0)
                .foregroundColor(mainColor())
                .frame(minWidth: 44, minHeight: 44)
            ,
            trailing:
                HStack {
//                     TODO: animate, cannot animate items in nav bar
                    if recipe.recipeText != nil {
                        Button(action: {
                            // save stuff
                            unfocusEditable()
                            // TODO name change switch to recipe text and back
                            unfocusMultilineTexts()
                            withAnimation {
                                presentRecipeText.toggle()
                            }
                        })
                        {
                            if presentRecipeText {
                                Image(systemName: "doc.plaintext.fill")
                            }
                            else {
                                Image(systemName: "doc.plaintext")
                                    .opacity(buttonFlashOpacity)
                                    .scaleEffect(buttonScale)
                            }
                        }
                        .padding(.horizontal)
                        .frame(minWidth: 44, minHeight: 44)
                    }
                    
                    if recipe.isCreatingRecipe() {
                        Menu {
                            Text("Import Recipe")
                                .font(.title)
                                .foregroundColor(.black)
                            
                            Button(action: {
                                cameraRollSheetPresented = true
                            }) {
                                Text("From camera roll")
                            }
                            
                            Button(action: {
                                withAnimation {
                                    recipe.importFromURL = true
                                }
                            }) {
                                Text("From URL")
                            }
                            
                            Button(action: {}) {
                                Text("Cancel")
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                                .padding(.horizontal)
                                .frame(minWidth: 44, minHeight: 44)
                        }
                        .disabled(recipe.isImportingFromURL)
                        .sheet(isPresented: $cameraRollSheetPresented, onDismiss: transcribeImage) {
                            ZStack {
                                NavigationView {
                                }
                                .background(Color.white.edgesIgnoringSafeArea(.all))
                                
                                ImagePicker(image: self.$selectedImage)
                            }
                        }
                    }
            
                    // TODO: done is way far from side
                    Button(action: {
                        saveRecipe()
                        unfocusEditable()
                        unfocusMultilineTexts()
                    })
                    {
                        Text("Done")
                    }
                    .alert(isPresented: $presentErrorAlert) {
                        Alert(title: Text("Save Failed"),
                              message: Text("\(getErrorMessages())")
                        )
                    }
                }
//                .padding(.trailing, 0)
                .foregroundColor(mainColor())
        )
    }
    
    private func transcribeWeb() {
        if urlString != "" {
            recipe.invalidURL = false
            resetErrors()
            recipe.transcribeRecipe(fromUrlString: urlString)
        }
        else {
            recipe.invalidURL = true
        }
    }
    
    private func transcribeImage() {
        guard let inputImage = selectedImage else { return }
        recipe.transcribeRecipe(fromImage: inputImage)
    }
    
    private func setRecipe() {
        if name == "" || name == nameFieldPlaceholder {
            name = recipe.tempRecipe.name
            if name.isOnlyWhitespace() {
                name = nameFieldPlaceholder
            }
            // was original servings
            servings = recipe.tempRecipe.servings.toString()
            source = recipe.tempRecipe.source
        }
    }
    
    func clearSearchFilters() {
        category.collection.search = ""
        category.collection.currentCategory?.filteredRecipes = category.collection.currentCategory?.recipes ?? []
    }
    
    func resetErrors() {
        servingsFieldMissing = false
        nameFieldMissing = false
        ingredientsFieldMissing = false
        directionsFieldMissing = false
        newDirectionFieldMissing = false
        newIngredientFieldMissing = false
    }
    
    // TODO: save should be not on main thread
    private func saveRecipe() {
        if isSaving {
            return
        }
        isSaving = true
        recipe.tempRecipe.ingredients = recipe.tempRecipe.ingredients.filter { (ingredient) -> Bool in
            !ingredient.ingredientString.isOnlyWhitespace()
        }
        
        recipe.tempRecipe.directions = recipe.tempRecipe.directions.filter { (direction) -> Bool in
            !direction.direction.isOnlyWhitespace()
        }
        resetErrors()

        // TODO: what if they want to name their recipee Recipe Name (name == placeholder && nameFieldMissing)?
        // name cannot the placeholder, or just whitespace
        if name == nameFieldPlaceholder || name.isOnlyWhitespace() {
            nameFieldMissing = true
            name = nameFieldPlaceholder
        }
        if recipe.tempRecipe.ingredients.count == 0 {
            ingredientsFieldMissing = true
        }
        if recipe.tempRecipe.directions.count == 0 {
            directionsFieldMissing = true
        }
        if servings.toInt() < 1 {
            servingsFieldMissing = true
        }
        if !fieldMissing {
            if recipe.isCreatingRecipe() {
                category.createRecipe(name: name, tempIngredients: recipe.tempRecipe.ingredients, directions: recipe.tempRecipe.directions, images: recipe.tempImages, servings: servings, source: source) { createdRecipe in
                    if let createdRecipe = createdRecipe {
                        recipe.setTempRecipe(createdRecipe)
                        recipe.setRecipe(createdRecipe)
                    }
                    else {
                        print("error creating recipe")
                    }
                    isSaving = false
                    withAnimation {
                        isEditingRecipe = false
                    }
                }
            }
            else {
                recipe.updateRecipe(withId: recipe.id, name: name, ingredients: recipe.tempRecipe.ingredients, directions: recipe.tempRecipe.directions, images: recipe.tempRecipe.images, servings: servings, source: source, categoryId: recipe.categoryId) { success in
                    isSaving = false
                    withAnimation {
                        isEditingRecipe = false
                    }
                }
            }
            // TODO: have page shrink up into square and be brought to the recipe collection view showing the new recipe
            // flying into place
//            withAnimation {
//                isEditingRecipe = false
//            }
        }
        else {
            presentErrorAlert = true
            isSaving = false
        }
    }
    
    private func addDirection() {
        if !direction.isOnlyWhitespace() && direction != directionPlaceholder {
            newDirectionFieldMissing = false
            recipe.addTempDirection(direction)
            direction = directionPlaceholder
        }
        else {
            newDirectionFieldMissing = true
        }
        if recipe.tempRecipe.directions.count > 0 {
            directionsFieldMissing = false
        }
    }
    
    private func addIngredient() {
        if !ingredient.isOnlyWhitespace() && ingredient != ingredientPlaceholder {
            newIngredientFieldMissing = false
            recipe.addTempIngredient(ingredient)
            ingredient = ingredientPlaceholder
        }
        else {
            newIngredientFieldMissing = true
        }
        if recipe.tempRecipe.ingredients.count > 0 {
            ingredientsFieldMissing = false
        }
    }
    
    @ViewBuilder
    func EditableRecipe() -> some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    if partialRecipeAlert {
    //                    Button(action: {
    //                        withAnimation {
    //                            // save stuff
    //                            unfocusEditable()
    //                            presentRecipeText = true
    //                        }
    //                    }) {
                            HStack {
                                (Text("Missing fields? Reference the full recipe text by clicking ") +  Text(Image(systemName: "doc.plaintext")) + Text(" above."))
                                    .customFont(style: .caption1)
                            }
                            .formHeader()
    //                    }
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            ZStack {
                                HStack {
                                    Spacer()

                                    RecipeNameTitle(name: " ")

                                    Spacer()
                                }
                                .opacity(!editingName ? 1 : 0)
                                
                                HStack {
                                    Spacer()
                                    
                                    RecipeNameTitle(name: "\(name)")
                                        .foregroundColor(name == nameFieldPlaceholder ? placeholderFontColor() : .black)
                                    
                                    Spacer()
                                }
                                .opacity(!editingName ? 1 : 0)

                                if editingName {
                                    VStack {
                                        Spacer()
                                        
                                        EditableTextView(textBinding: $name, isFirstResponder: true, textStyle:  UIFont.TextStyle.largeTitle, textAlignment: NSTextAlignment.center)
                                            .onChange(of: name) { value in
                                                // on commit by enter
                                                if value.hasSuffix("\n") {
                                                    editingName = false
                                                    name.removeLast(1)
                                                    withAnimation {
                                                        // unfocus
                                                        unfocusEditable()
                                                        
                                                        if name.isOnlyWhitespace() {
                                                            name = nameFieldPlaceholder
                                                        }
                                                    }
                                                }
                                                if name != "" && name != nameFieldPlaceholder {
                                                    withAnimation {
                                                        nameFieldMissing = false
                                                    }
                                                }
                                            }
                                            .recipeTitle()
                     
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .simultaneousGesture(
                                TapGesture(count: 1).onEnded { _ in
                                    // if not editing name currently
                                    if !editingName {
                                        unfocusEditable()
                                        unfocusMultilineTexts()
                                    }
                                    editingName = true
                                    if name == nameFieldPlaceholder {
                                        name = ""
                                    }
                                }
                            )
                            
                            ErrorMessage("\(nameFieldMissingMessage)", isError: $nameFieldMissing, isCentered: true)
                                .padding(0)
                        }
                        .padding(.bottom, 0)
                    }
                    .formHeader()
                    
                    ImagesView()
                    
                    VStack(spacing: 0) {
                        HStack {
                            Text("Ingredients")
                                .customFont(style: .subheadline)
                                .textCase(.uppercase)

                            Spacer()
                            
                            VStack {
                                Picker(selection: $servings, label:
                                        HStack {
                                            Text("Servings: \(servings)")
                                                .textCase(.uppercase)
                                                .customFont(style: .subheadline)
                                                // can't remember why this was a problem
                                                .fixedSize(horizontal: true, vertical: false)
                                    
                                            Image(systemName: "chevron.down")
                                        }
                                        .foregroundColor(servingsFieldMissing && servings == "0" ? .red : Color.gray)
                                )
                                {
                                    ForEach(1..<101, id: \.self) { num in
                                        Text("\(num.toString())").tag(num.toString())
                                            .customFont(style: .subheadline)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                        }
                        .formHeader()
                                
                        VStack(spacing: 0) {
                            ForEach(0..<recipe.tempRecipe.ingredients.count, id: \.self) { index in
                                HStack {
                                    EditableIngredient(index: index, editingIndex: $editingIngredientIndex)
                                        .environmentObject(recipe)
                                }
                                .id(index)
                                .deletable(isDeleting: true, onDelete: {
                                    withAnimation {
                                        recipe.removeTempIngredient(at: index)
                                    }
                                })
                                .formSectionItem(padding: .horizontal)
                                .simultaneousGesture(
                                    TapGesture(count: 1).onEnded { _ in
                                        unfocusEditable()
                                        unfocusMultilineTexts()
                                        editingIngredientIndex = index
                                    }
                                )
                            }
                            .onDelete { indexSet in
                                indexSet.map{ $0 }.forEach { index in
                                    recipe.removeTempIngredient(at: index)
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    ZStack {
                                        HStack {
                                            RecipeControls.ReadIngredientText(" ")
                                                .padding()

                                            Spacer()
                                        }
                                        .opacity(0)
                                        
                                        HStack {
                                            RecipeControls.ReadIngredientText(ingredient)
                                                .padding()

                                            Spacer()
                                        }
                                        .opacity(0)
                                        
                                        VStack {
                                            Spacer()

                                            PlaceholderTextView(placeholderText: ingredientPlaceholder, textBinding: $ingredient, isFirstResponder: false)
                                                .customFont(style: .subheadline)
                                                .onChange(of: ingredient) { value in
                                                    print("")
                                                    if value.hasSuffix("\n") {
                                                        ingredient.removeLast(1)
                                                        withAnimation {
                                                            // unfocus
                                                            unfocusEditable()
                                                            unfocusMultilineTexts()
                                                            addIngredient()
                                                        }
                                                    }
                                                }

                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                    }
                                    .autocapitalization(.none)
                                    .simultaneousGesture(
                                        TapGesture(count: 1).onEnded { _ in
                                            unfocusEditable()
                                            unfocusMultilineTexts()
                                            editingIngredientIndex = recipe.tempRecipe.ingredients.count
                                        }
                                    )
                                    
                                    UIControls.AddButton(action: {
                                        withAnimation {
                                            unfocusEditable()
                                            unfocusMultilineTexts()
                                            addIngredient()
                                        }
                                    })
                                }
                                .id(recipe.tempRecipe.ingredients.count)
                                .formSectionItem(padding: .horizontal)
                            }
                        }
                        .formSection()
                    
                        VStack(alignment: .leading) {
                            ErrorMessage("\(newIngredientFieldMissingMessage)", isError: $newIngredientFieldMissing)

                            ErrorMessage("\(ingredientsFieldMissingMessage)", isError: $ingredientsFieldMissing)
                        }
                        .formFooter()
                    }
                
                    VStack(spacing: 0) {
                        HStack {
                            Text("Directions")
                                .textCase(.uppercase)
                                .customFont(style: .subheadline)

                            Spacer()
                        }
                        .formHeader()
                        
                        VStack(spacing: 0) {
                            ForEach(0..<recipe.tempRecipe.directions.count, id: \.self) { index in
                                HStack(alignment: .center, spacing: 20) {
                                    Text("\(index + 1)")
                                        .customFont(style: .subheadline)
                                    
                                    EditableDirection(index: index, editingIndex: $editingDirectionIndex)
                                        .environmentObject(recipe)
                                }
                                .id(recipe.tempRecipe.ingredients.count + 1 + index)
                                .deletable(isDeleting: true, onDelete: {
                                    withAnimation {
                                        recipe.removeTempDirection(at: index)
                                    }
                                })
                                .formSectionItem(padding: .horizontal)
                                .simultaneousGesture(
                                    TapGesture(count: 1).onEnded { _ in
                                        unfocusEditable()
                                        unfocusMultilineTexts()
                                        editingDirectionIndex = index
                                    }
                                )
                            }
                            .onDelete { indexSet in
                                indexSet.map{ $0 }.forEach { index in
                                    recipe.removeTempDirection(at: index)
                                }
                            }
                                                
                            VStack(alignment: .leading) {
                                HStack(alignment: .center, spacing: 20) {
                                    Text("\(recipe.tempRecipe.directions.count + 1)")
                                        .customFont(style: .subheadline)
                                    
                                    ZStack {
                                        HStack(spacing: 0) {
                                            RecipeControls.ReadDirection(direction: " ")
                                                .padding()

                                            Spacer()
                                        }
                                        .opacity(0)
                                        
                                        HStack(spacing: 0) {
                                            RecipeControls.ReadDirection(direction: direction)
                                                .padding()

                                            Spacer()
                                        }
                                        .opacity(0)
                                        
                                        VStack {
                                            Spacer()

                                            PlaceholderTextView(placeholderText: directionPlaceholder, textBinding: $direction, isFirstResponder: false)
                                                .customFont(style: .subheadline)
                                                .onChange(of: direction) { value in
                                                    if value.hasSuffix("\n") {
                                                        direction.removeLast(1)
                                                        withAnimation {
                                                            // unfocus
                                                            unfocusEditable()
                                                            unfocusMultilineTexts()
                                                            addDirection()
                                                        }
                                                    }
                                                }

                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                    }
                                    .autocapitalization(.none)
                                    .simultaneousGesture(
                                        TapGesture(count: 1).onEnded { _ in
                                            unfocusEditable()
                                            unfocusMultilineTexts()
                                            editingDirectionIndex = recipe.tempRecipe.directions.count
                                        }
                                    )

                                    UIControls.AddButton(action: {
                                        withAnimation {
                                            // unfocus
                                            unfocusEditable()
                                            unfocusMultilineTexts()
                                            addDirection()
                                        }
                                    })
                                }
                                .id(recipe.tempRecipe.ingredients.count + recipe.tempRecipe.directions.count + 1)
                                .formSectionItem(padding: .horizontal)
                            }
                        }
                        .formSection()
                    
                        
                        VStack {
                            Group {
                                ErrorMessage("\(newDirectionFieldMissingMessage)", isError: $newDirectionFieldMissing)

                                ErrorMessage("\(directionsFieldMissingMessage)", isError: $directionsFieldMissing)
                            }
                        }
                        .formFooter()
                    }
                }
                .onChange(of: editingIngredientIndex) { index in
                    if let index = index {
                        withAnimation {
                            proxy.scrollTo(index, anchor: .bottomTrailing)
                        }
                    }
                }
                .onChange(of: editingDirectionIndex) { index in
                    if let index = index {
                        withAnimation {
                            proxy.scrollTo(recipe.tempRecipe.ingredients.count + 1 + index, anchor: .bottomTrailing)
                        }
                    }
                }
                .gesture(editingIngredientIndex != nil || editingDirectionIndex != nil || editingName ? TapGesture(count: 1).onEnded {
                    unfocusMultilineTexts()
                } : nil)
                .simultaneousGesture(
                    TapGesture().onEnded { _ in
                        unfocusEditable()
                    }
                )
            }
            .onAppear {
                if !alertShown && recipe.recipeText != nil && (recipe.name == "" || recipe.ingredients.count == 0 || recipe.directions.count == 0) {
                    alertShown = true
                    partialRecipeAlert = true
                }
                else if alertShown {
                    partialRecipeAlert = false
                }
            }
        }
    }
    
    func unfocusMultilineTexts() {
        editingName = false
        withAnimation {
            editingIngredientIndex = nil
            editingDirectionIndex = nil
            if name.isOnlyWhitespace() {
                name = nameFieldPlaceholder
            }
        }
    }
    
    func getErrorMessages() -> String {
        var errorMessage = ""
        if nameFieldMissing {
            errorMessage.append(nameFieldMissingMessage)
        }
        if ingredientsFieldMissing {
            errorMessage.append(ingredientsFieldMissingMessage)
        }
        if directionsFieldMissing {
            errorMessage.append(directionsFieldMissingMessage)
        }
        if servingsFieldMissing {
            errorMessage.append(servingsFieldMissingMessage)
        }
        return errorMessage.replacingOccurrences(of: ".", with: ". ")
    }
}

extension Array where Element: Identifiable {
    func indexOf(element: Element) -> Int? {
        for index in 0..<self.count {
            if self[index].id == element.id {
                return index
            }
        }
        return nil
    }
    
    mutating func remove(element: Element) {
        if let index = indexOf(element: element) {
            self.remove(at: index)
        }
    }
}

extension String {
    func isOnlyWhitespace() -> Bool {
        self == "" || self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
