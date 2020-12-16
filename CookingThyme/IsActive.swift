//
//  IsActive.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/8/20.
//

import SwiftUI

// if screen is active
struct IsActive: ViewModifier {
    @Binding var isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                self.isActive = false
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                self.isActive = true
            }
    }
}

extension View {
    func isActive(_ isActive: Binding<Bool>) -> some View {
        modifier(IsActive(isActive: isActive))
    }
}
