//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct Test: View {
    var confirmAddIngredient = false
    @State var search = ""
    @State var commitCount = 0
    @State var commitedSearch = ""
    
    var body: some View {
        Menu {
            Text("Add Photo")
            
            Button(action: {
//                cameraRollSheetPresented = true
            }) {
                Text("From camera roll")
            }
            
            Button(action: {
//                presentPasteAlert = true
//                if UIPasteboard.general.url != nil {
//                    confirmPaste = true
//                } else {
//                    explainPaste = true
//                }
            }) {
                Label("Paste", systemImage: "doc.on.clipboard")
            }
            
            Button(action: {
            }) {
                Text("Cancel")
            }
        } label: {
            VStack(alignment: .center) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        
                    
                    VStack {
                        ZStack {
                            Circle()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.white)
                                .shadow(radius: 1)

                            Image(systemName: "plus")
                                .font(Font.subheadline.weight(.bold))
                                .foregroundColor(mainColor())
                        }
                        
                        Text("Add Photo")
                            .bold()
                    }
                    .border(Color.black, width: 3.0, isDashed: true)
                }
                .frame(width: 300)
            }
            .background(formBackgroundColor())
            .frame(width: 300, height: 200)
        }
    }
        
        func onCommit(_ search: String) {
            commitCount += 1
            commitedSearch = search
        }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
