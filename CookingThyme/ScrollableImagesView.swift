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
    
    var uiImages: [Int: UIImage]
    var width: CGFloat
    var height: CGFloat
    var isEditing: Bool
    var borderWidth: CGFloat = 3
    var widthOffset: CGFloat = 6
    var pictureWidth: CGFloat
    var pictureHeight: CGFloat

    
    init(uiImages: [Int: UIImage], width: CGFloat, height: CGFloat, isEditing: Bool) {
        self.uiImages = uiImages
        self.width = width
        self.height = height
        self.isEditing = isEditing
        self.pictureWidth = min(width/2 - widthOffset, height * (4.0/3.0))
        self.pictureHeight = min(pictureWidth * (3.0/4.0), height)
    }

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                // uiImages.count
                ForEach(0..<(recipe.imageHandler.imagesCount ?? 0), id: \.self) { index in
                    if uiImages[index] == nil {
                        VStack {
                            Spacer()

                            UIControls.Loading()

                            Spacer()
                        }
                        .frame(width: pictureWidth, height: pictureHeight, alignment: .center)
                    }
                    else if index < uiImages.count, uiImages[index] != nil {
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

                            Image(uiImage: uiImages[index]!)
                                .scaleEffect(ImageHandler.getZoomScale(uiImages[index]!, in: CGSize(width: pictureWidth, height: height)))
                                .frame(width: pictureWidth, height: pictureHeight, alignment: .center)
                                .clipped()
                                .border(borderColor(), width: borderWidth)
                                .animation(.easeInOut(duration: 1.0))
                                .transition(.slide)
                            
                        }
                    }
                }
            }
            .frame(minWidth: width)
        }
        .frame(height: height)
    }
    
}

