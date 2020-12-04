//
//  ImageView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/3/20.
//

import SwiftUI
import Combine

struct ImageView: View {
    @ObservedObject var imageHandler: ImageHandler
    
    @State private var confirmBackgroundPaste = false
    @State private var explainBackgroundPaste = false
    
    var body: some View {
        
        VStack {
            GeometryReader { geometry in
                HStack {
                OptionalImage(uiImage: imageHandler.image)
                    .scaleEffect(imageHandler.zoomScale)
    //                .offset(panOffset)
                }
                .onReceive(imageHandler.$image.dropFirst()) { image in
                    withAnimation {
                        zoomToFit(image, in: geometry.size)
                    }
                }
            }
            
            Button(action: {
                if UIPasteboard.general.url != nil {
                    confirmBackgroundPaste = true
                } else {
                    explainBackgroundPaste = true
                }
            }) {
                Image(systemName: "doc.on.clipboard").imageScale(.large)
                    .alert(isPresented: $explainBackgroundPaste) {
                        Alert(title: Text("Paste Image"),
                              message: Text("Copy the URL of an image to the clipboard and tap this button to add the image"),
                              dismissButton: .default(Text("Ok")))
                    }
            }
            .alert(isPresented: $confirmBackgroundPaste) {
                Alert(title: Text("Paste Image"),
                      message: Text("Add this image?"),
                      primaryButton: .default(Text("Ok")) {
                        imageHandler.addImage(url: UIPasteboard.general.url)
                      },
                      secondaryButton: .cancel())
            }
        }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let horizontalZoom = size.width / image.size.width
            let verticalZoom = size.height / image.size.height

            imageHandler.zoomScale = min(horizontalZoom, verticalZoom)
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(imageHandler: ImageHandler())
    }
}
