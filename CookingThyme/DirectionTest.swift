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
    
    var directions = ["mix", "drink"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("INGREDIENTS")
                
                Spacer()
            }
            .padding([.leading, .top])
            .padding(.bottom, 5)
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 7)
                    .foregroundColor(.white)
            
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 20) {
                        // edit
                        Group {
                            Text("\(20)")
                            
                            TextEditor(text: $newDirection)
                                .fixedSize(horizontal: false, vertical: true)
//                                .padding(.vertical, -7)
                            
    //                            TextField("\(directions[0])", text: $newDirection)

                        }
                        .padding(.vertical)
                    }
                    
                    Divider()
                        .foregroundColor(formBorderColor())
                    
                    HStack(alignment: .top, spacing: 20) {
                        // edit
                        Group {
                            Text("\(21)")
                            
                            TextEditor(text: $newDirection)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.vertical, -7)

                        }
                        .padding(.vertical)
                    }
                }
                .padding(.horizontal)
            }
            .padding([.horizontal, .bottom])
        }
        .formed()
    }
}

struct DirectionTest_Previews: PreviewProvider {
    static var previews: some View {
        DirectionTest()
    }
}
