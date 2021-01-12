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
    
    init() {
        self.backgroundColor = Color.white
    }
    
    init(backgroundColor: Color) {
        self.backgroundColor = backgroundColor
    }
    
    func body(content: Content) -> some View {
        content
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(formBorderColor())
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(backgroundColor)
            }
        )
    }
}

struct CustomFormItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hi").formed()
        }
//        .background(formBackgroundColor())
    }
}

extension View {
    func formed() -> some View {
        modifier(CustomFormItem())
    }
    
    func formed(backgroundColor: Color) -> some View {
        modifier(CustomFormItem(backgroundColor: backgroundColor))
    }
}
