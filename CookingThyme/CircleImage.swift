//
//  CircleImage.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/18/20.
//

import SwiftUI

struct CircleImage: View {
    var isSelected: Bool
    var uiImage: UIImage?
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        VStack {
            if uiImage != nil {
                Image(uiImage: uiImage!)
                    .scaleEffect(ImageHandler.getZoomScale(uiImage, in: CGSize(width: width, height: height)))
                    .frame(width: width, height: height, alignment: .center)
                    .clipped()
            }
            else {
                Circle()
                    .foregroundColor(getCategoryColor())
            }
        }
    }
    
    func getCategoryColor() -> Color {
        return Color.green.opacity(isSelected ? 1 : 0.5)
    }
}

//struct CircleImage_Previews: PreviewProvider {
//    static var previews: some View {
//        CircleImage(width: 60, height: 60)
//    }
//}
