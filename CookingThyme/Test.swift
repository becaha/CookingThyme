//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

// add photo
//VStack(alignment: .center) {
//    VStack {
//        EditPhotoButton()
//            .padding(.bottom, 5)
//
//        Text("Add Photo")
//            .font(.subheadline)
//            .padding(.top, 0)
//    }
//    .border(Color.black, width: 3.0, isDashed: true)
//    .frame(width: geometry.size.width/2)
//}
//.frame(width: geometry.size.width)

struct Test: View {
    var confirmAddIngredient = false
    
    var body: some View {
        VStack(alignment: .center) {
            VStack {
                GeometryReader { geometry in
                    HStack {
                        ScrollView(.horizontal) {
                            HStack {
                                Rectangle()
                                    .frame(width: geometry.size.width/2, height: geometry.size.height, alignment: .center)
                                    .clipped()
                                    .border(Color.black, width: 3)
                                        
                                Rectangle()
                                    .frame(width: geometry.size.width/2, height: geometry.size.height, alignment: .center)
                                    .clipped()
                                    .border(Color.black, width: 3)
                            }
                            .foregroundColor(Color.white)
                            .frame(minWidth: geometry.size.width)
                        }
                    }
                }
                .frame(height: 150)

                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                        .opacity(0.8)

                    Circle()
                        .stroke(Color.black)
                        .frame(width: 40, height: 40)

                    //TODO add button or camera button?
                    Image(systemName: "plus")
                }
                
            }
            .padding()
        }
        .padding(.horizontal)
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
