//
//  SearchTest.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/18/20.
//

import SwiftUI

struct SearchTest: View {
    var categories = ["a"]
    var recipes = ["ra", "rb", "rc"]
    @State private var scrollMinY: CGFloat = 0
    @State private var frameMinY: CGFloat = 0
    
    @State private var search: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(categories, id: \.self) { category in
                    Circle()
                        .frame(width: 40, height: 40)
                        .padding()
                }
                
                Text("\(scrollMinY)")
                
                Text("\(frameMinY)")
            }
            
            Divider()
                .foregroundColor(.blue)
            
            GeometryReader { frameGeometry in
                VStack(spacing: 0) {
                    GeometryReader { geometry in
                        HStack {
                            TextField("Search", text: $search, onCommit: {
                                print("\(search)")
                            })
                            .font(Font.body.weight(.regular))
                            .foregroundColor(.black)
                            .opacity(getOpacity(frameMinY: frameGeometry.frame(in: .global).minY, scrollMinY: geometry.frame(in: .global).minY))
                            
                            Button(action: {
                                print("\(search)")
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .font(Font.body.weight(.regular))
                                    .foregroundColor(searchFontColor())
                                    .opacity(getOpacity(frameMinY: frameGeometry.frame(in: .global).minY, scrollMinY: geometry.frame(in: .global).minY))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .formItem(isSearchBar: true)
                        .scaleEffect(y: getScale(frameMinY: frameGeometry.frame(in: .global).minY, scrollMinY: geometry.frame(in: .global).minY))
                    }
                    .frame(height: 35)
                    .padding(.bottom)

                    
                    ForEach((1...20).reversed(), id: \.self) { num in
                        NavigationLink(destination: Text("Recipe")) {
                            Text("\(num)")
                                .formItem(isNavLink: true)
                        }
                    }
                    
                    Spacer()
                }
                .formed()
                .padding(.top, 0)
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
//                    .frame(width: nil, height: positionY <= frameY ? 0 : 1, alignment: .top)
                    .foregroundColor(Color.gray),
                alignment: .top)
        }
        .foregroundColor(mainColor())
        .background(formBackgroundColor())
    }
    
    // frame min y = 116
    // search min y = 116 -> (116 - 35)  116 -> 81
    func getScale(frameMinY: CGFloat, scrollMinY: CGFloat) -> CGFloat {
        self.frameMinY = frameMinY
        self.scrollMinY = scrollMinY
        if frameMinY - scrollMinY >= -5 && frameMinY - scrollMinY <= 35 {
            return CGFloat(35 - (frameMinY - scrollMinY + 5)) / 35.0
        }
        return 1
    }
    
    func getOpacity(frameMinY: CGFloat, scrollMinY: CGFloat) -> Double {
        self.frameMinY = frameMinY
        self.scrollMinY = scrollMinY
        if frameMinY - scrollMinY >= 0 && frameMinY - scrollMinY <= 35 {
            return Double(35 - (3 * (frameMinY - scrollMinY))) / 35.0
        }
        return 1
    }
}

struct SearchTest_Previews: PreviewProvider {
    static var previews: some View {
        SearchTest()
    }
}
