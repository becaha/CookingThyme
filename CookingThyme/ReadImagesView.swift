//
//  ReadImagesView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/10/20.
//

import SwiftUI

// for Web Recipe Images
struct ReadImagesView: View {
    var uiImages: [UIImage]

    var body: some View {
        VStack(alignment: .center) {
            HStack {
                GeometryReader { geometry in
                    HStack {
                        if uiImages.count > 0 {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(0..<uiImages.count, id: \.self) { index in
                                        if index < uiImages.count {
                                            Image(uiImage: uiImages[index])
                                                .scaleEffect(ImageHandler.getZoomScale(uiImages[index], in: CGSize(width: geometry.size.width/2, height: geometry.size.height)))
                                                .frame(width: geometry.size.width/2, height: geometry.size.height, alignment: .center)
                                                .clipped()
                                                .border(Color.black, width: 3)
                                        }
                                    }
                                }
                                .frame(minWidth: geometry.size.width)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .frame(height: 150)
    }
}
