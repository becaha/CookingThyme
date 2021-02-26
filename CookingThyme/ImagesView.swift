//
//  ImageView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/3/20.
//

import SwiftUI
import Combine

struct ImagesView: View {
    @EnvironmentObject var recipe: RecipeVM
    var isEditing: Bool = true
    var widthOffset: CGFloat = 6
    @State var pictureWidth: CGFloat = 200
    @State var pictureHeight: CGFloat = 150
    
//    init(isEditing: Bool) {
//        self.isEditing = isEditing
//        print("")
//    }
    
    var body: some View {
        
        VStack(alignment: .center) {
            VStack {
                GeometryReader { geometry in
                    HStack {
                        if recipe.images.count > 0 {
                            ScrollableImagesView(width: geometry.size.width, height: geometry.size.height, isEditing: isEditing)
                        }
                        else if isEditing {
                            VStack(alignment: .center) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color("ButtonLight"))
                                    
                                    VStack {
                                        ZStack {
                                            Circle()
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(buttonColor())
                                                .shadow(color: buttonBorder(), radius: 1)

                                            Image(systemName: "plus")
                                                .font(Font.subheadline.weight(.bold))
                                                .foregroundColor(mainColor())
                                        }
                                        
                                        Text("Add Photo")
                                            .bold()
                                    }
                                    .border(Color.black, width: 3.0, isDashed: true)
                                }
                                .frame(width: pictureWidth, height: pictureHeight)
                                .editPhotoMenu(onPaste: paste, loadImage: loadImage)
                            }
                            .background(formBackgroundColor())
                            .padding([.bottom, .horizontal])
                            .frame(width: geometry.size.width, height: 150)
                        }
                    }
                    .onAppear {
                        pictureWidth = min(geometry.size.width/2 - widthOffset, geometry.size.height * (4.0/3.0))
                        pictureHeight = min(pictureWidth * (3.0/4.0), geometry.size.height)
                    }
                }
                .padding(.bottom)
                .frame(height: 150)

                if isEditing && recipe.images.count > 0 {
                    UIControls.AddButton(withLabel: "Add Photo") {}
                        .editPhotoMenu(onPaste: paste, loadImage: loadImage)
                    .padding(.top, 0)
                }
            }
        }
        .padding(.horizontal)
    }
    
    // loads image selected from camera roll
    func loadImage(_ selectedImage: UIImage) {
        withAnimation {
            recipe.addTempImage(uiImage: selectedImage)
        }
    }
    
    func paste() {
        recipe.addTempImage(url: UIPasteboard.general.url)
    }
}
