//
//  EditPhotoMenu.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/25/21.
//

import SwiftUI

struct EditPhotoMenu: ViewModifier {
    var onPaste: () -> Void
    var loadImage: (UIImage) -> Void
    
    @State private var presentPasteAlert = false
    @State private var confirmPaste = false
    @State private var explainPaste = false

    @State private var editPhotoSheetPresented = false
    @State private var cameraRollSheetPresented = false
    @State private var selectedImage: UIImage?
    
    func body(content: Content) -> some View {
        Menu {
            Text("Add Photo")
            
            Button(action: {
                cameraRollSheetPresented = true
            }) {
                Label("From camera roll", systemImage: "photo.on.rectangle")
            }
            
            Button(action: {
                presentPasteAlert = true
                if UIPasteboard.general.url != nil {
                    confirmPaste = true
                } else {
                    explainPaste = true
                }
            }) {
                Label("Paste", systemImage: "doc.on.clipboard")
            }
            
            Button(action: {}) {
                Text("Cancel")
            }
        } label: {
            content
        }
        .sheet(isPresented: $cameraRollSheetPresented, onDismiss: setImage) {
            ZStack {
                NavigationView {
                }
                .background(formBackgroundColor().edgesIgnoringSafeArea(.all))
                
                ImagePicker(image: self.$selectedImage)
            }
        }
        .alert(isPresented: $presentPasteAlert) {
            if confirmPaste {
                return Alert(title: Text("Add Image"),
                      message: Text(""),
                      primaryButton: .default(Text("Ok")) {
                        onPaste()
                      },
                      secondaryButton: .cancel())
            }
            return Alert(title: Text("Paste Image"),
                  message: Text("Copy the URL of an image to the clipboard and tap this button to add the image"),
                  dismissButton: .default(Text("Ok")))
        }
    }
    
    func setImage() {
        guard let inputImage = selectedImage else { return }
        loadImage(inputImage)
    }

}

//struct EditPhotoMenu_Previews: PreviewProvider {
//    static var previews: some View {
//        EditPhotoMenu()
//    }
//}

extension View {
    func editPhotoMenu(onPaste: @escaping () -> Void, loadImage: @escaping (UIImage) -> Void) -> some View {
        modifier(EditPhotoMenu(onPaste: onPaste, loadImage: loadImage))
    }
}
