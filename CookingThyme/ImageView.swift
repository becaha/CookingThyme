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
            GeometryReader { screenGeometry in
                HStack {
                    GeometryReader { geometry in
                        HStack {
                            OptionalImage(uiImage: imageHandler.image)
                                .scaleEffect(imageHandler.zoomScale)
                        }
                        .frame(width: geometry.size.width/2, height: geometry.size.height, alignment: .center)
                        .clipped()
                        .border(Color.black, width: 5.0)
                        .position(x: geometry.size.width/2, y: geometry.size.height/2)
                        .onReceive(imageHandler.$image.dropFirst()) { image in
                            withAnimation {
                                imageHandler.zoomToFit(image, in: CGSize(width: geometry.size.width/2, height: geometry.size.height))
                            }
                        }
                    }
                }
                .padding()
                .frame(width: screenGeometry.size.width, height: screenGeometry.size.height/4)
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
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(imageHandler: ImageHandler())
    }
}
