//
//  CustomForm.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/18/21.
//

import SwiftUI

struct CustomForm: ViewModifier {
    var backgroundColor: Color
    
    init() {
        self.backgroundColor = formBackgroundColor()
    }
    
    init(backgroundColor: Color) {
        self.backgroundColor = backgroundColor
    }
    
    func body(content: Content) -> some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                content
                
                Spacer()
            }
            .padding(.top)
        }
        .background(backgroundColor)
    }
}

struct CustomForm_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Divider()
            
            ZStack {
        
//                VStack(spacing: 0) {
                    ForEach((1...20).reversed(), id: \.self) {
                        Text("\($0)").formItem()
                    }
//                }
                .formed(backgroundColor: Color.gray)
                
                VStack {
                    Spacer()

                    HStack {
                        Spacer()
                        
                        Button(action: {
        //                    createRecipe()
                        }) {
                            ZStack {
                                Circle()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                    .shadow(radius: 5)

                                Image(systemName: "plus")
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom)
                .zIndex(1)
            }
//            
//            List {
//                Text("Hi")
//            }
//            .listStyle(InsetGroupedListStyle())
        }
    }
}

extension View {
    func formed() -> some View {
        modifier(CustomForm())
    }
    
    func formed(backgroundColor: Color) -> some View {
        modifier(CustomForm(backgroundColor: backgroundColor))
    }
}
