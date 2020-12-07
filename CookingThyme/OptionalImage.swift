//
//  OptionalImage.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/3/20.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    init(uiImage: UIImage?) {
        self.uiImage = uiImage
    }

    var body: some View {
        if let image = uiImage {
            Image(uiImage: image)
                .border(Color.black, width: 3)
        }
    }
}