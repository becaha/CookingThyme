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
    var padding: Edge.Set = .all
    
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
    
    init(padding: Edge.Set) {
        self.padding = padding
    }
    
    init(padding: Edge.Set, isLastItem: Bool) {
        self.padding = padding
        self.isLastItem = isLastItem
    }
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            HStack {
                content
                    .padding(padding)

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
                .padding()
                .background(Color.blue)
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
    
    func formSectionItem(padding: Edge.Set) -> some View {
        modifier(CustomFormSectionItem(padding: padding))
    }
    
    func formSectionItem(isLastItem: Bool) -> some View {
        modifier(CustomFormSectionItem(isLastItem: isLastItem))
    }
    
    func formSectionItem(padding: Edge.Set, isLastItem: Bool) -> some View {
        modifier(CustomFormSectionItem(padding: padding, isLastItem: isLastItem))
    }
    
    func formSectionItem(backgroundColor: Color) -> some View {
        modifier(CustomFormSectionItem(backgroundColor: backgroundColor))
    }
    
    func formSectionItem(isLastItem: Bool, backgroundColor: Color) -> some View {
        modifier(CustomFormSectionItem(isLastItem: isLastItem, backgroundColor: backgroundColor))
    }
}
