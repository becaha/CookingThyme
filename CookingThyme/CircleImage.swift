//
//  CircleImage.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/18/20.
//

import SwiftUI

struct CircleImage: View {
//    @EnvironmentObject var collection: RecipeCollectionVM
//    @EnvironmentObject var category: RecipeCategoryVM
//    var isSelected: Bool
    var images: [UIImage]
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        VStack {
            if images.count > 0 {
                CategoryImage()
            }
            else {
                Circle()
                    .foregroundColor(getCategoryColor())
            }
        }
    }
    
    @ViewBuilder
    func CategoryImage() -> some View {
        Image(uiImage: images[0])
            .scaleEffect(ImageHandler.getZoomScale(images[0], in: CGSize(width: width, height: height)))
            .frame(width: width, height: height, alignment: .center)
            .clipShape(Circle())
    }
    
    func getCategoryColor() -> Color {
//        return Color.green.opacity(isSelected ? 1 : 0.5)
        return Color.green.opacity(1)
    }
}

//struct CircleImage_Previews: PreviewProvider {
//    static var previews: some View {
//        CircleImage(width: 60, height: 60)
//    }
//}
