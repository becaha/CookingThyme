//
//  PasteButton.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/21/21.
//

import SwiftUI

struct PasteButton: View {
    @State private var presentPasteAlert = false
    @State private var confirmPaste = false
    @State private var explainPaste = false
    var confirmPasteAlert: Alert
    var explainPasteAlert: Alert
    
    var body: some View {
        Button(action: {
            presentPasteAlert = true
            if UIPasteboard.general.url != nil {
                confirmPaste = true
            } else {
                explainPaste = true
            }
        }) {
            Text("Paste")
        }
        .alert(isPresented: $presentPasteAlert) {
            if confirmPaste {
                return confirmPasteAlert
            }
            return explainPasteAlert
        }
    }
}

struct PasteButton_Previews: PreviewProvider {
    static var previews: some View {
        PasteButton(
            confirmPasteAlert:
                Alert(title: Text("Add Image"),
                     message: Text(""),
                     primaryButton: .default(Text("Ok")) {
//                                               recipe.addTempImage(url: UIPasteboard.general.url)
                     },
                     secondaryButton: .cancel()
                ),
            explainPasteAlert:
                Alert(title: Text("Paste Image"),
                     message: Text("Copy the URL of an image to the clipboard and tap this button to add the image"),
                     dismissButton: .default(Text("Ok"))
                )
        )
    }
}
