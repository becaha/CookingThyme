//
//  ScrollableImagesView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/3/20.
//

import SwiftUI

// TODO: image in recipe in landscape
// TODO: image loading
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
    
    init(uiImages: [Int: UIImage], width: CGFloat, height: CGFloat, isEditing: Bool) {
        self.uiImages = uiImages
        self.width = width
        self.height = height
        self.isEditing = isEditing
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
                                            .stroke(Color.black)
                                            .frame(width: 40, height: 40)

                                        Image(systemName: "trash")
                                    }
                                }
                                .zIndex(1)
                            }
                        
                            Image(uiImage: uiImages[index]!)
                                .scaleEffect(ImageHandler.getZoomScale(uiImages[index]!, in: CGSize(width: width/2 - widthOffset, height: height)))
                                .frame(width: width/2 - widthOffset, height: height, alignment: .center)
                                .clipped()
                                .border(Color.black, width: borderWidth)
                        }
                    }
                }
            }
            .frame(minWidth: width)
        }
    }
    
}

