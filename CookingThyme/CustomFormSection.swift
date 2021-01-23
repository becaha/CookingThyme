//
//  CustomFormSection.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct CustomFormSection: ViewModifier {
    var backgroundColor: Color
    
    init() {
        self.backgroundColor = formBackgroundColor()
    }
    
    init(backgroundColor: Color) {
        self.backgroundColor = backgroundColor
    }
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .stroke(formBorderColor())
                
                RoundedRectangle(cornerRadius: 7)
                    .fill(backgroundColor)
                
                VStack {
                    content
                 
//                    Spacer()
                }
                .padding()
            }
            .padding(.horizontal)
            .frame(width: geometry.size.width)
            .fixedSize()
        }
    }
}

struct CustomFormSection_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            VStack {
                Text("hi")
                    .formSectionItem()
                
                Text("hi")
                    .formSectionItem()
            }
            .formSection()
            
            VStack {
                Text("hi")
                    .formSectionItem()
                
                Text("hi")
                    .formSectionItem()
            }
            .formSection()
        }
    }
}

extension View {
    func formSection() -> some View {
        modifier(CustomFormSection())
    }
}
