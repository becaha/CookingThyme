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
    @ObservedObject var imageHandler = ImageHandler()
    
    @State private var confirmBackgroundPaste = false
    @State private var explainBackgroundPaste = false
    
    var body: some View {
        
        VStack {
            HStack {
                GeometryReader { geometry in
                    HStack {
                        if imageHandler.image != nil {
                            OptionalImage(uiImage: imageHandler.image)
                                .scaleEffect(imageHandler.zoomScale)
                        }
                        else {
                            VStack {
                                Button(action: {
                                    if UIPasteboard.general.url != nil {
                                        confirmBackgroundPaste = true
                                    } else {
                                        explainBackgroundPaste = true
                                    }
                                }) {
                                    Image(systemName: "doc.on.clipboard").imageScale(.large)
                                        .alert(isPresented: $explainBackgroundPaste) {
                                            Alert(title: Text("Paste Image"),
                                                  message: Text("Copy the URL of an image to the clipboard and tap this button to add the image"),
                                                  dismissButton: .default(Text("Ok")))
                                        }
                                }
                                .alert(isPresented: $confirmBackgroundPaste) {
                                    Alert(title: Text("Paste Image"),
                                          message: Text("Add this image?"),
                                          primaryButton: .default(Text("Ok")) {
                                            imageHandler.addImage(url: UIPasteboard.general.url)
                                          },
                                          secondaryButton: .cancel())
                                }
                                .padding()
                                
                                Text("Add Photo")
                                    .padding(.top, 0)
                            }
                            .padding()
                            .border(Color.black, width: 3.0, isDashed: true)
                        }
                    }
                    .frame(width: geometry.size.width/2, height: geometry.size.height, alignment: .center)
                    .clipped()
                    .border(Color.black, width: imageHandler.image != nil ? 3 : 0)
                    .position(x: geometry.size.width/2, y: geometry.size.height/2)
                    .onReceive(imageHandler.$image.dropFirst()) { image in
                        withAnimation {
                            imageHandler.zoomToFit(image, in: CGSize(width: geometry.size.width/2, height: geometry.size.height))
                        }
                    }
                }
            }
            .padding()
        }
        .frame(minHeight: 150)
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            Section(header: Text("Photos")) {
                ImageView()
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
