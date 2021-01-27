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
        self.backgroundColor = Color.white
    }
    
    init(backgroundColor: Color) {
        self.backgroundColor = backgroundColor
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(RoundedRectangle(cornerRadius: 7).stroke(formBorderColor()))
            .background(RoundedRectangle(cornerRadius: 7).fill(Color.white))
            .padding([.horizontal])
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
            
            Form {
                Text("hi")
                
                Text("hi")
            }
        }
        .background(Color.blue)

    }
}

extension View {
    func formSection() -> some View {
        modifier(CustomFormSection())
    }
}
