//
//  EditRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/17/20.
//

import SwiftUI

// TODO: have cursor go to next item in list after one is entered https://www.hackingwithswift.com/forums/100-days-of-swiftui/jump-focus-between-a-series-of-textfields-pin-code-style-entry-widget/765
struct EditRecipeView: View {
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var category: RecipeCategoryVM
    @Binding var isEditingRecipe: Bool
    @EnvironmentObject var recipe: RecipeVM
            
    private var fieldMissing: Bool {
        return nameFieldMissing || newIngredientFieldMissing || newDirectionFieldMissing || ingredientsFieldMissing || directionsFieldMissing || servingsFieldMissing
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
    @State private var servings: String = "100"
    @State private var ingredientPlaceholder = "New Ingredient"
    @State private var ingredient: String = ""
    @State private var directionPlaceholder = "New Direction"
    @State private var direction: String = ""
    
    @State private var cameraRollSheetPresented = false
    @State private var importRecipePresented = false
    @State private var selectedImage: UIImage?
    
    @State private var urlString: String = ""
    
    @State var isImportingRecipe: Bool = false
    
    @State private var presentRecipeText = false
    
    
    @State private var editingIngredientIndex: Int?
    @State private var editingDirectionIndex: Int?

        
    var body: some View {
        VStack {
            if recipe.isImportingFromURL && !recipe.invalidURL {
                UIControls.Loading()
                    .padding()
                
                Spacer()
            }
            else if recipe.importFromURL {
                VStack(spacing: 0) {
                    HStack {
                        Text("Import from:")
                        
                        TextField("URL", text: $urlString, onCommit: {
                            transcribeWeb()
                        })
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
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                transcribeWeb()
                            }
                        }) {
                            Text("Import")
                        }
                    }
                    .padding()
                }
                .formed()
            }
            else {
                if presentRecipeText {
                    RecipeTextView()
                }
                else {
                    EditableRecipe()
                        .onAppear {
                            setRecipe()
                        }
                }
            }
        }
        .background(formBackgroundColor().edgesIgnoringSafeArea(.all))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading:
                Button(action: {
                    withAnimation {
                        if recipe.isCreatingRecipe() {
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
            ,
            trailing:
                HStack(spacing: 20) {
                    if recipe.recipeText != nil {
                        Button(action: {
                            withAnimation {
                                // save stuff
                                unfocusEditable()
                                presentRecipeText.toggle()
                            }
                        })
                        {
                            if presentRecipeText {
                                Image(systemName: "doc.plaintext.fill")
                            }
                            else {
                                Image(systemName: "doc.plaintext")
                            }
                        }
                    }
                    
                    if recipe.isCreatingRecipe() {
                        Menu {
                            Text("Import Recipe")
                            
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
            
                
                    Button(action: {
                        saveRecipe()
                        unfocusEditable()
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
                .foregroundColor(mainColor())
        )
    }
    
    private func transcribeWeb() {
        if urlString != "" {
            recipe.invalidURL = false
            recipe.transcribeRecipe(fromUrlString: urlString)
        }
        else {
            recipe.invalidURL = true
        }
    }
    
    private func transcribeImage() {
        guard let inputImage = selectedImage else { return }
        recipe.transcribeRecipe(fromImage: inputImage)
        isImportingRecipe = true
    }
    
    private func setRecipe() {
        if name == "" {
            name = recipe.name
            servings = recipe.servings.toString()
        }
    }
    
    // tODO: saave should be not on main thread
    private func saveRecipe() {
        recipe.tempIngredients = recipe.tempIngredients.filter { (ingredient) -> Bool in
            ingredient.ingredientString != ""
        }
        recipe.tempDirections = recipe.tempDirections.filter { (direction) -> Bool in
            direction.direction != ""
        }
        servingsFieldMissing = false
        if name == "" {
            nameFieldMissing = true
        }
        if recipe.tempIngredients.count == 0 {
            ingredientsFieldMissing = true
        }
        if recipe.tempDirections.count == 0 {
            directionsFieldMissing = true
        }
        if servings.toInt() < 1 {
            servingsFieldMissing = true
        }
        if !fieldMissing {
            if recipe.isCreatingRecipe() {
                if let createdRecipe = category.createRecipe(name: name, tempIngredients: recipe.tempIngredients, directions: recipe.tempDirections, images: recipe.tempImages, servings: servings) {
                    recipe.setRecipe(createdRecipe)
                }
                else {
                    print("error")
                }
            }
            else {
                withAnimation {
                    isEditingRecipe = false
                }
                recipe.updateRecipe(withId: recipe.id, name: name, tempIngredients: recipe.tempIngredients, directions: recipe.tempDirections, images: recipe.tempImages, servings: servings, categoryId: recipe.categoryId)
            }
            // TODO: have page shrink up into square and be brought to the recipe collection view showing the new recipe
            // flying into place
            withAnimation {
                isEditingRecipe = false
            }
        }
        else {
            presentErrorAlert = true
        }
    }
    
    private func addDirection() {
        if direction != directionPlaceholder {
            newDirectionFieldMissing = false
            recipe.addTempDirection(direction)
            direction = directionPlaceholder
        }
        else {
            newDirectionFieldMissing = true
        }
        if recipe.tempDirections.count > 0 {
            directionsFieldMissing = false
        }
    }
    
    private func addIngredient() {
        if ingredient != "" {
            newIngredientFieldMissing = false
            recipe.addTempIngredient(ingredient)
            ingredient = ingredientPlaceholder
        }
        else {
            newIngredientFieldMissing = true
        }
        if recipe.tempIngredients.count > 0 {
            ingredientsFieldMissing = false
        }
    }
    
//    func unfocusEditable() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
//    }
    
    @ViewBuilder
    func EditableRecipe() -> some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading) {
                        TextField("Recipe Name", text: $name, onEditingChanged: { isEditing in
                            if name != "" {
                                withAnimation {
                                    nameFieldMissing = false
                                }
                            }
                        })
                        .recipeTitle()
                        
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
                            .textCase(.uppercase)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        VStack {
                            Picker(selection: $servings, label:
                                    HStack {
                                        Text("Servings: \(servings)")
                                            .textCase(.uppercase)
                                            .font(.subheadline)
                                
                                        Image(systemName: "chevron.down")
                                    }
                                    .foregroundColor(servingsFieldMissing && servings == "0" ? .red : Color.gray)
                            )
                            {
                                ForEach(1..<101, id: \.self) { num in
                                    Text("\(num.toString())").tag(num.toString())
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                    .formHeader()
                            
                    VStack(spacing: 0) {
                        ForEach(0..<recipe.tempIngredients.count, id: \.self) { index in
                            HStack {
                                EditableIngredient(index: index, editingIndex: $editingIngredientIndex)
                                    .environmentObject(recipe)
                            }
                            .deletable(isDeleting: true, onDelete: {
                                withAnimation {
                                    recipe.removeTempIngredient(at: index)
                                }
                            })
                            .formSectionItem(padding: false)
                            .simultaneousGesture(
                                TapGesture(count: 1).onEnded { _ in
                                    unfocusEditable()
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
                                        RecipeControls.ReadIngredientText(ingredient)
                                            .padding()

                                        Spacer()
                                    }
                                    .opacity(0)
                                    
                                    VStack {
                                        Spacer()

                                        PlaceholderTextView(placeholderText: ingredientPlaceholder, textBinding: $ingredient, isFirstResponder: false)
                                            .onChange(of: ingredient) { value in
                                                if value.hasSuffix("\n") {
                                                    ingredient.removeLast(1)
                                                    withAnimation {
                                                        // unfocus
                                                        unfocusEditable()
                                                        addIngredient()
                                                    }
                                                }
                                            }

                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                                .autocapitalization(.none)
                                
                                UIControls.AddButton(action: {
                                    withAnimation {
                                        addIngredient()
                                    }
                                })
                            }
                            .formSectionItem(padding: false)
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
                            .font(.subheadline)
                        
                        Spacer()
                    }
                    .formHeader()
                    
                    VStack(spacing: 0) {
                        ForEach(0..<recipe.tempDirections.count, id: \.self) { index in
                            HStack(alignment: .center, spacing: 20) {
                                Text("\(index + 1)")
                                
                                EditableDirection(index: index, editingIndex: $editingDirectionIndex)
                                    .environmentObject(recipe)
                            }
                            .deletable(isDeleting: true, onDelete: {
                                withAnimation {
                                    recipe.removeTempDirection(at: index)
                                }
                            })
                            .formSectionItem(padding: false)
                            .simultaneousGesture(
                                TapGesture(count: 1).onEnded { _ in
                                    unfocusEditable()
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
                                Text("\(recipe.tempDirections.count + 1)")
                                
                                ZStack {
                                    HStack(spacing: 0) {
                                        RecipeControls.ReadDirection(direction: direction)
                                            .padding()

                                        Spacer()
                                    }
                                    .opacity(0)
                                    
                                    VStack {
                                        Spacer()

                                        PlaceholderTextView(placeholderText: directionPlaceholder, textBinding: $direction, isFirstResponder: false)
                                            .onChange(of: direction) { value in
                                                if value.hasSuffix("\n") {
                                                    direction.removeLast(1)
                                                    withAnimation {
                                                        // unfocus
                                                        unfocusEditable()
                                                        addDirection()
                                                    }
                                                }
                                            }

                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                                .autocapitalization(.none)

                                UIControls.AddButton(action: {
                                    withAnimation {
                                        addDirection()
                                    }
                                })
                            }
                            .formSectionItem(padding: false)
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
            .gesture(editingIngredientIndex != nil || editingDirectionIndex != nil ? TapGesture(count: 1).onEnded {
                withAnimation {
                    editingIngredientIndex = nil
                    editingDirectionIndex = nil
                }
            } : nil)
        }
    }
    
    func getErrorMessages() -> String {
        var errorMessage = ""
        if nameFieldMissing {
            errorMessage.append(nameFieldMissingMessage)
        }
        if newIngredientFieldMissing {
            errorMessage.append(newIngredientFieldMissingMessage)
        }
        if newDirectionFieldMissing {
            errorMessage.append(newDirectionFieldMissingMessage)
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
