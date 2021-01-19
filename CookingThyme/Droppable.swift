//
//  Droppable.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/19/21.
//

import SwiftUI

struct Droppable: ViewModifier {
    let condition: Bool
    let types: [String]
    let tracking: Binding<Bool>?
    let action: ([NSItemProvider]) -> Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if condition {
            content.onDrop(of: types, isTargeted: tracking, perform: action)
        } else {
            content
        }
    }
}

extension View {
    public func droppable(if condition: Bool, of supportedTypes: [String], isTargeted: Binding<Bool>?, perform action: @escaping ([NSItemProvider]) -> Bool) -> some View {
        self.modifier(Droppable(condition: condition, types: supportedTypes, tracking: isTargeted, action: action))
    }
}
