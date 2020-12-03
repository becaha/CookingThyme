//
//  Deletable.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/25/20.
//

import SwiftUI

struct Deletable: ViewModifier {
    @State var isDeleting: Bool
    @State var onDelete: () -> Void
    
    func body(content: Content) -> some View {
        HStack {
            if isDeleting {
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .frame(width: 20, height: 20, alignment: .center)
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
            content
        }
    }
}

struct Deletable_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hi").deletable(isDeleting: true, onDelete: {print("delete")})
    }
}

extension View {
    func deletable(isDeleting: Bool, onDelete: @escaping () -> Void) -> some View {
        modifier(Deletable(isDeleting: isDeleting, onDelete: onDelete))
    }
}

