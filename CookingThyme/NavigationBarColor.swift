//
//  NavigationBarColor.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/5/21.
//

import SwiftUI

struct NavigationBarColor: ViewModifier {
        
    var backgroundColor: UIColor?
    var textColor: UIColor
    var text: String
    var style: UIFont.TextStyle
    
    init(backgroundColor: UIColor?, text: String, style: UIFont.TextStyle?, textColor: UIColor?) {
        self.backgroundColor = backgroundColor
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = .clear
        coloredAppearance.shadowColor = UIColor(borderColor())
        
        self.textColor = textColor ?? UIColor(navBarFont())
        self.text = text
        self.style =  style ?? UIFont.TextStyle.title2
//        coloredAppearance.titleTextAttributes = [.foregroundColor: textColor]
//        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: textColor]
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = .black

    }
    
    func body(content: Content) -> some View {
        ZStack{
            content
            VStack {
                GeometryReader { geometry in
                    ZStack {
                        Color(self.backgroundColor ?? .clear)
                        
                        VStack {
                            Spacer()
                            
                            Text("\(self.text)")
                                .customFont(style: self.style, weight: .bold)
                                .foregroundColor(Color(textColor))
                                .padding(.bottom, 10)
                        }
                    }
                    .frame(height: geometry.safeAreaInsets.top)
                    .edgesIgnoringSafeArea(.all)
                    
                    Spacer()
                }
            }
        }
    }
}


extension View {
    func navigationBarColor(_ backgroundColor: UIColor?, text: String, style: UIFont.TextStyle?, textColor: UIColor?) -> some View {
        modifier(NavigationBarColor(backgroundColor: backgroundColor, text: text, style: style, textColor: textColor))
    }
    
    func navigationBarColor(_ backgroundColor: UIColor?, text: String, style: UIFont.TextStyle?) -> some View {
        modifier(NavigationBarColor(backgroundColor: backgroundColor, text: text, style: style, textColor: nil))
    }
}
