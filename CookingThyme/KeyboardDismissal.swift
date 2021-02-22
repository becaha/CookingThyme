//
//  KeyboardDismissal.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/22/21.
//

import SwiftUI
import Combine

struct KeyboardDismissal: ViewModifier {
    @State var keyboardPresented = false

    func body(content: Content) -> some View {
        content
            .onReceive(Publishers.keyboardHeight) { height in
                keyboardPresented = height == 0 ? false : true
            }
            .gesture(keyboardPresented ?
                        TapGesture(count: 1).onEnded {
                withAnimation {
                    unfocusEditable()
                }
            } : nil)
    }
}

extension View {
    func keyboardDismissable() -> some View {
        self.modifier(KeyboardDismissal())
    }
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
