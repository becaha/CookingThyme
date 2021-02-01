//
//  EditRecipeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/17/20.
//

import SwiftUI

// TODO: have cursor go to next item in list after one is entered https://www.hackingwithswift.com/forums/100-days-of-swiftui/jump-focus-between-a-series-of-textfields-pin-code-style-entry-widget/765
// tODO: no scroll in edtiable ingredient/direction
struct EditRecipeView: View {
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var category: RecipeCategoryVM
    @Binding var isEditingRecipe: Bool
    @EnvironmentObject var recipe: RecipeVM
            
    private var fieldMissing: Bool {
        return nameFieldMissing || newIngredientFieldMissing || newDirectionFieldMissing || ingredientsFieldMissing || directionsFieldMissing || servingsFieldMissing
    }
    @State private var nameFieldMissing = false
    @State private var newIngredientFieldMissing = false
    @State private var newDirectionFieldMissing = false
    @State private var ingredientsFieldMissing = false
    @State private var directionsFieldMissing = false
    @State private var servingsFieldMissing = false
            
    @State private var name: String = ""
    @State private var servings: String = "100"
    @State private var ingredientPlaceholder = ""
    @State private var ingredient: String = ""
    @State private var directionPlaceholder = ""
    @State private var direction: String = ""
    
    @State private var cameraRollSheetPresented = false
    @State private var importRecipePresented = false
    @State private var selectedImage: UIImage?
    
    @State private var importFromURL = false
    @State private var urlString: String = ""
    
    @State var isImportingRecipe: Bool = false
    
    @State private var presentRecipeText = false
        
    var body: some View {
        ScrollView(.vertical) {
            if importFromURL {
                VStack {
                    HStack {
                        Text("Import from:")
                        
                        TextField("URL", text: $urlString, onCommit: {
                            transcribeWeb()
                        })
                    }
                    .formItem()
                    
                    HStack {
                        Button(action: {
                            withAnimation {
                                importFromURL = false
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
            else if recipe.isImportingFromURL {
                UIControls.Loading()
                    .padding()
            }
            else {
                if presentRecipeText {
                    RecipeTextView(isPresented: $presentRecipeText)
                }
                else {
                    EditableRecipe()
                        .onAppear {
                            setRecipe()
                        }
                }
            }
        }
        .background(formBackgroundColor())
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
                    // TODO: a side view that slides in insteead of a sheet on a sheet
                    // tODO: popover to explain icon
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
                                    importFromURL = true
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
                        .sheet(isPresented: $cameraRollSheetPresented, onDismiss: transcribeImage) {
                            ImagePicker(image: self.$selectedImage)
                        }
                    }
                
                    Button(action: {
                        saveRecipe()
                        unfocusEditable()
                    })
                    {
                        Text("Done")
                    }
                }
                .foregroundColor(mainColor())
        )
    }
    
    private func transcribeWeb() {
        if urlString != "" {
            recipe.transcribeRecipe(fromUrlString: urlString)
            importFromURL = false
        }
    }
    
    private func transcribeImage() {
        guard let inputImage = selectedImage else { return }
        recipe.transcribeRecipe(fromImage: inputImage)
        isImportingRecipe = true
    }
    
    private func setRecipe() {
        name = recipe.name
        servings = recipe.servings.toString()
//        recipe.popullateRecipeTemps()
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
    
    func unfocusEditable() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
    
    @ViewBuilder
    func EditableRecipe() -> some View {
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
                    
                    ErrorMessage("Must have a name.", isError: $nameFieldMissing, isCentered: true)
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
                        // TODO make serving size look like you need to choose it
                        Picker(selection: $servings, label:
                                HStack {
                                    Text("Serving Size: \(servings)")
                                        .textCase(.uppercase)
                                        .font(.subheadline)
                            
                                    Image(systemName: "chevron.down")
                                }
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
                            EditableIngredient(index: index)
                                .environmentObject(recipe)
                        }
                        .deletable(isDeleting: true, onDelete: {
                            withAnimation {
                                recipe.removeTempIngredient(at: index)
                            }
                        })
                        .formSectionItem()
                    }
                    .onDelete { indexSet in
                        indexSet.map{ $0 }.forEach { index in
                            recipe.removeTempIngredient(at: index)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            ZStack {
                                HStack(spacing: 0) {
                                    Text(ingredient)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .padding(.all, 8)
                                }

                                TextEditor(text: $ingredient)
                                    .onChange(of: ingredient) { value in
                                        if value.hasSuffix("\n") {
                                            ingredient.removeLast(1)
                                            withAnimation {
                                                addIngredient()
                                            }
                                        }
                                    }
                            }
                            .autocapitalization(.none)
                            
                            UIControls.AddButton(action: {
                                withAnimation {
                                    addIngredient()
                                }
                            })
                        }
                        .formSectionItem()
                    }
                }
                .formSection()
            
                VStack(alignment: .leading) {
                    ErrorMessage("Must fill in an ingredient slot", isError: $newIngredientFieldMissing)

                    ErrorMessage("Must have at least one ingredient", isError: $ingredientsFieldMissing)
                    
                    ErrorMessage("Must have a serving size", isError: $servingsFieldMissing)
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
                            
                            EditableDirection(index: index)
                                .environmentObject(recipe)
                        }
                        .deletable(isDeleting: true, onDelete: {
                            withAnimation {
                                recipe.removeTempDirection(at: index)
                            }
                        })
                        .formSectionItem()
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
                                    Text(direction)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .padding(.all, 8)
                                }

                                TextEditor(text: $direction)
                                    .onChange(of: direction) { value in
                                        if value.hasSuffix("\n") {
                                            direction.removeLast(1)
                                            withAnimation {
                                                addDirection()
                                            }
                                        }
                                    }
                            }
                            .autocapitalization(.none)

                            UIControls.AddButton(action: {
                                withAnimation {
                                    addDirection()
                                }
                            })
                        }
                        .formSectionItem()
                    }
                }
                .formSection()
            
                
                VStack {
                    Group {
                        ErrorMessage("Must fill in a direction", isError: $newDirectionFieldMissing)

                        ErrorMessage("Must have at least one direction", isError: $directionsFieldMissing)
                    }
                }
                .formFooter()
            }
        }
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
