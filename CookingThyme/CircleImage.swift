//
//  CircleImage.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/18/20.
//

import SwiftUI

struct CircleImage: View {
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
        return Color.white
        
//        let randomNum = Double.random(in: 0..<1)
//        switch(randomNum) {
//        case _ where randomNum < 0.2:
//            return Color.yellow
//        case _ where randomNum < 0.4:
//            return Color.blue
//        case _ where randomNum < 0.6:
//            return Color.red
//        case _ where randomNum < 0.8:
//            return Color.pink
//        case _ where randomNum < 1:
//            return Color.orange
//        default:
//            return Color.white
//        }
    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        CircleImage(width: 60, height: 60)
    }
}
