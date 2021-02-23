//
//  CustomFormItem.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import SwiftUI

struct CustomFormItem: ViewModifier {
    var backgroundColor: Color = formItem()
    var isNavLink: Bool
    var cornerRadius: CGFloat = 7
    var height: CGFloat = 40
    var isSearchBar: Bool = false
    var padding: Bool = false
    var centered: Bool = false
    
    init() {
        self.isNavLink = false
        self.padding = true
    }
    
    init(backgroundColor: Color) {
        self.backgroundColor = backgroundColor
        self.isNavLink = false
        self.padding = true
    }
    
    init(centered: Bool, backgroundColor: Color) {
        self.backgroundColor = backgroundColor
        self.isNavLink = false
        self.padding = true
        self.centered = centered
    }
    
    init(isNavLink: Bool) {
        self.isNavLink = isNavLink
        self.padding = true
    }
    
    init(padding: Bool) {
        self.isNavLink = false
        self.padding = padding
    }
    
    init(isSearchBar: Bool) {
        self.backgroundColor = searchBarColor()
        self.isNavLink = false
        if isSearchBar {
            self.height = 35
            self.isSearchBar = true
        }
        self.padding = true
    }
    
    func body(content: Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(formBorderColor())
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
            
            HStack {
                content
                    .foregroundColor(formItemFont())
             
                if !centered {
                    Spacer()
                }
                
                if isNavLink {
                    Image(systemName: "chevron.right")
                        .foregroundColor(mainColor())
                }
            }
            .padding()
            .frame(height: height)

        }
        .frame(height: height)
        .padding(padding ? .horizontal : [])
        .padding(.vertical, 2)
        .padding(isSearchBar ? .bottom : [])
    }
}

struct CustomFormItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Divider()
            
            Text("Hi").formItem(isSearchBar: true)

            Text("Hi").formItem(backgroundColor: mainColor())

            
            Text("Hi").formItem()

        }
        .background(formBackgroundColor())
        .formed()
    }
}

extension View {
    func formItem() -> some View {
        modifier(CustomFormItem())
    }
    
    func formItem(backgroundColor: Color) -> some View {
        modifier(CustomFormItem(backgroundColor: backgroundColor))
    }
    
    func formItem(isNavLink: Bool) -> some View {
        modifier(CustomFormItem(isNavLink: isNavLink))
    }
    
    func formItem(isSearchBar: Bool) -> some View {
        modifier(CustomFormItem(isSearchBar: isSearchBar))
    }
    
    func formItem(padding: Bool) -> some View {
        modifier(CustomFormItem(padding: padding))
    }
    
    func formItem(centered: Bool, backgroundColor: Color) -> some View {
        modifier(CustomFormItem(centered: centered, backgroundColor: backgroundColor))
    }
}
