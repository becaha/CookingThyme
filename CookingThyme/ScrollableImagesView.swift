//
//  ScrollableImagesView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/3/20.
//

import SwiftUI

// TODO make images scrollable by left/right arrows
struct ScrollableImagesView: View {
    @EnvironmentObject var recipe: RecipeVM
    
    var uiImages: [UIImage]
    var width: CGFloat
    var height: CGFloat
    var isEditing: Bool
    
    init(uiImages: [UIImage], width: CGFloat, height: CGFloat, isEditing: Bool) {
        self.uiImages = uiImages
        self.width = width
        self.height = height
        self.isEditing = isEditing
    }

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0..<uiImages.count, id: \.self) { index in
                    if index < uiImages.count {
                        ZStack {
                            if isEditing {
                                Button(action: {
                                    recipe.removeTempImage(at: index)
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
                        
                            Image(uiImage: uiImages[index])
                                .scaleEffect(ImageHandler.getZoomScale(uiImages[index], in: CGSize(width: width/2, height: height)))
                                .frame(width: width/2, height: height, alignment: .center)
                                .clipped()
                                .border(Color.black, width: 3)
                        }
                    }
                }
            }
            .frame(minWidth: width)
        }
    }
    
}

