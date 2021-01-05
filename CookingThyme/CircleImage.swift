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
    var image: UIImage?
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        VStack {
            if image != nil {
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
        Image(uiImage: image!)
            .scaleEffect(ImageHandler.getZoomScale(image!, in: CGSize(width: width, height: height)))
            .frame(width: width, height: height, alignment: .center)
            .clipShape(Circle())
    }
    
//    func getImage() -> UIImage? {
//        let name = category.name
//        return category.imageHandler.image
//    }
    
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
