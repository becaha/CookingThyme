//
//  FormTitle.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/23/20.
//

import SwiftUI

struct FormTitle: ViewModifier {
    var title: String
    
    func body(content: Content) -> some View {
        ZStack {
            VStack {
                HStack {
                    Text("")
                        .customFont(style: .title1)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                content
            }
            
            VStack {
                HStack {
                    Text("\(title)")
                        .customFont(style: .title1)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                Spacer()
            }
        }
        .background(formBackgroundColor())
    }
}

extension View {
    func formTitle(title: String) -> some View {
        return modifier(FormTitle(title: title))
    }
}


//struct FormTitle_Previews: PreviewProvider {
//    static var previews: some View {
//        Text("hi")
//    }
//}
