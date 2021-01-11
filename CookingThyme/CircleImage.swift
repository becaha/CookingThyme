//
//  CircleImage.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/18/20.
//

import SwiftUI

// TODO: why does this appear so many times
// TODO: transition which animation?
struct CircleImage: View {
    @EnvironmentObject var category: RecipeCategoryVM
    var width: CGFloat
    var height: CGFloat
    
    var isLoading: Bool {
        return category.imageHandler.loadingImages && category.imageHandler.images.count == 0
    }
    
    @State var opacity: Double = 0

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .foregroundColor(getCategoryColor())
                
                if category.imageHandler.images.count > 0 {
                    Image(uiImage: category.imageHandler.images[0])
                        .scaleEffect(ImageHandler.getZoomScale(category.imageHandler.images[0], in: CGSize(width: width, height: height)))
                        .frame(width: width, height: height, alignment: .center)
                        .clipShape(Circle())
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 1.5)) {
                                self.opacity = 1
                            }
                        }
                }
            }
        }
    }
    
    func getCategoryColor() -> Color {
//        return Color.green.opacity(isSelected ? 1 : 0.5)
        return Color.green.opacity(0.8)
    }
}

//struct CircleImage_Previews: PreviewProvider {
//    static var previews: some View {
//        CircleImage(width: 60, height: 60)
//    }
//}
