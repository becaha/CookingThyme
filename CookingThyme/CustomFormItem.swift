//
//  CustomFormItem.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/12/21.
//

import SwiftUI

//struct CustomForm: View {
//    var items: [View]
//
//    var body: some View {
//        VStack {
//            ForEach(0..<items.count) { index in
//                items[index].formed()
//            }
//        }
//        .background(Color.blue)
//    }
//}
//
//struct CustomForm_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            Text("Hi").formed()
//        }
//    }
//}

struct CustomFormItem: ViewModifier {
    var backgroundColor: Color
    var isNavLink: Bool
    
    init() {
        self.backgroundColor = Color.white
        self.isNavLink = false
    }
    
    init(backgroundColor: Color) {
        self.backgroundColor = backgroundColor
        self.isNavLink = false
    }
    
    init(isNavLink: Bool) {
        self.backgroundColor = Color.white
        self.isNavLink = isNavLink
    }
    
    func body(content: Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .stroke(formBorderColor())
            
            RoundedRectangle(cornerRadius: 7)
                .fill(backgroundColor)
            
            HStack {
                content
                    .foregroundColor(.black)
             
                Spacer()
                
                if isNavLink {
                    Image(systemName: "chevron.right")
                        .foregroundColor(mainColor())
                }
            }
            .padding()
        }
        .frame(height: 40)
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

struct CustomFormItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Divider()

            Text("Hi").formItem()
            
            Text("Hi").formItem()
        }
//        .background(formBackgroundColor())
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
}
