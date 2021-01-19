//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/18/20.
//

import SwiftUI

struct Test: View {
    var categories = ["a"]
    var recipes = ["ra", "rb", "rc"]
    @State private var positionY: CGFloat = 0
    @State private var frameY: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(categories, id: \.self) { category in
                    Circle()
                        .frame(width: 40, height: 40)
                        .padding()
                }
                
                Text("\(positionY)")
                
                Text("\(frameY)")
            }
            
            GeometryReader { frameGeometry in
                VStack {
                    ForEach((1...20).reversed(), id: \.self) { num in
                        NavigationLink(destination: Text("Recipe")) {
                            Text("\(num)")
                                .formItem(isNavLink: true)
                        }
                    }
                    
                    Spacer()
                    
                    GeometryReader { geometry -> Text in
                        positionY = geometry.frame(in: .global).minY
                        frameY = frameGeometry.frame(in: .global).maxY
                        return Text("")
                    }
                }
                .formed()
            }

            VStack {
                HStack {
                    Button(action: {
//                        createRecipe()
                    }) {
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(mainColor())

                                Image(systemName: "plus")
                                    .font(Font.subheadline.weight(.bold))
//                                    .imageScale(.small)
                                    .foregroundColor(.white)
                            }
                            
                            Text("New Recipe")
                                .bold()
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .overlay(
                Rectangle()
                    .frame(width: nil, height: positionY <= frameY ? 0 : 1, alignment: .top)
                    .foregroundColor(Color.gray),
                alignment: .top)
        }
        .foregroundColor(mainColor())
        .background(formBackgroundColor())
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
