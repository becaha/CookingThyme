//
//  CircleImage.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/18/20.
//

import SwiftUI

struct CircleImage: View {
    @EnvironmentObject var category: RecipeCategoryVM
    var width: CGFloat = 60
    var height: CGFloat = 60
    var strokeColor: Color = formBorderColor()
    
    var isLoading: Bool {
        return category.imageHandler.loadingImages && category.imageHandler.images.count == 0
    }
    
    @State var opacity: Double = 0

    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    Circle()
                        .fill(mainColor())
                    
                    if category.imageHandler.images.count > 0, category.imageHandler.images[0] != nil {
                        Image(uiImage: category.imageHandler.images[0]!)
                            .scaleEffect(ImageHandler.getZoomScale(category.imageHandler.images[0]!, in: CGSize(width: width, height: height)))
                            .frame(width: width, height: height, alignment: .center)
                            .clipShape(Circle())
                    }
                }
            }
            
            Circle()
                .stroke(strokeColor, lineWidth: 2)
        }
        .frame(width: width, height: height)
    }
    
    func getCategoryColor() -> Color {
        return mainColor()
    }
}
