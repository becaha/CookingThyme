//
//  Deletable.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/25/20.
//

import SwiftUI

// for a deletable item
struct Deletable: ViewModifier {
    var isDeleting: Bool
    var onDelete: () -> Void
    var isCentered: Bool = true
    
    init(isDeleting: Bool, onDelete: @escaping () -> Void) {
        self.isDeleting = isDeleting
        self.onDelete = onDelete
    }
    
    init(isDeleting: Bool, onDelete: @escaping () -> Void, isCentered: Bool?) {
        self.isDeleting = isDeleting
        self.onDelete = onDelete
        if let isCentered = isCentered {
            self.isCentered = isCentered
        }
    }
    
    func body(content: Content) -> some View {
        HStack {
            if isDeleting {
                VStack {
                    if isCentered {
                        Spacer()
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "minus.circle.fill")
                            .frame(width: 20, height: 20, alignment: .center)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
            }
            content
        }
    }
}

struct Deletable_Previews: PreviewProvider {
    static var previews: some View {
        Text("Long long text thaat porbably goies on two different lines. wow it is centered. Maybe we don't wnat that sometimes.")
            .deletable(isDeleting: true, onDelete: {print("delete")})
    }
}

extension View {
    func deletable(isDeleting: Bool, onDelete: @escaping () -> Void) -> some View {
        modifier(Deletable(isDeleting: isDeleting, onDelete: onDelete))
    }
    
    func deletable(isDeleting: Bool, onDelete: @escaping () -> Void, isCentered: Bool) -> some View {
        modifier(Deletable(isDeleting: isDeleting, onDelete: onDelete, isCentered: isCentered))
    }
}

