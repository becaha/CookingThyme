//
//  CustomFont.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/22/21.
//

import SwiftUI

@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
struct CustomFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory

    var style: UIFont.TextStyle
    var name: String = mainFont()
    var weight: Font.Weight = .regular

    func body(content: Content) -> some View {
        return content.font(CustomFont.getFont(style: style, name: name, weight: weight))
    }
    
    static func getFont(style: UIFont.TextStyle,
                       name: String = mainFont(),
                       weight: Font.Weight = .regular) -> Font {
        Font.custom(
            name,
            size: UIFont.preferredFont(forTextStyle: style).pointSize)
            .weight(weight)
    }
}

@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
extension View {
    func customFont(
        style: UIFont.TextStyle,
        name: String = mainFont(),
        weight: Font.Weight = .regular) -> some View {
        return self.modifier(CustomFont(style: style, name: name, weight: weight))
    }
}

