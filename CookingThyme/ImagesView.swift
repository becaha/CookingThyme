//
//  ImageView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/3/20.
//

import SwiftUI
import Combine

struct ImagesView: View {
    @EnvironmentObject var recipe: RecipeVM
    var isEditing: Bool = true
    
    @State private var presentPasteAlert = false
    @State private var confirmPaste = false
    @State private var explainPaste = false

    @State private var editPhotoSheetPresented = false
    @State private var cameraRollSheetPresented = false
    @State private var selectedImage: UIImage?
    
    private var isLoading: Bool {
        return recipe.imageHandler.loadingImages
    }
    
    var body: some View {
        
        VStack(alignment: .center) {
            if isLoading {
                UIControls.Loading()
            }
            else {
                VStack {
                    GeometryReader { geometry in
                        HStack {
                            if recipe.imageHandler.images.count > 0 {
                                ScrollableImagesView(uiImages: recipe.imageHandler.images, width: geometry.size.width, height: geometry.size.height, isEditing: isEditing)
                            }
                            else if isEditing {
                                Button(action: {
                                    editPhotoSheetPresented = true
                                }) {
                                    VStack(alignment: .center) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.white)
                                                
                                            
                                            VStack {
                                                ZStack {
                                                    Circle()
                                                        .frame(width: 25, height: 25)
                                                        .foregroundColor(.white)
                                                        .shadow(radius: 1)

                                                    Image(systemName: "plus")
                                                        .font(Font.subheadline.weight(.bold))
                                                        .foregroundColor(mainColor())
                                                }
                                                
                                                Text("Add Photo")
                                                    .bold()
                                            }
                                            .border(Color.black, width: 3.0, isDashed: true)
                                        }
                                        .frame(width: geometry.size.width/2)
                                    }
                                    .background(formBackgroundColor())
                                    .frame(width: geometry.size.width)
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(height: 150)

                    if isEditing && recipe.imageHandler.images.count > 0 {
                        UIControls.AddButton(withLabel: "Add Photo") {
                            editPhotoSheetPresented = true
                        }
                        .padding(.top, 0)
                    }
                }
            }
        }
        .padding(.horizontal)
        .actionSheet(isPresented: $editPhotoSheetPresented, content: {
            ActionSheet(title: Text("Add photo"), message: nil, buttons:
                [
                    .default(Text("Pick from camera roll"), action: {
                        cameraRollSheetPresented = true
                    }),
                    .default(Text("Paste"), action: {
                        presentPasteAlert = true
                        if UIPasteboard.general.url != nil {
                            confirmPaste = true
                        } else {
                            explainPaste = true
                        }
                    }),
                    .cancel()
                ])
        })
        .sheet(isPresented: $cameraRollSheetPresented, onDismiss: loadImage) {
            ImagePicker(image: self.$selectedImage)
        }
        .alert(isPresented: $presentPasteAlert) {
            if confirmPaste {
                return Alert(title: Text("Add Image"),
                      message: Text(""),
                      primaryButton: .default(Text("Ok")) {
                        recipe.addTempImage(url: UIPasteboard.general.url)
                      },
                      secondaryButton: .cancel())
            }
            return Alert(title: Text("Paste Image"),
                  message: Text("Copy the URL of an image to the clipboard and tap this button to add the image"),
                  dismissButton: .default(Text("Ok")))
        }
    }
    
    // loads image selected from camera roll
    func loadImage() {
        withAnimation {
            guard let inputImage = selectedImage else { return }
            recipe.addTempImage(uiImage: inputImage)
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
        ImagesView(isEditing: true)
            .environmentObject(RecipeVM(
                recipe: Recipe(
                    name: "Water",
                    ingredients: [
                        Ingredient(name: "water", amount: 1.05, unitName: UnitOfMeasurement.cup),
                        Ingredient(name: "water", amount: 2.1, unitName: UnitOfMeasurement.cup),
                        Ingredient(name: "water", amount: 1.3, unitName: UnitOfMeasurement.cup),
                        Ingredient(name: "water", amount: 1.8, unitName: UnitOfMeasurement.cup),
                        Ingredient(name: "water", amount: 1.95, unitName: UnitOfMeasurement.cup)
                    ],
                    directions: [
                        Direction(step: 1, recipeId: 1, direction: "Fetch a pail of water from the wishing well in the land of the good queen Casandra"),
                        Direction(step: 2, recipeId: 1, direction: "Bring back the pail of water making sure as to not spill a single drop of it"),
                        Direction(step: 3, recipeId: 1, direction: "Pour yourself a glass of nice cold water")],
                    images: [RecipeImage](),
                    servings: 1),
                category: RecipeCategoryVM(category: RecipeCategory(name: "All", recipeCollectionId: 1), collection: RecipeCollectionVM(collection: RecipeCollection(id: 0, name: "Becca")))
        ))
        }
        .background(Color.blue)
        .foregroundColor(mainColor())
    }
}
