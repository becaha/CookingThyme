//
//  ScrollableImagesView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/3/20.
//

import SwiftUI

// TODO: image loading, viewe doesnt update to loading only to new image

// TODO: in edit mode allow drag ordering of the images
// TODO: make images scrollable by left/right arrows
struct ScrollableImagesView: View {
    @EnvironmentObject var recipe: RecipeVM
    
    var width: CGFloat
    var height: CGFloat
    var isEditing: Bool
    var borderWidth: CGFloat = 3
    var widthOffset: CGFloat = 6
    var pictureWidth: CGFloat
    var pictureHeight: CGFloat
    
    @State var imagesCount = 0

    
    init(width: CGFloat, height: CGFloat, isEditing: Bool) {
        self.width = width
        self.height = height
        self.isEditing = isEditing
        self.pictureWidth = width / 2 - widthOffset //min(width/2 - widthOffset, height * (4.0/3.0))
        self.pictureHeight = height //min(pictureWidth * (3.0/4.0), height)
    }

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0..<imagesCount, id: \.self) { index in
                    if recipe.imageHandler.images[index] == nil {
                        VStack {
                            Spacer()

                            UIControls.Loading()

                            Spacer()
                        }
                        .frame(width: pictureWidth, height: pictureHeight, alignment: .center)
                        .border(borderColor(), width: borderWidth)
                    }
                    else if index < recipe.imageHandler.images.count, recipe.imageHandler.images[index] != nil {
                        ZStack {
                            if isEditing {
                                Button(action: {
                                    withAnimation {
                                        recipe.removeTempImage(at: index)
                                    }
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 40, height: 40)
                                            .opacity(0.8)

                                        Circle()
                                            .stroke(borderColor())
                                            .frame(width: 40, height: 40)

                                        Image(systemName: "trash")
                                    }
                                }
                                .zIndex(1)
                            }

                            Image(uiImage: recipe.imageHandler.images[index]!)
                                .scaleEffect(ImageHandler.getZoomScale(recipe.imageHandler.images[index]!, in: CGSize(width: pictureWidth, height: pictureHeight)))
                                .frame(width: pictureWidth, height: pictureHeight, alignment: .center)
                                .clipped()
                                .border(borderColor(), width: borderWidth)
                                .animation(.easeInOut(duration: 1.0))
                            
                        }
                    }
                }
            }
            .frame(minWidth: width)
        }
        .onAppear {
            imagesCount = recipe.images.count
        }
        .onChange(of: recipe.imageHandler.images, perform: {
            images in
            imagesCount = images.count
        })
        .frame(height: height)
    }
    
}

