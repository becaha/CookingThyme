//
//  ImageView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/3/20.
//

import SwiftUI
import Combine

struct ImageView: View {
    @EnvironmentObject var recipe: RecipeVM
    var isEditing: Bool = true
    
    @State private var confirmBackgroundPaste = false
    @State private var explainBackgroundPaste = false
    @State private var editPhotoSheetPresented = false
    @State private var cameraRollSheetPresented = false

    @State private var uiImage: UIImage?
    @State private var image: Image?
    
    private var isLoading: Bool {
        let image = recipe.imageHandler.image
        return recipe.imageHandler.imageURL != nil && recipe.imageHandler.image == nil
    }
    
    var body: some View {
        
        VStack(alignment: .center) {
            if isLoading {
                HStack {
                    Spacer()
                    
                    ProgressView()
                        .frame(alignment: .center)
                    
                    Spacer()
                }
            }
            else {
                ZStack {
                    if isEditing && recipe.imageHandler.image != nil {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                                .opacity(0.8)
                            
                            Circle()
                                .stroke(Color.black)
                                .frame(width: 40, height: 40)
                            
                            EditPhotoButton()
                        }
                        .zIndex(1)
                    }

                    GeometryReader { geometry in
                        HStack {
                            if recipe.imageHandler.image != nil {
                                OptionalImage(uiImage: recipe.imageHandler.image)
                                    .scaleEffect(recipe.imageHandler.zoomScale)
                                    .onAppear {
                                        recipe.imageHandler.zoomToFit(recipe.imageHandler.image, in: CGSize(width: geometry.size.width/2, height: geometry.size.height))
                                    }
                            }
                            else if isEditing {
                                VStack {
                                    EditPhotoButton()
                                        .padding(.bottom, 5)
                                    
                                    Text("Add Photo")
                                        .font(.subheadline)
                                        .padding(.top, 0)
                                }
                                .padding()
                                .border(Color.black, width: 3.0, isDashed: true)
                            }
                        }
                        .frame(width: geometry.size.width/2, height: geometry.size.height, alignment: .center)
                        .clipped()
                        .border(Color.black, width: recipe.imageHandler.image != nil ? 3 : 0)
                        .position(x: geometry.size.width/2, y: geometry.size.height/2)
                        .onReceive(recipe.imageHandler.$image.dropFirst()) { image in
                            withAnimation {
                                recipe.imageHandler.zoomToFit(image, in: CGSize(width: geometry.size.width/2, height: geometry.size.height))
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .frame(height: 150)
        .sheet(isPresented: $cameraRollSheetPresented, onDismiss: loadImage) {
            ImagePicker(image: self.$uiImage)
        }
        .alert(isPresented: $explainBackgroundPaste) {
            Alert(title: Text("Paste Image"),
                  message: Text("Copy the URL of an image to the clipboard and tap this button to add the image"),
                  dismissButton: .default(Text("Ok")))
        }
        .alert(isPresented: $confirmBackgroundPaste) {
            Alert(title: Text("Paste Image"),
                  message: Text(recipe.imageHandler.image != nil ? "Are you sure you want to replace your image?" : ""),
                  primaryButton: .default(Text("Ok")) {
                    recipe.addTempImage(url: UIPasteboard.general.url)
                  },
                  secondaryButton: .cancel())
        }
    }
    
    func loadImage() {
        guard let inputImage = uiImage else { return }
        recipe.addTempImage(uiImage: inputImage)
        image = Image(uiImage: inputImage)
    }
    
    @ViewBuilder
    func EditPhotoButton() -> some View {
        Button(action: {
            editPhotoSheetPresented = true
        }) {
            Image(systemName: "camera.circle").imageScale(.large)
        }
        .actionSheet(isPresented: $editPhotoSheetPresented, content: {
            ActionSheet(title: Text(""), message: nil, buttons:
                [
                    .default(Text("Pick from camera roll"), action: {
                        cameraRollSheetPresented = true
                    }),
                    .default(Text("Paste"), action: {
                        if UIPasteboard.general.url != nil {
                            confirmBackgroundPaste = true
                        } else {
                            explainBackgroundPaste = true
                        }
                    }),
                    .cancel()
                ])
        })
    }
    
    @ViewBuilder
    func PasteButton() -> some View {
        Button(action: {
            if UIPasteboard.general.url != nil {
                confirmBackgroundPaste = true
            } else {
                explainBackgroundPaste = true
            }
        }) {
            Image(systemName: "doc.on.clipboard").imageScale(.large)
        }
        .alert(isPresented: $explainBackgroundPaste) {
            Alert(title: Text("Paste Image"),
                  message: Text("Copy the URL of an image to the clipboard and tap this button to add the image"),
                  dismissButton: .default(Text("Ok")))
        }
        .alert(isPresented: $confirmBackgroundPaste) {
            Alert(title: Text("Paste Image"),
                  message: Text(recipe.imageHandler.image != nil ? "Are you sure you want to replace your image?" : ""),
                  primaryButton: .default(Text("Ok")) {
                    recipe.addTempImage(url: UIPasteboard.general.url)
                  },
                  secondaryButton: .cancel())
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            Section(header: Text("Photos")) {
                ImageView(isEditing: true)
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
        }
    }
}
