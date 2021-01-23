//
//  CustomFormSectionItem.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct CustomFormSectionItem: ViewModifier {
    @State var thyme: String = ""
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            HStack {
                content
                    .padding()

                Spacer()
            }
            
            Divider()
        }
    }
}

struct CustomFormSectionItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("hi")
                .formSectionItem()
            
            Text("so long it is ridoijdfosij couhow tlong this message actually is")
                .formSectionItem()
        }
        .formSection()
    }
}

extension View {
    func formSectionItem() -> some View {
        modifier(CustomFormSectionItem())
    }
}
