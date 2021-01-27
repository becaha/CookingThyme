//
//  CustomFormSectionItem.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct CustomFormSectionItem: ViewModifier {
    var isLastItem: Bool = false
    var backgroundColor: Color = Color.white
    
    init() {}
    
    init(isLastItem: Bool) {
        self.isLastItem = isLastItem
    }
    
    init(isLastItem: Bool, backgroundColor: Color) {
        self.isLastItem = isLastItem
        self.backgroundColor = backgroundColor
    }
    
    init(backgroundColor: Color) {
        self.backgroundColor = backgroundColor
    }
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            HStack {
                content
                    .padding()

                Spacer()
            }
            .background(backgroundColor)
            
            if !isLastItem {
                Divider()
            }
        }
        .padding(0)
    }
}

struct CustomFormSectionItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            Text("hi")
                .formSectionItem()
            
            Text("so long it is ridoijdfosij couhow tlong this message actually is")
                .formSectionItem(isLastItem: true)
        }
        .formSection()
    }
}

extension View {
    func formSectionItem() -> some View {
        modifier(CustomFormSectionItem())
    }
    
    func formSectionItem(isLastItem: Bool) -> some View {
        modifier(CustomFormSectionItem(isLastItem: isLastItem))
    }
    
    func formSectionItem(backgroundColor: Color) -> some View {
        modifier(CustomFormSectionItem(backgroundColor: backgroundColor))
    }
    
    func formSectionItem(isLastItem: Bool, backgroundColor: Color) -> some View {
        modifier(CustomFormSectionItem(isLastItem: isLastItem, backgroundColor: backgroundColor))
    }
}
