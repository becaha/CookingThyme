//
//  DirectionTest.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/21/21.
//

import SwiftUI

struct DirectionTest: View {
    @State var isPresented = true
    @State var newDirection: String = "this is a verrrrrrrrrry long sentenece for sure double lines"
    
    var list = ["a", "b"]
    var directions = ["mix", "drink"]
    
    @State var text = "one lineer"
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        ForEach (0..<list.count, id: \.self) { index in
                            HStack {
//                                EditableTextView(textBinding: $text)
                            }
                            .formSectionItem()
                         }
                         .onDelete { indexSet in // (4)
                            // The rest of this function will be added later
                         }
                    }
                    .formSection()
                }
            }
            .background(formBackgroundColor())
            .navigationBarTitle("Recipes", displayMode: .inline)
        }
    }
}

struct DirectionTest_Previews: PreviewProvider {
    static var previews: some View {
        DirectionTest()
    }
}
