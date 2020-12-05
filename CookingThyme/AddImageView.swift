//
//  AddImageView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/4/20.
//

import SwiftUI

struct AddImageView: View {
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var image: Image?

    var body: some View {
        VStack {
            image
            
            Button(action: {
                self.showingImagePicker = true
            }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
}

struct AddImageView_Previews: PreviewProvider {
    static var previews: some View {
        AddImageView()
    }
}
